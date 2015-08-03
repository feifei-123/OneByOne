//
//  Utils.m
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "Utils.h"
#import  "Constants.h"
#include <sys/sysctl.h>

@implementation Utils

+(AppDelegate*)getDelegate{
    return  (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

// 行程类型
+(NSArray*)getSchTypeArray{
    
    return [NSArray arrayWithObjects:@"临时",@"工作",@"家人",@"朋友",@"爱情",@"自我", nil];
}

+(UIImage*)getSchTypeImage:(kEventType)type{
    
    NSString*typeImage = @"";
    switch (type) {
        case kEventTypeTemporary:
            typeImage = @"cell_schetype_temp";
            break;
        case kEventTypeWork:
            typeImage = @"cell_schetype_work";
            break;
        case kEventTypeFamily:
            typeImage = @"cell_schetype_family";
            break;
        case kEventTypeFriend:
            typeImage = @"cell_schetype_friend";
            break;
        case kEventTypeLove:
            typeImage = @"cell_schetype_love";
            break;
        case kEventTypeSelf:
            typeImage = @"cell_schetype_self";
            break;
        default:
            typeImage = @"cell_schetype_temp";
            break;
    }
    UIImage* icon = [UIImage imageNamed:typeImage];
    return icon;
}

+(NSString*)convertSchTypeID2String:(NSInteger)schType{
    NSArray*array = [Utils getSchTypeArray];
    NSString* result = @"";
    if (schType>=0&&schType<[array count]) {
        result = [array objectAtIndex:schType];
    }else{
        NSLog(@"schType was wrong!");
    }
    return result;
}

//行程提醒类型
+(NSArray*)getSchRemindTypeArray{
    
    return [NSArray arrayWithObjects:@"无提醒",@"日程发生时",@"提前5分钟",@"提前15分钟",@"提前30分钟",@"提前1小时",@"提前2小时",@"提前1天",@"提前2天",@"提前1周", nil];
}


+(NSString*)convertSchRemindID2String:(NSInteger)schRemindType{
    NSArray*array = [Utils getSchRemindTypeArray];
    NSString* result = @"";
    if (schRemindType>=0&&schRemindType<[array count]) {
        result = [array objectAtIndex:schRemindType];
    }else{
        NSLog(@"schRemindTypeID was wrong!");
    }
    return result;
}


 //行程 重复 类型
+(NSArray*)getSchRepeatTypeArray{
    
    return [NSArray arrayWithObjects:@"从不重复",@"每天",@"工作日",@"每周",@"每月",@"每年", nil];
    
}

+(NSString*)convertSchRepeatTypeID2String:(NSInteger)schRepeatType{
    NSArray*array = [Utils getSchRepeatTypeArray];
    NSString* result = @"";
    if (schRepeatType>=0&&schRepeatType<[array count]) {
        result = [array objectAtIndex:schRepeatType];
    }else{
        NSLog(@"schType was wrong!");
    }
    return result;
}

+(NSInteger)isTodayOrTomorrowOrTDayAfTomorow:(NSDate*)date{
    NSDateComponents *today = [Utils convertDate2Components:[NSDate date]];
    NSDateComponents *toTestDate = [Utils convertDate2Components:date];
    
    NSInteger result = kOtherDays;
    
    if(toTestDate.year==today.year&&toTestDate.month==today.month){
        if(toTestDate.day==today.day){
            result = kToay;
        }else if(toTestDate.day == (today.day+1)){
            result = kTomorrow;
        }else if(toTestDate.day == (today.day+2)){
            result = kTDayAfterTomorrow;
        }else{
            result = kOtherDays;
        }
    }
   
    return result;
}

/**
 * 将NSDate对象转换成 NSDateComponents
 * add by feifei 
 * 2015_05_10
 */
+(NSDateComponents*)convertDate2Components:(NSDate*)date{

     NSDateComponents *components = [[NSCalendar currentCalendar]components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit
        fromDate:date];
    return components;
}

/**
 * 将NSDateStr对象转换成 NSDate对象
 * add by feifei
 * 2015_05_10
 */
+(NSDate*)convertString2Date:(NSString*)dateStr{
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [fmt dateFromString:dateStr];
   
    return date;
    
}

/**
 * 将NSDate对象转换成NSDateStr.
 * add by feifei
 * 2015_05_10
 */
+(NSString*)convertDate2String:(NSDate*)date{
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [fmt stringFromDate:date];
    
    return dateStr;
    
}


+(NSString*)getDeviceType{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    
    free(name);
    
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
    
}
@end
