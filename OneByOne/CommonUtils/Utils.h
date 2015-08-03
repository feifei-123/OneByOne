//
//  Utils.h
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "OBOStringTools.h"

@interface Utils : NSObject
+(AppDelegate*)getDelegate;
+(NSArray*)getSchTypeArray;
+(NSString*)convertSchTypeID2String:(NSInteger)schType;
+(NSArray*)getSchRemindTypeArray;
+(NSString*)convertSchRemindID2String:(NSInteger)schRemindType;
+(NSArray*)getSchRepeatTypeArray;
+(NSString*)convertSchRepeatTypeID2String:(NSInteger)schRepeatType;

//判断日期 是今天 明天 后天
+(NSInteger)isTodayOrTomorrowOrTDayAfTomorow:(NSDate*)date;
//将日期字符串 转换成NSDate
+(NSDate*)convertString2Date:(NSString*)dateStr;
//将NSDate 转换成 日期字符串
+(NSString*)convertDate2String:(NSDate*)date;
+(UIImage*)getSchTypeImage:(kEventType)type;
//获得设备型号！
+(NSString*)getDeviceType;
@end
