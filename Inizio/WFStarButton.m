//
//  WFStarButton.m
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "WFStarButton.h"

@implementation WFStarButton

- (void)setIsStarred:(BOOL)isStarred
{
    _isStarred = isStarred;
    if (isStarred)
    {
        [self setImage:[UIImage imageNamed:@"Heart-Selected"] forState:UIControlStateNormal];
    }
    else
    {
        [self setImage:[UIImage imageNamed:@"Heart-Normal"] forState:UIControlStateNormal];
    }
}

@end
