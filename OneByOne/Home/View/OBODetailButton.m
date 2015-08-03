//
//  OBODetailButtonView.m
//  OneByOne
//
//  Created by macbook on 15-6-22.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBODetailButton.h"

#define kIconWidth  32

@implementation OBODetailButton

// 不能使用self.titleLabel 因为self.titleLabel内部会调用titleRectForContentRect
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = 0;
    CGFloat titleW = 0;
    CGFloat titleH = 0;
    NSDictionary *dict = @{
                           NSFontAttributeName : kDetailButtonFont
                           };
    CGRect titleRc = [self.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:dict context:nil];
    
    titleW = titleRc.size.width;
    titleH = contentRect.size.height;
    titleX = kIconWidth + (self.bounds.size.width - kIconWidth - titleW) / 2;
    //    titleY = (titleH - titleRc.size.height) / 2;
    titleY = 0;
    
    //    NSLog(@"%d,%s",1,__func__);
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageH = self.frame.size.height;
    //    CGFloat imageX = CGRectGetMaxX([self titleRectForContentRect:contentRect]);
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    NSLog(@"%d,%s",2,__func__);
    
    return CGRectMake(imageX, imageY, kIconWidth, imageH);
}

- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
