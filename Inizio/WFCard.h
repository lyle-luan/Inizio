//
//  WFCard.h
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFCard : NSObject

@property (nonatomic, readonly, strong) NSString *clipName;
@property (nonatomic, readonly, strong) NSString *frameName;
@property (nonatomic, readonly, strong) NSString *subtitle;
@property (nonatomic, readonly, assign) BOOL isDidDownload;

- (id)initWithClipName: (NSString *)clipName withFrameName: (NSString *)frameName withSubtitle: (NSString *)subtitle withIsDidDownload: (BOOL)isDidDownload;

@end
