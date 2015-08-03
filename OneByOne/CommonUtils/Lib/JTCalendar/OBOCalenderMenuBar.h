//
//  OBOCalenderMenuBar.h
//  TestJTCalender
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  JTCalendar;
@protocol OBOCalenderMenuDelegate <NSObject>
@required
-(void)CalenderMenuLeftBtnClicked:(id)sender;
-(void)CalenderMenuRightBtnClicked:(id)sender;
-(void)CalenderMenuTitleBtnClicked:(id)sender;
@end

@interface OBOCalenderMenuBar : UIView
@property(nonatomic,weak)id<OBOCalenderMenuDelegate> delegate;
@property(nonatomic,strong)UIButton*leftBtn;
@property(nonatomic,strong)UIButton*rightBtn;
@property(nonatomic,strong)UIButton*titleBtn;

-(void)setCurrentDate:(NSDate*)currentDate;

@end
