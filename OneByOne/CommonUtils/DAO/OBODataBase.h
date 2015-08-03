//
//  OBODataBase.h
//  OneByOne
//
//  Created by macbook on 15-5-7.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBOStringTools.h"
#import "OBOCommonDelegate.h"
#import "Constants.h"

@class Events;
@class FMDatabaseQueue;

typedef void (^OperationResult) (NSError* error);

typedef void (^EventResult) (Events *event);
typedef void (^ArrayResult) (NSArray* result);
typedef void (^NumResult) (int num);
typedef void (^PageQueryResult) (NSArray* result, int total);
typedef void (^DicResult) (NSMutableDictionary* resutl);
//typedef id(^AsyncProcess)(NSManagedObjectContext *ctx, NSString *className);

@interface OBODataBase : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

+ (instancetype)sharedManager;

- (void)queryUntreatedEventNumBeforeTodayWithResultList:(NumResult)resultBlock;

- (void)queryEventsWithId:(NSNumber *)ID resultList:(EventResult)resultBlock;

- (void)queryEventsWithDate:(NSDate *)date state:(kEventState)state byNow:(BOOL)now resultList:(ArrayResult)resultBlock;

- (void)queryEventsWithDate:(NSDate *)date state:(kEventState)state offset:(int)offset limit:(int)limit orderBy:(NSArray *)array resultList:(PageQueryResult)resultBlock;

- (void)queryLastEventBeforeDate:(NSDate *)date result:(EventResult)resultBlock;

- (void)removeEventWithEvent:(Events *)event result:(boolResult)resultBlock;

- (void)updateEventWithEvent:(Events *)event result:(boolResult)resultBlock;

- (void)updateEventWithArray:(NSArray *)eventArray state:(kEventState)state result:(boolResult)resultBlock;

// 每次插入adjustTo和isAdjustdBy必须是0
- (void)insertEventWithEvent:(Events *)event result:(boolResult)resultBlock;

- (void)adjustEventWithEvent:(Events *)event tartgetEvent:(Events *)targetEvent result:(boolResult)resultBlock;

//----------------------------------------------------------------------------
- (void)queryEventsWithDate:(NSDate*)date resultList:(ArrayResult)resultBolck;

- (void)queryAllEventsWithSearchKeywords:(NSString*)keyWords ResultList:(ArrayResult)resultBlock;

- (void)queryAllEventsAfterDate:(NSDate*)date ResultList:(ArrayResult)resultBlock;

-(void)queryEventsBeforeDate:(NSDate*)date offset:(NSNumber*)offset Limit:(NSNumber*)limit ResultList:(PageQueryResult)resultBlock;

-(void)queryAllCalenderEventsWithDateArray:(NSArray*)dateArray ResultList:(DicResult)resultBlock;

-(void)queryEventsAroundDate:(NSDate*)date AheadOffset:(NSNumber*)offset Limit:(NSNumber*)limit ResultList:(ArrayResult)resultBlock;

-(void)queryEventsWithDate1:(NSDate*)date_1 Date2:(NSDate*)date_2 ResultList:(ArrayResult)resultBlock;
-(void)queryEventsWithDate:(NSDate*)date Direction:(Direction)direct dayLimit:(NSNumber*)daylimit ResultList:(ArrayResult)resultBlock;
/**
 *  查询所有日程
 *
 *  @return 所有日程的数组
 */
+ (NSArray *)queryAllEvents;
/**
 *  根据日期查询日程
 *
 *  @param date 时间字符串，格式xxxx-xx-xx
 *
 *  @return 日程的数组
 */
+ (NSArray *)queryEventsWithDate:(NSString *)date;
/**
 *  根据sql字符串查询日程
 *
 *  @param sql sql字符串
 *
 *  @return 日程的数组
 */
+ (NSArray *)queryEventsWithString:(NSString *)sql;
/**
 *  添加一条日程
 *
 *  @param event 日程的对象
 *
 *  @return 是否插入成功
 */
//+ (BOOL)insertEventWithEvent:(OBOEventModel *)event;

+ (NSArray *)queryAllEventsByGroup;

+ (NSArray *)queryEventsGroupByState:(kEventState)state;

+ (NSInteger)queryUntreatedEventNum;

@end
