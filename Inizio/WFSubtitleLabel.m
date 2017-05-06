//
//  WFSubtitleLabel.m
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "WFSubtitleLabel.h"

@implementation WFSubtitleLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, edgeInsets)];
}

@end
