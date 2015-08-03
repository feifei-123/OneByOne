//
//  OBOTableHeaderButton.m
//  OneByOne
//
//  Created by macbook on 15-7-23.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOTableHeaderButton.h"
#import "Constants.h"

#define kIconWidth 6
#define kIconHeight 6

#define kIconRightX 32

@implementation OBOTableHeaderButton

- (void)setHighlighted:(BOOL)highlighted{
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    //    CGFloat imageX = CGRectGetMaxX([self titleRectForContentRect:contentRect]);
    CGFloat imageX = kScreenWidth - kIconRightX;
    CGFloat imageY = (self.frame.size.height - kIconHeight) / 2;
    
    return CGRectMake(imageX, imageY, kIconWidth, kIconHeight);
}

@end

