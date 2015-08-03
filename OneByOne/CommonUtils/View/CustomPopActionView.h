//
//  CustomPopActionView.h
//  MyPopSheet
//
//  Created by 白雪飞 on 15-5-4.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomPopActionDelegate <NSObject>

-(void)bottomPopViewOkBtnClicked:(NSInteger)flag;

@end

@interface CustomPopActionView : UIView

@property (nonatomic,assign)float contentViewHeight;//内容视图的高度

@property (nonatomic,strong)id<CustomPopActionDelegate> delegate;

- (id)initWithTitle:(NSString *)title referView:(UIView *)referView;
-(void)show;
-(void)hide;
-(void)addComponentView:(UIView *)comonent;
-(void)setTitle:(NSString *)title;

@end
