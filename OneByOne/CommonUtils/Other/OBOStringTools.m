//
//  OBOStringTools.m
//  OneByOne
//
//  Created by macbook on 15-5-5.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import "OBOStringTools.h"
#import "Utils.h"
#import "Constants.h"

@implementation OBOStringTools

/**
 *  查询日程类型对应的字符串
 *
 *  @param type 日程类型
 *
 *  @return 日程字符串
 */
+ (NSString *)stringWithEventType:(kEventType)type{
    switch (type) {
        case kEventTypeTemporary:
            return @"临时";
            break;
        case kEventTypeWork:
            return @"工作";
            break;
        case kEventTypeFamily:
            return @"家人";
            break;
        case kEventTypeFriend:
            return @"朋友";
            break;
        case kEventTypeLove:
            return @"爱情";
            break;
        case kEventTypeSelf:
            return @"自我";
            break;
            
        default:
            return @"未知";
            break;
    }
}

/**
 *  查询日程状态对应的图片字符串
 *
 *  @param state 日程状态代码
 *
 *  @return 图片字符串
 */
+ (NSString *)stringWithEventState:(kEventState)state{
    switch (state) {
        case kEventStatePending:
            return @"未处理";
            break;
        case kEventStateComplete:
            return @"已完成";
            break;
        case kEventStateCancelled:
            return @"已取消";
            break;
        case kEventStateAdjusted:
            return @"已调整";
            break;
        default:
            return @"其他";
            break;
    }
}

/**
 *  查询提醒对应的字符串
 *
 *  @param state 提醒代码
 *
 *  @return 字符串
 */
+ (NSString *)stringWithRemind:(kRemindType)remind
{
    switch (remind) {
        case kNotARemindType:
            return @"不是提醒类别";
            break;
        case kWithOutRemind:
            return @"无提醒";
            break;
        case kRemindWHappen:
            return @"日程发生时";
            break;
        case k5MinAhead:
            return @"提前5分钟";
            break;
        case k15MinAhead:
            return @"提前15分钟";
            break;
        case k30MinAhead:
            return @"提前30分钟";
            break;
        case k1HourAhead:
            return @"提前1h";
            break;
        case k2HourAhead:
            return @"提前2h";
            break;
        case k1DayAhead:
            return @"提前1天";
            break;
        case k2DayAhead:
            return @"提前2天";
            break;
        case k1WeekAhead:
            return @"提前1周";
            break;
        default:
            return @"不是提醒类别";
            break;
    }
}

/**
 *  查询重复对应的字符串
 *
 *  @param state 重复代码
 *
 *  @return 字符串
 */
+ (NSString *)stringWithRepeat:(kRepeatType)repeat
{
    switch (repeat) {
        case kRepeatTypeNone:
            return @"从不重复";
            break;
        case kRepeatTypeDaily:
            return @"每天";
            break;
        case kRepeatTypeWorkDay:
            return @"工作日";
            break;
        case kRepeatTypeWeekly:
            return @"每周";
            break;
        case kRepeatTypeMonthly:
            return @"每月";
            break;
        case kRepeatTypeYearly:
            return @"每年";
            break;
        default:
            return @"不是重复类别";
            break;
    }
}

/**
 *  查询日程状态对应的图片
 *
 *  @param state 日程状态代码
 *
 *  @return 图片
 */
+ (UIImage *)imageWithEventState:(kEventState)state{
    switch (state) {
        case kEventStatePending:
            return [UIImage imageNamed:@"cell_stateview_pending_normal"];
            break;
        case kEventStateComplete:
            return [UIImage imageNamed:@"cell_stateview_complete_normal"];
            break;
        case kEventStateCancelled:
            return [UIImage imageNamed:@"cell_stateview_cancel_normal"];
            break;
        case kEventStateAdjusted:
            return [UIImage imageNamed:@"cell_stateview_adjust_normal"];
            break;
        default:
            return nil;
            break;
    }
}

/**
 *  查询日程状态对应的图片
 *
 *  @param state 日程状态代码
 *
 *  @return 图片
 */
+ (UIImage *)detailImageWithEventState:(kEventState)state{
    switch (state) {
        case kEventStatePending:
            return [UIImage imageNamed:@"detail_pending_normal"];
            break;
        case kEventStateComplete:
            return [UIImage imageNamed:@"detail_complete_normal"];
            break;
        case kEventStateCancelled:
            return [UIImage imageNamed:@"detail_cancel_normal"];
            break;
        case kEventStateAdjusted:
            return [UIImage imageNamed:@"detail_adjust_normal"];
            break;
        default:
            return nil;
            break;
    }
}

/**
 *  查询日程状态对应的小图片
 *
 *  @param state 日程状态代码
 *
 *  @return 图片
 */
+ (UIImage *)smallImageWithEventType:(kEventType)type{
    
//    typedef enum {
//        kNotAEventType = -1,        //不是日程类型
//        kEventTypeTemporary = 0,    // 临时
//        kEventTypeWork,             // 工作
//        kEventTypeFamily,           // 家人
//        kEventTypeFriend,           // 朋友
//        kEventTypeLove,             // 爱情
//        kEventTypeSelf              // 自我
//    }kEventType;
    switch (type) {
        case kEventTypeTemporary:
            return [UIImage imageNamed:@"cell_schetype_temp"];
            break;
        case kEventTypeWork:
            return [UIImage imageNamed:@"cell_schetype_work"];
            break;
        case kEventTypeFamily:
            return [UIImage imageNamed:@"cell_schetype_family"];
            break;
        case kEventTypeFriend:
            return [UIImage imageNamed:@"cell_schetype_friend"];
            break;
        case kEventTypeLove:
            return [UIImage imageNamed:@"cell_schetype_love"];
            break;
        case kEventTypeSelf:
            return [UIImage imageNamed:@"cell_schetype_self"];
            break;
        default:
            return nil;
            break;
    }
}

+ (NSString *)dateStringWithOffset:(NSInteger)count{
    NSTimeInterval seconds = count * 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDate *targetDay;
    
    targetDay = [today dateByAddingTimeInterval: seconds];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    // 10 first characters of description is the calendar date:
    return [dateformatter stringFromDate:targetDay];
}
+ (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"yyyy-MM-dd";
    return [df stringFromDate:date];
}

+ (NSString *)stringWithDayTipsFromDate:(NSDate *)date{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyy-MM-dd";
    
    NSString* dateString =  [df stringFromDate:date];
    
    NSInteger tmp = [Utils isTodayOrTomorrowOrTDayAfTomorow:date];
    if (tmp == kToay) {
        dateString = [NSString stringWithFormat:@"今天 %@",dateString];
    }else if(tmp==kTomorrow){
        dateString = [NSString stringWithFormat:@"明天 %@",dateString];
    }else if(tmp==kTDayAfterTomorrow){
         dateString = [NSString stringWithFormat:@"后天 %@",dateString];
    }
    
    return dateString;
}

+ (NSString *)stringFromTime:(NSDate *)time{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"HH:mm";
    return [df stringFromDate:time];
}

+ (NSDate *)currentDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setTimeStyle: NSDateFormatterNoStyle];
    
    [df setDateStyle: NSDateFormatterMediumStyle];
    
    NSString *nowDateStr = [df stringFromDate:[NSDate date]];
    
    return [df dateFromString:nowDateStr];
}

+ (NSDate *)formatDateWithString:(NSString *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"yyyy-MM-dd";
    
    return [df dateFromString: date];
}

+ (NSDate *)currentTime{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setTimeStyle: NSDateFormatterMediumStyle];
    
    [df setDateStyle: NSDateFormatterNoStyle];
    
    NSString *nowDateStr = [df stringFromDate:[NSDate date]];
    
    return [df dateFromString:nowDateStr];
}
+ (NSDate *)currentTimeWithOffset:(NSInteger)offset{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setTimeStyle: NSDateFormatterMediumStyle];
    
    [df setDateStyle: NSDateFormatterNoStyle];
    
    NSString *nowDateStr = [df stringFromDate:[NSDate date]];
    
    return [[df dateFromString:nowDateStr] dateByAddingTimeInterval: 60 * offset];
}

+ (NSDate *)formatTimeWithString:(NSString *)time{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"HH:mm";
    
    return [df dateFromString: time];
}

+ (NSDate *)dateWithOffset:(NSInteger)offset{
    NSTimeInterval seconds = offset * 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setTimeStyle: NSDateFormatterNoStyle];
    
    [df setDateStyle: NSDateFormatterMediumStyle];
    
    NSString *nowDateStr = [df stringFromDate:[today dateByAddingTimeInterval: seconds]];
    
    return [df dateFromString:nowDateStr];
}

/**
 *  星期英文转中文
 *
 *  @param theWeek 星期英文
 *
 *  @return 星期中文
 */
+ (NSString *)cTransformFromE:(NSString *)theWeek{
    NSString *chinaStr;
//    if(theWeek){
//        if([theWeek isEqualToString:@"Monday"]){
//            chinaStr = @"星期一";
//        }else if([theWeek isEqualToString:@"Tuesday"]){
//            chinaStr = @"星期二";
//        }else if([theWeek isEqualToString:@"Wednesday"]){
//            chinaStr = @"星期三";
//        }else if([theWeek isEqualToString:@"Thursday"]){
//            chinaStr = @"星期四";
//        }else if([theWeek isEqualToString:@"Friday"]){
//            chinaStr = @"星期五";
//        }else if([theWeek isEqualToString:@"Saturday"]){
//            chinaStr = @"星期六";
//        }else if([theWeek isEqualToString:@"Sunday"]){
//            chinaStr = @"星期日";
//        }
//    }
    return theWeek;
}

@end
