//
//  OBOEventDateListModel.m
//  OneByOne
//
//  Created by macbook on 15-5-8.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOEventDateListModel.h"
#import "OBOEventModel.h"
//#import "OBOEventFrameModel.h"
#import "Events.h"
#import "OBOArrayTools.h"
#import "Constants.h"
#import "NSDate+helper.h"

@implementation OBOEventDateListModel

-(instancetype)init{
    
    self = [super init];
    if (self) {
        
        self.isShow = YES;
    }
    
    return self;
}

- (NSMutableArray *)eventList{
    if (_eventList == nil) {
        _eventList = [[NSMutableArray alloc]init];
    }
    return _eventList;
}

//- (void)eventListWithArray:(NSMutableArray *)array{
//    for (OBOEventFrameModel *frame in array) {
//        if ([frame.event.startDate isEqualToString:self.date]) {
//            [self.eventList addObject:frame];
////            [array removeObject:frame];
//        }
//    }
//}

/*
- (void)eventListWithSortedArray:(NSMutableArray *)sortedArray{
    int i = 0;
    Events *firstEvent = [sortedArray objectAtIndex:0];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"YYYY-MM-dd";
    self.date = [df stringFromDate:firstEvent.startDate];
    
 
    for (Events *event in sortedArray) {
        if ([event.startDate isEqualToDate:firstEvent.startDate]) {

             OBOEventFrameModel *frame = [[OBOEventFrameModel alloc]init];
             frame.event = event;
             [self.eventList addObject:frame];
 
            i++;
        }
    }
 
     NSRange range = NSMakeRange(0, i);
    [sortedArray removeObjectsInRange:range];
}
*/

/* 该函数 负责 sortedArray,提取出同一日期的日程，并将其封装成OBOEventFrameModel，保存
 *OBOEventDateListModel.eventList中。
 *要求:sortedArray 必须是排过序的
 *参数：sortedArray－排序后的数组
 *     format：YES－将event进行日程和事件按照特定格式（事件排到第二位）混排，NO－不区分日程和事件的固定排列格式。
 */
- (void)eventListWithSortedArray:(NSMutableArray *)sortedArray withFormat:(BOOL)format{
    int i = 0;
    Events *firstEvent = [sortedArray objectAtIndex:0];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"YYYY-MM-dd";
    self.date = [df stringFromDate:firstEvent.startDate];
    
    NSMutableArray*tmpEventsArray = [[NSMutableArray alloc]init];
    
    for (Events *event in sortedArray) {
        if ([event.startDate isEqualToDate:firstEvent.startDate]) {
            
            [tmpEventsArray addObject:event];
            i++;
        }
        
    }
    
    if (format) {
        //将tmpEventsArray 进行日程和事件的 混合排序.
        [OBOArrayTools sortScheduleAndEvents:tmpEventsArray];
    }
    
    //将event进行封装，组装成OBOEventFrameModel.
    for (Events*event in tmpEventsArray) {
        [self.eventList addObject:event];
    }
    
    NSRange range = NSMakeRange(0, i);
    [sortedArray removeObjectsInRange:range];
}

/*
 *对一个存在的OBOEventDateListModel重新 对events进行梳理。将日程和事件进行混合排序。
 * 参数：format-YES:日程和事件进行混合排序,format-NO :日程和事件进行混合排序不进行混合排序.
 */

-(void)sortSelfEventListWithFormat:(BOOL)format{

    //提取出原始的events数组
    NSMutableArray*orignEvents = [[NSMutableArray alloc]init];
    for (Events* event in self.eventList) {
        [orignEvents addObject:event];
    }
    
    //晴空eventList
    [self.eventList removeAllObjects];
    
    //重新组装 eventList
    [OBOArrayTools sortArrayByDateTime:orignEvents ascending:NO];
    
    [self eventListWithSortedArray:orignEvents withFormat:format];
}

+(OBOEventDateListModel*)createNoScheduleModel:(NSDate*)date{
    
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    
    Events* e = [[Events alloc]init];
    e.classify =  @(kEventClassifyNone);
    [arr addObject:e];
    
    OBOEventDateListModel*dateListModel = [[OBOEventDateListModel alloc]init];
    dateListModel.eventList = arr;
    dateListModel.date = [NSDate stringFromDate:date];
    
    return  dateListModel;
}

@end
