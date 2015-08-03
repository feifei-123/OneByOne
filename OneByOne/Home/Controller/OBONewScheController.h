//
//  OBO_NewScheVController.h
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBOFatherController.h"
#import "CustomPopActionView.h"
#import "Utils.h"
#import "OBOCalenderView.h"
#import "Events.h"
#import "Constants.h"
#import "OBOCommonDelegate.h"

/*
@protocol OBONewScheduleDelegate <NSObject>
//通知首页，添加新日程的操作结果。
@required
-(void)addNewSchedule:(BOOL)sucess WithDay:(NSInteger)day AndScheModel:(Events*)model;
@end
*/

@interface OBONewScheController : OBOFatherController<JTCalendarDataSource,CustomPopActionDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,OBOCalenderMenuDelegate,UITextViewDelegate>

//delegate
@property(nonatomic,weak) id<OBOOperateDataDelegate>delegete;

//标记新建页面的类别
@property(nonatomic,assign) kNewScheduleViewType operationType;
//数据实体
@property(nonatomic,strong)Events *sheduleModel;

-(instancetype)initWithModel:(Events*)model;
@end
