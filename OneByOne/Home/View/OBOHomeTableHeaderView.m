//
//  OBOHomeTableHeaderView.m
//  OneByOne
//
//  Created by macbook on 15-5-2.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import "OBOHomeTableHeaderView.h"
#import "Constants.h"

@interface OBOHomeTableHeaderView()

@property (nonatomic, strong) UILabel *untreatedIssueView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic ,strong) NSArray *constraint;

@end

@implementation OBOHomeTableHeaderView

- (void)awakeFromNib
{
    self.imageView.contentMode = UIViewContentModeCenter;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeCenter;
//        self.backgroundColor = [UIColor redColor];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.titleLabel.font = kBigFont;

    }
    return self;
}

// 不能使用self.titleLabel 因为self.titleLabel内部会调用titleRectForContentRect
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = 0;
    CGFloat titleW = 0;
    CGFloat titleH = 0;
    NSDictionary *dict = @{
                           NSFontAttributeName : kBigFont
                           };
    CGRect titleRc = [self.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:dict context:nil];
    
    titleW = titleRc.size.width;
    titleH = contentRect.size.height;
    titleX = (self.bounds.size.width - titleW) / 2 + 5;
//    titleY = (titleH - titleRc.size.height) / 2;
    titleY = -2;
    
//    NSLog(@"%d,%s",1,__func__);
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = 32;
    CGFloat imageH = 32;
//    CGFloat imageX = CGRectGetMaxX([self titleRectForContentRect:contentRect]);
    CGFloat imageX = self.bounds.size.width - imageW - 110;
    CGFloat imageY = -2;
    NSLog(@"%d,%s",2,__func__);
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}
@end