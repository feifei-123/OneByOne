//
//  OBODataBase.m
//  OneByOne
//
//  Created by macbook on 15-5-7.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBODataBase.h"
#import "OBOEventDateListModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "NSDate+helper.h"
#import "Events.h"


static OBODataBase *_sharedManager = nil;

@implementation OBODataBase

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (NSString *)dataBasePath:(NSString *)dbName
{
    BOOL success;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *writableDBPath=[documentsDirectory stringByAppendingPathComponent:dbName];
    NSLog(@"%@",writableDBPath);
    

    /*
     success=[fileManager fileExistsAtPath:writableDBPath];
     if (success) {
     [fileManager removeItemAtPath:writableDBPath error:&error];
     }
    */
    
    success=[fileManager fileExistsAtPath:writableDBPath];

    if(!success)
    {
        NSString *defaultDBPath=[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:dbName];
        success=[fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if(!success)
        {
            NSLog(@"%@",[error localizedDescription]);
            return nil;
        }
    }
    
   /*
    NSString *defaultDBPath=[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:dbName];
    [fileManager removeItemAtPath:defaultDBPath error:&error];
    success=[fileManager copyItemAtPath:writableDBPath toPath:defaultDBPath error:&error];
    if(!success)
    {
        NSLog(@"%@",[error localizedDescription]);
        return nil;
    }
    */
    return writableDBPath;
}

- (instancetype)init{
    self = [super init];
    if (self)
    {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self dataBasePath:@"Events.sqlite"]];
    }
    return  self;
}

- (Events *)rsToEvent:(FMResultSet*)rs
{
    Events *event = [[Events alloc] init];
    event.ID = @([rs intForColumn:@"_id"]);
    event.startTime = [NSDate formatTimeWithString:[rs stringForColumn:@"startTime"]];
    event.title = [rs stringForColumn:@"title"];
    event.type = @([rs intForColumn:@"type"]);
    event.content = [rs stringForColumn:@"content"];
    event.startDate = [NSDate formatDateWithString:[rs stringForColumn:@"startDate"]];
//    event.endDate = [NSDate dateWithTimeIntervalSince1970:[rs longForColumn:@"endDate"]];
    event.endDate = [NSDate formatDateWithString:[rs stringForColumn:@"endDate"]];
    event.endTime = [NSDate formatTimeWithString:[rs stringForColumn:@"endTime"]];
    event.remind = @([rs intForColumn:@"remind"]);
    event.repeat = @([rs intForColumn:@"repeat"]);
    event.state = @([rs intForColumn:@"state"]);
    event.adjustTo = @([rs intForColumn:@"adjustTo"]);
    event.isAdjustdBy = @([rs intForColumn:@"isAdjustdBy"]);
    event.classify = @([rs intForColumn:@"classify"]);
    event.updateStateTime = [NSDate dateAndTimeFromString:[rs stringForColumn:@"updateStateTime"]];
    event.timeStamp = [NSDate dateAndTimeFromString:[rs stringForColumn:@"timeStamp"]];
    event.remindCount = @([rs intForColumn:@"remindCount"]);
    return event;
}

// 添加数据
// 每次插入adjustTo和isAdjustdBy必须是0
- (void)insertEventWithEvent:(Events *)event result:(boolResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
#warning 是否需要查找是否含有相同的
        //
        NSString *sql = [NSString stringWithFormat:@"insert into Events %@",[event insertString]];
        //        NSString *str;
        
        NSLog(@"sql:---------%@",sql);
        [db executeUpdate:sql];
      
        
        event.ID = @([db lastInsertRowId]);
        
        
        if ([db hadError]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
                resultBlock(NO,0);
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(YES,0);
            });
        }
        [db close];
    }];
}

// 修改数据
- (void)updateEventWithEvent:(Events *)event result:(boolResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        
        NSString *sql = [NSString stringWithFormat:@"update Events set %@ where _id = '%d'",[event existFilterString],event.ID.intValue];
        //        NSString *str;
        
        [db executeUpdate:sql];
        
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(NO,0);
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(YES,0);
            });
        }
        [db close];
    }];
}

- (void)updateEventWithArray:(NSArray *)eventArray state:(kEventState)state result:(boolResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        
        for (Events *event in eventArray) {
            NSString *sql;
            if (state == kEventStateNone) {
                sql = [NSString stringWithFormat:@"update Events set %@ where _id = '%d'",[event existFilterString],event.ID.intValue];
            }
            else{
                sql = [NSString stringWithFormat:@"update Events set state = '%d', updateStateTime = '%@' where _id = '%d'",state,[NSDate stringFromDateAndTime:event.updateStateTime],event.ID.intValue];
            }
            
            //        NSString *str;
            
            [db executeUpdate:sql];
        }
        
        
        if ([db hadError]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
                resultBlock(NO,0);
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(YES,0);
            });
        }
        [db close];
    }];
}

/**
 *  支撑调整逻辑
 *
 *  @param event       需要调整的日程
 *  @param targetEvent 调整完成的日程
 *  @param resultBlock 返回结果
 */
- (void)adjustEventWithEvent:(Events *)event tartgetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        
        targetEvent.isAdjustdBy = event.ID;
        
        NSString *sql = [NSString stringWithFormat:@"insert into Events %@",[targetEvent insertString]];
        //        NSString *str;
        
        
        [db executeUpdate:sql];
        //[db commit];
        
        targetEvent.ID = @([db lastInsertRowId]);
        
        
        if ([db hadError]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
                resultBlock(NO,0);
            });
            [db close];
            return;
        }
        else{
            // 更新需要调整日程的状态
            event.adjustTo = targetEvent.ID;
            event.state = @(kEventStateAdjusted);
            NSString *sql = [NSString stringWithFormat:@"update Events set %@ where _id = '%d'",[event existFilterString],event.ID.intValue];
            //        NSString *str;
            
            [db executeUpdate:sql];
            
            
            if ([db hadError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Err %d: %@",[db lastErrorCode],[db lastErrorMessage]);
                    resultBlock(NO,0);
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    event.adjustToEvent = targetEvent;
                    resultBlock(YES,0);
                });
            }
        }
        [db close];
    }];
}

// 删除数据
- (void)removeEventWithEvent:(Events *)event result:(boolResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        NSString *sql;
        
        // 首先将删除与之对应的调整后的
//        event.isAdjustdBy
        if (event.adjustTo.intValue != 0) {
            sql = [NSString stringWithFormat:@"update Events set isAdjustdBy = '-1' where _id = '%d'",event.adjustTo.intValue];
            [db executeUpdate:sql];
            
            if ([db hadError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(NO,0);
                });
            }
            //return;
        }
        if (event.isAdjustdBy.intValue != 0) {
            sql = [NSString stringWithFormat:@"update Events set adjustTo = '0' where _id = '%d'",event.isAdjustdBy.intValue];
            [db executeUpdate:sql];
            
            if ([db hadError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(NO,0);
                });
            }
            //return;
        }
        //--------------------------
        sql = @"delete from Events ";
        //        NSString *str;
        
        if (event) {
            sql = [NSString stringWithFormat:@"%@ where _id = '%d'",sql,event.ID.intValue];
            //            str = [NSString stringWithFormat:@""]
        }
        
        [db executeUpdate:sql];
        
        if ([db hadError]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(NO,0);
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(YES,0);
            });
        }
        [db close];
    }];
}

// 查询数据
//+ (void)queryAllEventsByGroupWithResultList:(ListResult)resultBlock{
//    
//    [self queryEventsGroupByState:kEventStateNone byNow:NO resultList:resultBlock];
//}

//+ (void)queryEventsWithDate:(NSDate *)date state:(kEventState)state resultList:(ListResult)resultBlock{
//    
//    [Events async:^id(NSManagedObjectContext *ctx, NSString *className) {
//        
//        NSLog(@"当前先成为%@",[NSThread currentThread]);
//        NSPredicate *filter;
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
//        
//        if (state == kEventStateNone) {
//            filter = [NSPredicate predicateWithFormat:@"startDate = %@",date];
//        }
//        else{
//            filter = [NSPredicate predicateWithFormat:@"startDate = %@ and state = %d",date,state];
//        }
//        
//        //        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]]];
//        [request setPredicate:filter];
//        NSError *error;
//        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
//        //        Events *event = [dataArray objectAtIndex:0];
//        //        event.ob
//        if (error) {
//            return error;
//        }else{
//            return dataArray;
//        }
//        
//    } result:^(NSArray *result, NSError *error) {
//        resultBlock(result, error);
//    }];
//    
//}
- (void)queryEventsWithId:(NSNumber *)ID resultList:(EventResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"select * from Events where _id = '%d'",ID.intValue];
        
        FMResultSet *rs = [db executeQuery:sql];
        //        while ([rs next])
        //        {
        //            [users addObject:[self rsToUser :rs]];
        //        }
        Events *event;
        while ([rs next]) {
            event = [self rsToEvent:rs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(event);
        });
        //        [db lastInsertRowId];
        [db close];
    }];
}

/**
 *  根据状态分组查询所有的时间
 *
 *  @param state 事件的状态
 *  @param now   如果事件的状态为kEventStatePending，该参数有效，如果为yes查询当前时间之前的未处理事件，否则查询所有未处理事假
 *
 *  @return 查询结果集
 */
- (void)queryEventsWithDate:(NSDate *)date state:(kEventState)state byNow:(BOOL)now resultList:(ArrayResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        
        NSString *sql = @"select * from Events";
//        NSString *str;
        
        if (date) {
            if (now) {
                sql = [NSString stringWithFormat:@"%@ where startDate < '%@'",sql,[OBOStringTools stringFromDate:date]];
            }
            else{
                sql = [NSString stringWithFormat:@"%@ where startDate = '%@'",sql,[OBOStringTools stringFromDate:date]];
            }
            
//            str = [NSString stringWithFormat:@""]
        }
        if (state != kEventStateNone) {
            sql = [NSString stringWithFormat:@"%@ and state = '%d' order by startDate,startTime",sql,state];
        }
        
        FMResultSet *rs = [db executeQuery:sql];

//        NSMutableArray *result = [[NSMutableArray alloc]init];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        while ([rs next]) {
//            int ID = [rs intForColumn:@"_id"];
            [arr addObject:[self rsToEvent:rs]];
        }
        
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc]initWithKey:@"startDate" ascending:NO], nil];
//        [arr sortedArrayUsingDescriptors:sortDescriptors];
//        
//        
//        while (arr.count > 0) {
//            OBOEventDateListModel *eventDateList = [[OBOEventDateListModel alloc]init];
////            eventDateList.date = [rs stringForColumn:@"startDate"];
////            eventDateList.date = 
//            [eventDateList eventListWithSortedArray:arr];
//            [result addObject:eventDateList];
//        }
        [db close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self queryAdjustWithArray:arr resultList:^(NSArray *result) {
                resultBlock(result);
            }];
        });
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (int i = 0; i < arr.count; i++) {
//                Events *event1 = arr[i];
//                if (event1.isAdjustdBy.intValue != 0) {
//                    [self queryEventsWithId:event1.isAdjustdBy resultList:^(Events *event) {
//                        event1.isAdjustdByEvent = event;
//                        arr[i] = event1;
//                    }];
//                }
//                if (event1.adjustTo.intValue != 0) {
//                    [self queryEventsWithId:event1.isAdjustdBy resultList:^(Events *event) {
//                        event1.adjustToEvent = event;
//                        arr[i] = event1;
//                    }];
//                }
//            }
////            for (Events *event1 in arr) {
////                if (event1.isAdjustdBy.intValue != 0) {
////                    [self queryEventsWithId:event1.isAdjustdBy resultList:^(Events *event) {
////                        event1.isAdjustdByEvent = event;
////                    }];
////                }
////                if (event1.adjustTo.intValue != 0) {
////                    [self queryEventsWithId:event1.isAdjustdBy resultList:^(Events *event) {
////                        event1.adjustToEvent = event;
////                    }];
////                }
////            }
//            // 为了确保在所有查询完成之后返回结果
//            [self.dbQueue inDatabase:^(FMDatabase *db) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    resultBlock(arr);
//                });
//            }];
//        });
    }];

}

- (void)queryAdjustWithArray:(NSArray *)arr resultList:(ArrayResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        
        NSString *formatSql = @"select * from Events where _id = ";
        NSString *sql;
        FMResultSet *rs;
        NSMutableArray *result = [[NSMutableArray alloc]init];
        //        NSString *str;
        
        for (Events *event in arr) {
            // 查询调整日程
            if (event.adjustTo.intValue != 0) {
                sql = [NSString stringWithFormat:@"%@'%d'",formatSql,event.adjustTo.intValue];
                rs = [db executeQuery:sql];
                [rs next];
                event.adjustToEvent = [self rsToEvent:rs];
            }
            
            // 查询被调整日程
            if (event.isAdjustdBy.intValue != 0) {
                sql = [NSString stringWithFormat:@"%@'%d'",formatSql,event.isAdjustdBy.intValue];
                rs = [db executeQuery:sql];
                [rs next];
                event.isAdjustdByEvent = [self rsToEvent:rs];
            }
            [result addObject:event];
        }
//        if (state != kEventStateNone) {
//            sql = [NSString stringWithFormat:@"%@ and state = '%d'",sql,state];
//        }
        
        
        //        NSMutableArray *result = [[NSMutableArray alloc]init];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 为了确保在所有查询完成之后返回结果
            resultBlock(arr);
        });
    }];
}
/**
 *  根据时间状态排序方法分页查询
 *
 *  @param date        时间
 *  @param state       状态
 *  @param offset      偏移量
 *  @param limit       限制条数
 *  @param array       排序条件 property 属性例如：startTime sort排序方法例如：desc（降序）
 *  @param resultBlock 结果块
 */
- (void)queryEventsWithDate:(NSDate *)date state:(kEventState)state offset:(int)offset limit:(int)limit orderBy:(NSArray *)array resultList:(PageQueryResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        
        int total = 0;
        FMResultSet *rs = nil;
        NSString *sql = @"select COUNT(*) from Events";
        
        //        NSString *str;
        if (limit > 0) {
            if (date) {
                sql = [NSString stringWithFormat:@"%@ where startDate < '%@'",sql,[OBOStringTools stringFromDate:date]];
                
                //            str = [NSString stringWithFormat:@""]
            }
            sql = [NSString stringWithFormat:@"%@ and state = '%d'",sql,state];
            
            rs = [db executeQuery:sql];
            [rs next];
            total = [rs intForColumnIndex:0];
        }
        
        sql = @"select * from Events";
        
        //        NSString *str;
        
        if (date) {
            sql = [NSString stringWithFormat:@"%@ where startDate < '%@'",sql,[OBOStringTools stringFromDate:date]];
            
            //            str = [NSString stringWithFormat:@""]
        }
        sql = [NSString stringWithFormat:@"%@ and state = '%d' ",sql,state];
        
        if (array != nil) {
            
            for (int i = 0; i < array.count; i++) {
                NSDictionary *dict = array[i];
                NSString *property = dict[@"property"];
                NSString *sort = dict[@"sort"];
                if (i == 0) {
                    sql = [NSString stringWithFormat:@"%@ order by %@ %@",sql,property,sort];
                }
                else{
                    sql = [NSString stringWithFormat:@"%@ ,%@ %@",sql,property,sort];
                }
            }
        }
//        else{
//            sql = [NSString stringWithFormat:@"%@ order by startDate desc,startTime desc",sql];
//        }
        
        if (limit > 0) {
            sql = [NSString stringWithFormat:@"%@ limit %d offset %d",sql,limit,offset];
        }
        
        
        
        rs = [db executeQuery:sql];
        
        //        NSMutableArray *result = [[NSMutableArray alloc]init];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        
        // 查询数量结果
//        [rs next];
        
//        int total = [rs intForColumnIndex:0];
        // 查询结果
        while ([rs next]) {
//            total = [rs intForColumnIndex:0];
            [arr addObject:[self rsToEvent:rs]];
        }
        
        //        NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc]initWithKey:@"startDate" ascending:NO], nil];
        //        [arr sortedArrayUsingDescriptors:sortDescriptors];
        //
        //
        //        while (arr.count > 0) {
        //            OBOEventDateListModel *eventDateList = [[OBOEventDateListModel alloc]init];
        ////            eventDateList.date = [rs stringForColumn:@"startDate"];
        ////            eventDateList.date =
        //            [eventDateList eventListWithSortedArray:arr];
        //            [result addObject:eventDateList];
        //        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (Events *event1 in arr) {
                if (event1.isAdjustdBy.intValue != 0) {
                    [self queryEventsWithId:event1.isAdjustdBy resultList:^(Events *event) {
                        event1.isAdjustdByEvent = event;
                    }];
                }
                if (event1.adjustTo.intValue != 0) {
                    [self queryEventsWithId:event1.isAdjustdBy resultList:^(Events *event) {
                        event1.adjustToEvent = event;
                    }];
                }
            }
            // 为了确保在所有查询完成之后返回结果
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(arr,total);
                });
            }];
        });
        [db close];
    }];
    
}
//
//
/**
 *  查询给定日期之前最晚的未处理event
 *
 *  @param date        给定的日期
 *  @param resultBlock 返回结果的block
 */
- (void)queryLastEventBeforeDate:(NSDate *)date result:(EventResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"select MAX(startDate),MAX(startTime) from Events where startDate < '%@' and state = '%d'",[NSDate stringFromDate:date],kEventStatePending];
        
        FMResultSet *rs = [db executeQuery:sql];
        //        while ([rs next])
        //        {
        //            [users addObject:[self rsToUser :rs]];
        //        }
        Events *event;
        while ([rs next]) {
            event = [self rsToEvent:rs];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(event);
        });
        //        [db lastInsertRowId];
        [db close];
    }];
}

//
- (void)queryUntreatedEventNumBeforeTodayWithResultList:(NumResult)resultBlock{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db open]) {
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"select COUNT(*) from Events where startDate < '%@' and state = '%d'",[NSDate stringFromDate:[NSDate currentDate]],kEventStatePending];
        
        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next])
//        {
//            [users addObject:[self rsToUser :rs]];
//        }
        int count = 0;
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(count);
        });
//        [db lastInsertRowId];
        [db close];
    }];
}


/*查询某个日期的所有的行程，
 *
 *参数：date －查询的日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_05_21
 */
-(void)queryEventsWithDate:(NSDate*)date resultList:(ArrayResult)resultBolck{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        //(1)打开数据库
        if(![db open]){
            NSLog(@"queryEventsWithDate open Database failed!");
            return ;
        }
        //(2)执行数据库查询操作
        
        NSString*sql = @"select * from Events ";
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" where startDate ='%@'",[OBOStringTools stringFromDate:date]]];
        NSLog(@"%@",sql);
    
        NSMutableArray * result = [[NSMutableArray alloc]init];
        
       FMResultSet *rs = [db executeQuery:sql];
        while([rs next]) {
            
            Events*event=[self rsToEvent:rs];
            [result addObject:event];
            
        }
        
        [db close];
        resultBolck(result);
        
        //(3)关闭数据
        
    }];
}

/*模糊搜索 所有相关的行程，
 *
 *参数：keyWords －查询的关键字，模糊匹配 标题和内容
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_05_21
 */
-(void)queryAllEventsWithSearchKeywords:(NSString*)keyWords ResultList:(ArrayResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase*db){
        
        //(1)打开数据库
        if (![db open]) {

            NSLog(@"queryAllEventsWithSearchKeywords  open DataBase failed!");
            return ;
        }
        
        //(2)查询数据
        
        NSString* searchKeywords = [NSString stringWithFormat:@"%@%@%@",@"%",keyWords,@"%"];
        NSString* sql = @"select * from Events";
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" where title like '%@'or content like '%@'",searchKeywords,searchKeywords]];
        NSLog(@"%@",sql);
        
        FMResultSet* rs = [db executeQuery:sql];
        
        NSMutableArray*result = [[NSMutableArray alloc]init];
        
        while ([rs next]) {
            Events*event = [self rsToEvent:rs];
            [result addObject:event];
        }
        
        //(3)处理数据
        resultBlock(result);
        
        
        //(4)关闭数据库
        [db close];
        
       
        
    }];
    
}


/*查询某个日期之后的 所有日程，
 *
 *参数：date －查询的起始日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_05_21
 */
-(void)queryAllEventsAfterDate:(NSDate*)date ResultList:(ArrayResult)resultBlock{

    [self.dbQueue inDatabase:^(FMDatabase*db){
       
        //(1)打开数据库
        if (![db open]) {
            NSLog(@"queryAllEventsAfterDate open dataBase Failed!");
            return ;
        }
        
        //(2)查询数据库
        NSString*sql = @"select * from Events ";
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"where startDate>='%@'",[OBOStringTools stringFromDate:date]]];
        NSLog(@"sql:--------%@",sql);
        
        FMResultSet * rs = [db executeQuery:sql];
        
        NSMutableArray*result = [[NSMutableArray alloc]init];
        
        while ([rs next]) {
            
            Events* event = [self rsToEvent:rs];
            [result addObject:event];
            
        }
        
        
        //(3)处理数据
        resultBlock(result);
        
        //(4)关闭数据库
        [db close];
        
    }];

}

/*查询date之后所有数据,以及date之前的 从offet 开始的，limit条 日程记录.
 *
 *参数：date －查询的日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_06_07
 */
-(void)queryEventsAroundDate:(NSDate*)date AheadOffset:(NSNumber*)offset Limit:(NSNumber*)limit ResultList:(ArrayResult)resultBlock{
    
    
    [self.dbQueue inDatabase:^(FMDatabase*db){
        
        //(1)打开数据库
        if (![db open]) {
            NSLog(@"queryEventsBeforeDate open database failed!");
            return ;
        }
        
        //(2)查询数据
        
        //查询 date 日期之后的所有数据.
        NSString * sql = @"select * from Events ";
        sql = [NSString stringWithFormat:@"%@ where startDate>='%@' order by startDate asc,startTime asc,timeStamp asc",sql,[OBOStringTools stringFromDate:date]];
        
        NSLog(@"%@",sql);
        FMResultSet* rs = [db executeQuery:sql];
        
        NSMutableArray * result = [[NSMutableArray alloc]init];
        while ([rs next]) {
            Events*event = [self rsToEvent:rs];
            [result addObject:event];
        }
        
        //查询 date 日期之前 的“一页” 的所有数据.
        sql = @"select * from Events ";
        sql = [NSString stringWithFormat:@"%@ where startDate<'%@' order by startDate desc,startTime desc,timeStamp desc",sql,[OBOStringTools stringFromDate:date]];
        sql = [NSString stringWithFormat:@"%@ limit %d offset %d ",sql,limit.intValue,offset.intValue];
        
        NSLog(@"%@",sql);
        rs = [db executeQuery:sql];
        while ([rs next]) {
            Events *event = [self rsToEvent:rs];
            [result insertObject:event atIndex:0];
        }
        
        [rs close];
        
        //(3)处理数据
        resultBlock(result);
        
        //(4)关闭数据库
        [db close];
        
    }];
    
}


/*查询startDate 在date_1和date_2之间的所有日程。
 *
 *参数：date_1和date_2  查询的日期区间为 [date_1  date_2)－左闭右开
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_06_30
 */
-(void)queryEventsWithDate1:(NSDate*)date_1 Date2:(NSDate*)date_2 ResultList:(ArrayResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase *db){
        
        //(1)打开数据库
        if (![db open]) {
            NSLog(@"%s open database failed!",__func__);
        }
        
        //(2)查询数据库
        NSString * sql = @"select * from Events ";
        sql = [NSString stringWithFormat:@"%@ where startDate>='%@' and startDate<'%@'",sql,[OBOStringTools stringFromDate:date_1],[OBOStringTools stringFromDate:date_2]];
        
        sql = [NSString stringWithFormat:@"%@ order by startDate asc,startTime asc,timeStamp asc ",sql];
        
        NSLog(@"sql-------:%@",sql);
        
        
        NSMutableArray * result = [[NSMutableArray alloc]init];
        FMResultSet*rs = [db executeQuery:sql];
        
        while ([rs next]) {
            Events *event = [self rsToEvent:rs];
            [result addObject:event];
        }
        
        
        //(3)关闭数据库
        [db close];
        
        //(4)处理数据
        resultBlock(result);
        
    }];
    
    
    
}




/*查询date日期“之后”或 “之前” 的  dayLimit天的所有日程
 *
 *参数：date －查询开始日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_06_30
 */
-(void)queryEventsWithDate:(NSDate*)date Direction:(Direction)direct dayLimit:(NSNumber*)daylimit ResultList:(ArrayResult)resultBlock{
 
    
    NSDate * date_left ;
    NSDate * date_right;
    
    if (direct==Before) {
        date_left = [NSDate dateWithStartDate:date Offset:-(daylimit.intValue)];
        date_right = date;
    }else{
        date_left = date;
        date_right = [NSDate dateWithStartDate:date Offset:daylimit.intValue];
    }
    
     [self queryEventsWithDate1:date_left Date2:date_right ResultList:resultBlock];
}

/*查询startdate日期之后的  dayLimit天的所有日程
 *
 *参数：startdate －查询开始日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_06_30
 */
//-(void)queryEventsAfterDate:(NSDate*)startdate dayLimit:(NSNumber*)daylimit ResultList:(ArrayResult)resultBlock{
//    
//    NSDate * date_left = startdate;
//    NSDate * date_right = [NSDate dateWithStartDate:startdate Offset:daylimit.intValue];
//    
//    [self queryEventsWithDate1:date_left Date2:date_right ResultList:resultBlock];
//    
////    [self.dbQueue inDatabase:^(FMDatabase *db){
////        
////        //(1)打开数据库
////        if (![db open]) {
////            NSLog(@"%s open database failed!",__func__);
////        }
////        
////        //(2)查询数据库
////        NSString * sql = @"select * from Events ";
////        sql = [NSString stringWithFormat:@"%@ where startDate>='%@' and startDate<'%@'",sql,[OBOStringTools stringFromDate:date_left],[OBOStringTools stringFromDate:date_right]];
////        
////        sql = [NSString stringWithFormat:@"%@ order by startDate desc,startTime desc,timeStamp desc ",sql];
////        
////        NSLog(@"sql-------:%@",sql);
////        
////        
////        NSMutableArray * result = [[NSMutableArray alloc]init];
////        FMResultSet*rs = [db executeQuery:sql];
////        
////        while ([rs next]) {
////            Events *event = [self rsToEvent:rs];
////            [result addObject:event];
////        }
////        
////        
////        //(3)关闭数据库
////        [db close];
////        
////        //(4)处理数据
////        resultBlock(result);
////        
////    }];
//    
//    
//    
//}
//
//
///*查询startdate日期之前的  dayLimit天的所有日程
//*
//*参数：startdate －查询开始日期
//*     resultBolck - 返回查询结果的block.
//*返回值：无
//*
//*added by baixuefei   2015_06_30
//*/
//-(void)queryEventsBeforeDate:(NSDate*)startdate dayLimit:(NSNumber*)daylimit ResultList:(ArrayResult)resultBlock{
//    
//    NSDate * date_right = startdate;
//    NSDate * date_left = [NSDate dateWithStartDate:startdate Offset:-(daylimit.intValue)];
//    
//    [self queryEventsWithDate1:date_left Date2:date_right ResultList:resultBlock];
//    
////    [self.dbQueue inDatabase:^(FMDatabase *db){
////        
////        //(1)打开数据库
////        if (![db open]) {
////            NSLog(@"%s open database failed!",__func__);
////        }
////        
////        //(2)查询数据库
////        NSString * sql = @"select * from Events ";
////        sql = [NSString stringWithFormat:@"%@ where startDate>='%@' and startDate<'%@'",sql,[OBOStringTools stringFromDate:date_left],[OBOStringTools stringFromDate:date_right]];
////        
////        sql = [NSString stringWithFormat:@"%@ order by startDate desc,startTime desc,timeStamp desc ",sql];
////        
////        NSLog(@"sql-------:%@",sql);
////        
////        
////        NSMutableArray * result = [[NSMutableArray alloc]init];
////        FMResultSet*rs = [db executeQuery:sql];
////        
////        while ([rs next]) {
////            Events *event = [self rsToEvent:rs];
////            [result addObject:event];
////        }
////        
////        
////        //(3)关闭数据库
////        [db close];
////        
////        //(4)处理数据
////        resultBlock(result);
////        
////    }];
//    
//    
//    
//}


/*查询某个日期之前的 从offet 开始的，limit条 日程记录，
 *
 *参数：date －查询的截止日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_05_22
 */
-(void)queryEventsBeforeDate:(NSDate*)date offset:(NSNumber*)offset Limit:(NSNumber*)limit ResultList:(PageQueryResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase*db){
    
       //(1)打开数据库
        if (![db open]) {
            NSLog(@"queryEventsBeforeDate open database failed!");
            return ;
        }
        
       //(2)查询数据库
        
        int total = 0;
        NSString*sql = [NSString stringWithFormat:@"select count(*) from Events where startDate<'%@'",[OBOStringTools stringFromDate:date]];
        NSLog(@"%@",sql);
        FMResultSet*rs = [db executeQuery:sql];
        
        while ([rs next]) {
            total = [rs intForColumnIndex:0];
        }
        
        
        sql = @"select * from Events ";
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"where startDate<'%@' order by startDate desc,startTime desc,timeStamp desc",[OBOStringTools stringFromDate:date]]];

        sql = [NSString stringWithFormat:@"%@ limit %d offset %d ",sql,limit.intValue,offset.intValue];
        
        NSLog(@"%@",sql);
        
        rs = [db executeQuery:sql];
       
        NSMutableArray * result = [[NSMutableArray alloc]init];
        while ([rs next]) {
            Events*event = [self rsToEvent:rs];
            [result addObject:event];
        }
        
        //(3)处理数据
        resultBlock(result,total);
        
        //(4)关闭数据库
        [db close];
        
    }];
}


/*
 *查询日历中，某个月份页面中，所涉及到的事件.
 *
 *参数：date －查询的日期
 *     resultBolck - 返回查询结果的block.
 *返回值：无
 *
 *added by baixuefei   2015_05_22
 */
-(void)queryAllCalenderEventsWithDateArray:(NSArray*)dateArray ResultList:(DicResult)resultBlock{
    
    [self.dbQueue inDatabase:^(FMDatabase *db){
        
        //(1）打开数据库
        if (![db open]) {
            NSLog(@"%s open datebase failure!",__func__);
            return ;
        }
        
        //(2)查询操作
        
        NSMutableDictionary* dicResult=[[NSMutableDictionary alloc]init];
        
        for (NSDate*date in dateArray) {
            
            NSString *sql = @"select count(*) from Events ";
            sql = [NSString stringWithFormat:@"%@where startDate='%@'",sql,[OBOStringTools stringFromDate:date]];
            NSLog(@"sql:%@",sql);
            
            FMResultSet* rs =  [db executeQuery:sql];
            
            int count = 0;
            while ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
            
            [dicResult setValue:@(count) forKey:[OBOStringTools stringFromDate:date]];
            
        }
        
        //(3)关闭数据库
        [db close];
        
        //(4)数据处理
        resultBlock(dicResult);
        
    }];
    
}














//    [Events async:^id(NSManagedObjectContext *ctx, NSString *className) {
//        NSLog(@"当前先成为%@",[NSThread currentThread]);
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
//        NSPredicate *filter = [NSPredicate predicateWithFormat:@"state = %d AND startDate < %@",kEventStatePending,[OBOStringTools currentDate]];
//#warning 当前时间加1到2秒防止查询延迟出现结果不准确效果
//        [request setPredicate:filter];
//        [request setResultType:NSCountResultType];
//        NSError *error;
//        NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
//        NSNumber *num = [dataArray objectAtIndex:0];
//        return num;
//    } result:^(NSArray *result, NSError *error) {
//        resultBlock(result, error);
//    }];
//}
//
//- (NSArray *)queryAllEvents{
//    
//    return [self queryEventsWithString:@"select * from Events"];
//}
//
//+ (NSArray *)queryEventsWithDate:(NSString *)date{
//    
//    NSString *sql = [NSString stringWithFormat:@"select * from Events where startDate = '%@'",date];
//    return [self queryEventsWithString:sql];
//}
//
//+ (NSArray *)queryEventsWithString:(NSString *)sql{
//    int i = 0;
//    NSMutableArray * arr = [[NSMutableArray alloc]init];
//    FMDatabase *db = [self readyDatabase:@"obo.sqlite"];
//    if (![db open]) {
//        return nil;
//    }
//    
//    FMResultSet *rs = [db executeQuery:sql];
////    NSDictionary *dict = [rs resultDictionary];
//    
//    while ([rs next]) {
//        OBOEventFrameModel *frameEvent = [[OBOEventFrameModel alloc]init];
//        OBOEventModel *event = [[OBOEventModel alloc]init];
//        event.type = [rs boolForColumn:@"type"];
//        event.title = [rs stringForColumn:@"title"];
//        event.content = [rs stringForColumn:@"content"];
//        event.startDate = [rs stringForColumn:@"startDate"];
//        event.startTime = [rs stringForColumn:@"startTime"];
//        event.endDate = [rs stringForColumn:@"endDate"];
//        event.endTime = [rs stringForColumn:@"endTime"];
//        event.isRemind = [rs boolForColumn:@"isRemind"];
//        event.isRepeat = [rs boolForColumn:@"isRepeat"];
//        event.state = [rs intForColumn:@"state"];
//        if (i == 0) {
//            event.isFirstCell = YES;
//        }
//        i++;
//        
//        frameEvent.event = event;
//        [arr addObject:frameEvent];
//    }
//    [db close];
//    return arr;
//}
//
//+ (NSArray *)queryEventsGroupWithString:(NSString *)sql groupString:(NSString *)sqlGroup{
//    
//    NSMutableArray *arr = [self queryEventsWithString:sql].mutableCopy;    // 查询所有的日程事件
//    
//    FMDatabase *db = [self readyDatabase:@"obo.sqlite"];
//    if (![db open]) {
//        return nil;
//    }
//    FMResultSet *rs = [db executeQuery:sqlGroup];
//    
//    NSMutableArray *result = [[NSMutableArray alloc]init];
//    while ([rs next]) {
//        OBOEventDateListModel *eventDateList = [[OBOEventDateListModel alloc]init];
//        eventDateList.date = [rs stringForColumn:@"startDate"];
//        [eventDateList eventListWithArray:arr];
//        [result addObject:eventDateList];
//    }
//    
//    [db close];
//    return result;
//}
//
//+ (BOOL)insertEventWithEvent:(OBOEventModel *)event{
//    FMDatabase *db = [self readyDatabase:@"obo.sqlite"];
//    if (![db open]) {
//        return nil;
//    }
//
//    NSString *sql = [NSString stringWithFormat:@"insert into Events (type, title, content, startDate, startTime, endDate, endTime, isRemind, isRepeat, state) values ('%ld', '%@', '%@', '%@', '%@', '%@', '%@', '%d', '%d', '%ld')",(long)event.type, event.title, event.content, event.startDate, event.startTime, event.endDate, event.endTime, event.isRemind, event.isRepeat, (long)event.state];
////    BOOL success = [db executeUpdate:@"insert into Events (type, title, content, startDate, startTime, endDate, endTime, isRemind, isRepeat, state) values (%ld, %@, %@, %@, %@, %@, %@, %d, %d, %ld)",(long)event.type, event.title, event.content, event.startDate, event.startTime, event.endDate, event.endTime, event.isRemind, event.isRepeat, (long)event.state];
//    BOOL success = [db executeUpdate:sql];
//    [db close];
//    return success;
//}
//
//+ (NSArray *)queryAllEventsByGroup{
////    NSString *sql = [NSString stringWithFormat:@"select startDate from Events group by startDate order by startDate desc"];
////    NSMutableArray *arr = [self queryAllEvents].mutableCopy;    // 查询所有的日程事件
////    
////    FMDatabase *db = [self readyDatabase:@"obo.sqlite"];
////    if (![db open]) {
////        return nil;
////    }
////    FMResultSet *rs = [db executeQuery:sql];
////    
////    NSMutableArray *result = [[NSMutableArray alloc]init];
////    while ([rs next]) {
////        OBOEventDateListModel *eventDateList = [[OBOEventDateListModel alloc]init];
////        eventDateList.date = [rs stringForColumn:@"startDate"];
////        [eventDateList eventListWithArray:arr];
////        [result addObject:eventDateList];
////    }
////    
////    [db close];
//    
//    return [self queryEventsGroupWithString:@"select * from Events" groupString:@"select startDate from Events group by startDate order by startDate desc"];
//}
//
//+ (NSArray *)queryEventsGroupByState:(kEventState)state{
//    
////    NSString *sql = [NSString stringWithFormat:@"select * from Events where state = '%d' grou",state];
////    FMDatabase *db = [self readyDatabase:@"obo.sqlite"];
////    if (![db open]) {
////        return nil;
////    }
////    FMResultSet *rs = [db executeQuery:sql];
////    NSMutableArray *result = [[NSMutableArray alloc]init];
////    while ([rs next]) {
////        OBOEventDateListModel *eventDateList = [[OBOEventDateListModel alloc]init];
////        eventDateList.date = [rs stringForColumn:@"startDate"];
//////        [eventDateList eventListWithArray:arr];
////        [result addObject:eventDateList];
////    }
////    
////    [db close];
////    return result;
//    NSString *sql = [NSString stringWithFormat:@"select * from Events where state = '%d' ",state];
//    NSString *sqlGroup = [NSString stringWithFormat:@"select startDate from Events where state = '%d' group by startDate order by startDate",state];
//    return [self queryEventsGroupWithString:sql groupString:sqlGroup];
//    
//}
//
//+ (NSInteger)queryUntreatedEventNum{
//    
//    int num = 0;
//    FMDatabase *db = [self readyDatabase:@"obo.sqlite"];
//    if (![db open]) {
//        return 0;
//    }
//    // 未处理并且开始时间在今天之前
//    NSString *sql = [NSString stringWithFormat:@"select COUNT(*) from Events where state = %d and startDate > %@", kEventStatePending, [OBOStringTools dateStringWithOffset:0]];
//    FMResultSet *rs = [db executeQuery:sql];
//    
//    while ([rs next]) {
//        num = [rs intForColumnIndex:0];
//    }
//    return num;
//}

@end
