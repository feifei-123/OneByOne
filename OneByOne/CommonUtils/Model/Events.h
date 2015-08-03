//
//  Events.h
//  OneByOne
//
//  Created by macbook on 15-5-12.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>


@interface Events : NSObject <NSMutableCopying>

//
@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSDate * startTime;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * type;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;
@property (nonatomic, strong) NSDate * endTime;
@property (nonatomic, strong) NSNumber * remind;
@property (nonatomic, strong) NSNumber * remindCount;
@property (nonatomic, strong) NSNumber * repeat;
@property (nonatomic, strong) NSNumber * state;
// 日程还是事件
@property (nonatomic, strong) NSNumber *classify;
// 处理时间
@property (nonatomic, strong) NSDate *updateStateTime;
//@property (nonatomic, strong) NSDate *insertStamp;
@property (nonatomic, strong) NSDate *timeStamp;
// 调整到
@property (nonatomic, strong) NSNumber *adjustTo;
@property (nonatomic, strong) Events *adjustToEvent;
// 被调整
@property (nonatomic, strong) NSNumber *isAdjustdBy;
@property (nonatomic, strong) Events *isAdjustdByEvent;

//判断两个事件是否相等。
- (BOOL)isEqualToEvent:(Events *)event;
//将事件进行初始化
//- (void)evaluateWithEvent:(Events *)event;

- (NSString *)existFilterString;

- (NSString *)insertString;

+(Events*)copyEvents:(Events*)model;
@end
