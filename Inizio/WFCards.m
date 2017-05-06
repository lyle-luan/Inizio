//
//  WFCards.m
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "WFCards.h"
#import "WFCard.h"
#import "ClipItem+CoreDataProperties.h"

@import CoreData;

@interface WFCards()
@property (nonatomic, readwrite, strong) NSArray<WFCard *> *allCards;
@property (nonatomic, readwrite, strong) NSArray<ClipItem *> *clipItems;

@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readwrite, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation WFCards

+ (WFCards *)shared
{
    static WFCards *sharedWFCardsInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (sharedWFCardsInstance == nil)
        {
            sharedWFCardsInstance = [[WFCards alloc] init];
            sharedWFCardsInstance.currentIndex = 0;
            sharedWFCardsInstance.allCards = [sharedWFCardsInstance fetchAllCards];
        }
    });
    return sharedWFCardsInstance;
}

- (NSInteger)next
{
    self.currentIndex += 1;
    self.currentIndex %= self.allCards.count;
    return self.currentIndex;
}

- (NSInteger)previous
{
    self.currentIndex -= 1;
    if (self.currentIndex < 0) { self.currentIndex = self.allCards.count - 1; }
    return self.currentIndex;
}

- (NSInteger)count
{
    return self.allCards.count;
}

- (NSString *)currentCardPicName
{
    return self.allCards[self.currentIndex].frameName;
}

- (NSString *)currentCardSubtitle
{
    return self.allCards[self.currentIndex].subtitle;
}

- (NSURL *)currentMovieURL
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentPath, self.allCards[self.currentIndex].clipName]];
}

- (NSString *)snapShotNameAtIndex: (NSInteger)index
{
    if ((index >> 0) && (index < self.allCards.count))
    {
        return self.allCards[index].frameName;
    }
    else
    {
        return self.allCards[0].frameName;
    }
}

- (void)markDidDownloadClip: (NSRange)range
{
    NSMutableArray<WFCard *> *addNewCardArray = [NSMutableArray arrayWithArray:self.allCards];
    WFCard *lastCard = addNewCardArray.lastObject;
    [addNewCardArray removeLastObject];
    
    for (NSUInteger index=range.location; index<=range.length; ++index)
    {
        NSString *clipName = [NSString stringWithFormat:@"00000000%zd", index];
        NSUInteger clipNameLength = clipName.length;
        clipName = [clipName substringFromIndex:clipNameLength-6];
        
        clipName = [NSString stringWithFormat:@"%@.mp4", clipName];
        
        for (ClipItem *currentClipItem in self.clipItems)
        {
            if ([currentClipItem.clipName isEqualToString:clipName])
            {
                currentClipItem.isDidDownload = @YES;
                WFCard *aNewCard = [[WFCard alloc] initWithClipName:currentClipItem.clipName withFrameName:currentClipItem.clipPic withSubtitle:currentClipItem.subtitle withIsDidDownload:currentClipItem.isDidDownload];
                [addNewCardArray addObject:aNewCard];
            }
        }
    }
    
    [addNewCardArray addObject:lastCard];
    
    if (self.currentIndex == (self.allCards.count - 1))
    {
        self.currentIndex = addNewCardArray.count - 1;
    }
    self.allCards = [addNewCardArray copy];
    
    if ([self.managedObjectContext hasChanges])
    {
        NSLog(@"Save: %@", self.managedObjectContext);
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        NSLog(@"save error: %@", error);
    }
}

#pragma mark - property

- (NSArray<WFCard *> *)fetchAllCards
{
    NSMutableArray<WFCard *> *mutableAllCards = [NSMutableArray arrayWithCapacity:30];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"ClipItem"];
    fetch.returnsObjectsAsFaults = false;
    
    NSError *error = nil;
    self.clipItems = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    
    for (ClipItem *currentClipItem in self.clipItems)
    {
        if (currentClipItem.isDidDownload.boolValue)
        {
            WFCard *aNewCard = [[WFCard alloc] initWithClipName:currentClipItem.clipName withFrameName:currentClipItem.clipPic withSubtitle:currentClipItem.subtitle withIsDidDownload:currentClipItem.isDidDownload];
            [mutableAllCards addObject:aNewCard];
        }
    }
    
    WFCard *theAddCard = [[WFCard alloc] initWithClipName:@"" withFrameName:@"Download.png" withSubtitle:@"点击上面图片下载更多" withIsDidDownload:NO];
    [mutableAllCards addObject:theAddCard];
    
    _allCards = [mutableAllCards copy];
    
    return _allCards;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        _managedObjectContext.undoManager = nil;
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ClipItems" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil)
    {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
//        NSURL *storeClipData = [[NSBundle mainBundle] URLForResource:@"ClipItems" withExtension:@"sqlite"];
        
        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        
        BOOL isFirstLaunch = ![[NSUserDefaults standardUserDefaults] boolForKey:@"NotFirstLaunch"];
        
        if (isFirstLaunch)
        {
            NSString *databasePath = [[NSBundle mainBundle] URLForResource:@"ClipItems" withExtension:@"sqlite"].path;
            
            [[NSFileManager defaultManager] copyItemAtPath:databasePath toPath:[documentPath stringByAppendingPathComponent:[databasePath lastPathComponent]] error:NULL];
        }
        
        documentPath = [documentPath stringByAppendingPathComponent:@"ClipItems.sqlite"];
        NSURL *storeClipData = [NSURL fileURLWithPath:documentPath];
        
        NSDictionary *options = @{
                                  NSReadOnlyPersistentStoreOption : @YES,
                                  NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"}
                                  };
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeClipData options:options error:nil];
    }
    return _persistentStoreCoordinator;
}

@end
