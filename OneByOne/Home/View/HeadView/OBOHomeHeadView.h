//
//  OBOHomeHeadView.h
//  OneByOne
//  首页中头部视图，包括头像视图，切换以及日历视图
//  Created by RAT on 15-4-29.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBOHomeHeadView;
@class OBODetailTimeView;

@protocol OBOHomeHeadViewDelegate <NSObject>

@optional
- (void)homeHeadView:(OBOHomeHeadView *)headView iconClick:(UIButton *)icon;
- (void)homeHeadView:(OBOHomeHeadView *)headView calendarClick:(UIView *)calendar;
- (void)homeHeadView:(OBOHomeHeadView *)headView dateButtonClick:(UIButton *)button;

@end

@interface OBOHomeHeadView : UIView

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, weak)id<OBOHomeHeadViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *tempView;
@property (weak, nonatomic) IBOutlet UIImageView *weatherView;


- (void)iconWithName:(NSString *)icon;

- (void)selectedBtnIndex:(NSInteger)index;

- (void)weatherViewWithImage:(UIImage *)icon temp1:(int)temp1 temp2:(int)temp2;

@end
