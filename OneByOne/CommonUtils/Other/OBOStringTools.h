//
//  OBOStringTools.h
//  OneByOne
//
//  Created by macbook on 15-5-5.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OBOEventFrameModel;

/** 日程类型 **/
typedef enum {
    kNotAEventType = -1,        //不是日程类型
    kEventTypeTemporary = 0,    // 临时
    kEventTypeWork,             // 工作
    kEventTypeFamily,           // 家人
    kEventTypeFriend,           // 朋友
    kEventTypeLove,             // 爱情
    kEventTypeSelf              // 自我
}kEventType;

/** 日程状态 **/
typedef enum {
    kEventStatePending = 0,     // 待处理
    kEventStateComplete,        // 已完成
    kEventStateCancelled,       // 已取消
    kEventStateAdjusted,        // 已调整
    kEventStateNone             // 无指定状态
}kEventState;

/** 日程分类 **/
typedef enum {
    kEventClassifySche = 0,     // 日程
    kEventClassifyEvent,         // 事件
    kEventClassifyNone,         // 无事件
}kEventClassify;

/** 重复类型 **/
typedef enum {
    kRepeatTypeNone = 0,     // 从不重复
    kRepeatTypeDaily,        // 每天
    kRepeatTypeWorkDay,      // 工作日
    kRepeatTypeWeekly,      // 每周
    kRepeatTypeMonthly,      // 每月
    kRepeatTypeYearly,      // 每月
}kRepeatType;

/** 日程类型 **/
typedef enum {
    kNotARemindType = -1,       //不是提醒类别
    kWithOutRemind = 0,         //无
    kRemindWHappen = 1,         //日程发生时
    k5MinAhead,                 // 提前5分钟
    k15MinAhead,                // 提前15分钟
    k30MinAhead,                // 提前30分钟
    k1HourAhead,                // 提前1h
    k2HourAhead,                // 提前2h
    k1DayAhead,                 // 提前1天
    k2DayAhead,                 // 提前2天
    k1WeekAhead,                //提前1周
}kRemindType;

/** 插入数据返回的结果 **/
typedef enum {
    kInsertDataResultSuccess = 0,     // 插入成功
    kInsertDataResultAlreadyExists,   // 记录已经存在
    kInsertDataResultOther            // 其他
}kInsertDataResult;


@interface OBOStringTools : NSObject

+ (NSString *)stringWithEventType:(kEventType)type;

+ (NSString *)stringWithEventState:(kEventState)state;

+ (NSString *)stringWithRemind:(kRemindType)remind;

+ (NSString *)stringWithRepeat:(kRepeatType)repeat;

+ (UIImage *)imageWithEventState:(kEventState)state;

+ (UIImage *)smallImageWithEventType:(kEventType)type;

+ (UIImage *)detailImageWithEventState:(kEventState)state;

+ (NSString *)dateStringWithOffset:(NSInteger)count;

+ (NSDate *)currentDate;

+ (NSDate *)formatDateWithString:(NSString *)date;

+ (NSDate *)currentTime;

+ (NSDate *)formatTimeWithString:(NSString *)time;

+ (NSDate *)dateWithOffset:(NSInteger)offset;

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringWithDayTipsFromDate:(NSDate *)date;
+ (NSString *)stringFromTime:(NSDate *)time;
+ (NSDate *)currentTimeWithOffset:(NSInteger)offset;

+ (NSString *)cTransformFromE:(NSString *)theWeek;

@end
