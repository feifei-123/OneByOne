//
//  OBOCalenderView.h
//  TestJTCalender
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"
#import "OBOCalenderMenuBar.h"

@protocol OBOCalenderViewDelegate <NSObject>
-(void)upSwipAction:(id)sender;
-(void)downSwipAction:(id)sender;
@end


@interface OBOCalenderView : UIView
@property(nonatomic,strong) OBOCalenderMenuBar * OBOMenueBar;//日历的标题菜单栏
//delegate
@property(nonatomic,weak,setter=setCalenderDataSource:) id<JTCalendarDataSource> calenderDataSource;
@property(nonatomic,weak,setter=setCalenderMenuDelegate:) id<OBOCalenderMenuDelegate>calenderMenuDelegate;
@property(nonatomic,weak)id<OBOCalenderViewDelegate> oboCalenderViewDelegete;

//------内部封装 的JTCalendar  类
@property (strong, nonatomic) JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;
@property (strong,nonatomic)  NSDate*currentDate;
@property (strong,nonatomic)  UIImage *bgImage;

@property(assign,nonatomic)CGFloat calenderHeaderHeight;
@property(assign,nonatomic)CGFloat calenderMenuBarHeight;
@property(assign,nonatomic)CGFloat leftMargin;
@property(assign,nonatomic)CGFloat rightMargin;
@property(assign,nonatomic)CGFloat bottomMargin;

-(void)refreshConstraints;
-(void)addUpSwipGestureWith:(SEL)upSwipAction AndDownSwipAction:(SEL)downSwipAction;
@end
