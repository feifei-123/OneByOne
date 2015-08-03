//
//  RATTipsView.h
//  OneByOne
//
//  Created by macbook on 15-7-5.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RATTipsView : UIView

// 自动隐藏
@property (nonatomic, assign) BOOL autoHide;
// 自动隐藏时间
@property (nonatomic, assign) BOOL autoHideTime;
// 渐隐动画时间
@property (nonatomic, assign) CGFloat animateTime;
// 透明度
@property (nonatomic, assign) CGFloat showAlpha;
// 显示的文字
@property (nonatomic, strong, readonly) UILabel *labelView;
// 背景image
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL isShowing;

//+ (instancetype)tipsView;
+ (instancetype)sharedManager;

- (void)show;

- (void)hide;

@end
