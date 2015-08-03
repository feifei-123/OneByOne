//
//  NSDate+helper.h
//  OneByOne
//
//  Created by macbook on 15-5-17.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (helper)

+ (NSDate *)dateWithDay:(NSDate *)day time:(NSDate *)time;

+ (NSDate *)currentDate;

+ (NSDate *)formatDateWithString:(NSString *)date;

+ (NSDate *)currentTime;

+ (NSDate *)formatTimeWithString:(NSString *)time;

+ (NSDate *)dateWithOffset:(NSInteger)offset;

+ (NSString *)stringFromDate:(NSDate *)date;

+ (NSString *)stringFromTime:(NSDate *)time;
+ (NSDate *)currentTimeWithOffset:(NSInteger)offset;

+ (NSDate *)dateAndTimeFromString:(NSString *)date;

+ (NSString *)stringFromDateAndTime:(NSDate *)date;

+ (NSDate *)timeWithString:(NSString *)time offset:(NSInteger)offset;


//-------------------------------------------------
+(NSDate *)beginningOfMonth:(NSDate *)date;
+(NSMutableArray*)getAllDaysOfCalenderMounth:(NSDate*)date;
+ (NSDate *)dateWithStartDate:(NSDate*)date Offset:(NSInteger)offset;
-(BOOL)dateIsEqual:(NSDate*)date;
-(NSInteger)dayIntervalFrom:(NSDate*)date;
+(NSDate*)CutTime:(NSDate*)date;
+(NSDate*)combineDate:(NSDate*)date AndTime:(NSDate*)time;
+(NSDate*)dateCutTime;
@end
