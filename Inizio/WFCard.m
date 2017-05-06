//
//  WFCard.m
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "WFCard.h"

@implementation WFCard

-(id)initWithClipName: (NSString *)clipName withFrameName: (NSString *)frameName withSubtitle: (NSString *)subtitle withIsDidDownload: (BOOL)isDidDownload
{
    self = [super init];
    if (self)
    {
        _clipName = clipName;
        _frameName = frameName;
        _subtitle = subtitle;
        _isDidDownload = isDidDownload;
    }
    return self;
}

@end
