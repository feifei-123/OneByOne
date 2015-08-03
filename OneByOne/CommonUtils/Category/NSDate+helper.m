//
//  NSDate+helper.m
//  OneByOne
//
//  Created by macbook on 15-5-17.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "NSDate+helper.h"

@implementation NSDate (helper)

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

+ (NSString *)stringFromTime:(NSDate *)time{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"HH:mm";
    return [df stringFromDate:time];
}

+ (NSString *)stringFromDateAndTime:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"yyyy-MM-dd HH:mm";
    return [df stringFromDate:date];
}

+ (NSDate *)dateAndTimeFromString:(NSString *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"yyyy-MM-dd HH:mm";
    
    NSDate *d = [df dateFromString:date];
    if (!d) {
        df.dateFormat  = @"yyyy-MM-dd";
        
        d = [df dateFromString:date];
    }
    return d;
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

+ (NSDate *)dateWithStartDate:(NSDate*)date Offset:(NSInteger)offset{
    
    NSTimeInterval seconds = offset * 24 * 60 * 60;
// 
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    
//    [df setTimeStyle: NSDateFormatterNoStyle];
//    
//    [df setDateStyle: NSDateFormatterMediumStyle];
//    
    //NSString *nowDateStr = [df stringFromDate:[date dateByAddingTimeInterval: seconds]];

    NSDate* tmp = [date dateByAddingTimeInterval: seconds];
    return tmp ;
}

+ (NSDate *)timeWithString:(NSString *)time offset:(NSInteger)offset{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"HH:mm";
    NSDate *t = [df dateFromString: time];
    
    return [t dateByAddingTimeInterval:offset];
}

+ (NSDate *)timeWithDate:(NSDate *)time offset:(NSInteger)offset{
    
    return [time dateByAddingTimeInterval:offset];
}

/*
 *计算 距离某个日期date, offset天 的日期
 *参数：date－基准日期.
 *     offset相对于基准日期的偏移量.
 *返回值：计算所得的日期.
 *added by baixuefei  2015_05_26
 */
+ (NSDate *)dateWithOffset:(NSInteger)offset withDate:(NSDate*)date{
    
    NSTimeInterval seconds = offset * 24 * 60 * 60;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle: NSDateFormatterNoStyle];
    [df setDateStyle: NSDateFormatterMediumStyle];
    
    NSString *nowDateStr = [df stringFromDate:[date dateByAddingTimeInterval: seconds]];
    
    return [df dateFromString:nowDateStr];
}

/*
 *获得一个月的第一天
 *参数：date－该日期 所在的月 为计算的月份
 *返回值：date所在月份的第一天
 *added by baixuefei  2015_05_26
 */
+(NSDate *)beginningOfMonth:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsCurrentDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:date];
    
    NSDateComponents *componentsNewDate = [NSDateComponents new];
    
    componentsNewDate.year = componentsCurrentDate.year;
    componentsNewDate.month = componentsCurrentDate.month;
    componentsNewDate.weekOfMonth = 1;
    componentsNewDate.weekday = calendar.firstWeekday;
    NSDate*beginningdate=[calendar dateFromComponents:componentsNewDate];
    NSLog(@"begginingDate:%@",beginningdate);
    return beginningdate;
}

+(NSMutableArray*)getAllDaysOfCalenderMounth:(NSDate*)date{

    NSMutableArray*result = [[NSMutableArray alloc]init];
    
    if (date ==nil) {
        return result;
    }
    
     NSDate * firstDate =[NSDate beginningOfMonth:date];
    
    for (int i=0; i<42; i++) {
        NSDate* tmpDate = [NSDate dateWithOffset:i+1 withDate:firstDate];
        [result addObject:tmpDate];
    }
    
    return result;
}

/*
 *判断两天是否是同一天
 *参数：date－要比较的日期
 *返回值：true:相等;false:不相等.
 *added by baixuefei  2015_07_01
 */
-(BOOL)dateIsEqual:(NSDate*)date{


    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *componentsSelf = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    
    if (date==nil) {
        NSLog(@"date was nil!!!!!");
    }
    
    if ((componentsSelf.year==componentsDate.year)&&(componentsSelf.month==componentsDate.month)&&(componentsDate.day==componentsSelf.day)) {
        return true;
    }else{
        return false;
    }
    
}

/**
 *去掉 将NSDate里面的十分秒信息 归零.
 *added by baixuefei  2015_07_019
 */
+(NSDate*)CutTime:(NSDate*)date{
    
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *componentsDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    componentsDate.hour = 0;
    componentsDate.minute = 0;
    componentsDate.second = 0;
    
    NSDate* newDate=[calendar dateFromComponents:componentsDate];

    return newDate;
}

/*
 *将第一个NSDate（date）的日期和第二个NSDate (time)的时间 进行合成，生成一个新的NSDate；
 *added by baixuefei  2015_07_019
 */
+(NSDate*)combineDate:(NSDate*)date AndTime:(NSDate*)time{
    
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *componentsDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    NSDateComponents * componentsTime = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:time];
    if (componentsTime!=nil) {
       
        componentsDate.hour = componentsTime.hour;
        componentsDate.minute = componentsTime.minute;
        componentsDate.second = componentsTime.second;
   
    }else{
    
        componentsDate.hour = 0;
        componentsDate.minute = 0;
        componentsDate.second = 0;
    }
    
    NSDate* newDate=[calendar dateFromComponents:componentsDate];
    //NSLog(@"-------:%@",newDate);
    return newDate;
}

/*
 *产生 当天日期，不携带时间信息
 */
+(NSDate*)dateCutTime{
    return [NSDate CutTime:[NSDate date]];
}
/*
 *计算 距离 date 间隔的天数.
 *参数：date－要计算的日期
 *返回值：天数,可正 可负
 *added by baixuefei  2015_07_01
 */
-(NSInteger)dayIntervalFrom:(NSDate*)date{
    
    NSInteger seconds = [date timeIntervalSinceDate:self];
    NSInteger day =  ceilf(seconds/24.0/60.0/60.0);
    return day;
}


+ (NSDate *)dateWithDay:(NSDate *)day time:(NSDate *)time{
    NSString *dayStr = [NSDate stringFromDate:day];
    NSString *timeStr = [NSDate stringFromTime:time];
    if (!timeStr) {
        timeStr = @"";
    }
    else{
        timeStr = [NSString stringWithFormat:@" %@",timeStr];
    }
    return [NSDate dateAndTimeFromString:[NSString stringWithFormat:@"%@%@",dayStr,timeStr]];
}

@end
