//
//  WFCards.h
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFCards : NSObject

@property (nonatomic, readwrite, assign) NSInteger currentIndex;
@property (nonatomic, readonly, assign) NSInteger next;
@property (nonatomic, readonly, assign) NSInteger previous;
@property (nonatomic, readonly, assign) NSInteger count;
@property (nonatomic, readonly, strong) NSString *currentCardPicName;
@property (nonatomic, readonly, strong) NSString *currentCardSubtitle;
@property (nonatomic, readonly, strong) NSURL *currentMovieURL;
+ (WFCards *)shared;
- (NSString *)snapShotNameAtIndex: (NSInteger)index;
- (void)markDidDownloadClip: (NSRange)range;
@end
