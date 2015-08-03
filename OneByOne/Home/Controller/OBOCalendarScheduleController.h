//
//  OBOCalendarScheduleController.h
//  OneByOne
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBOFatherController.h"
#import "OBOCalenderView.h"
#import "OBOSearchBar.h"
#import "CustomPopActionView.h"
#import "SRMonthPicker.h"
#import "RATTabBar.h"
#import "OBONewScheController.h"
#import "OBOTableController.h"
#import "OBOCommonDelegate.h"
#import "MGSwipeTableCell.h"
#import "OBOCellContentView.h"


@interface OBOCalendarScheduleController : OBOTableController<JTCalendarDataSource,OBOCalenderMenuDelegate,UIScrollViewDelegate,CustomPopActionDelegate,SRMonthPickerDelegate,RATTabBarDelegate,OBOOperateDataDelegate,MGSwipeTableCellDelegate,OBOCalenderViewDelegate>

@property(nonatomic,strong)OBOCalenderView * oboCalenderView;
@property(nonatomic,strong) NSArray *calenderLayout;//日历主视图约束。
@property(nonatomic,strong) NSArray *searchBarConstraint;//搜索栏 的高度约束。
@property(nonatomic,strong) NSArray *footerViewLayout;
@property (nonatomic, weak) id<OBOOperateDataDelegate> operateDelegate;

@end
