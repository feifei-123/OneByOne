//
//  Events.m
//  OneByOne
//
//  Created by macbook on 15-5-12.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "Events.h"
#import "OBOStringTools.h"
#import "NSDate+helper.h"


@implementation Events

//@dynamic ID;
//@dynamic startTime;
//@dynamic title;
//@dynamic type;
//@dynamic content;
//@dynamic startDate;
//@dynamic endDate;
//@dynamic endTime;
//@dynamic remind;
//@dynamic repeat;
//@dynamic state;
//@dynamic adjustTo;
//@dynamic isAdjustdBy;



- (BOOL)isEqualToEvent:(Events *)event{
    return ([self.startTime isEqualToDate:event.startTime] &&
            [self.title isEqualToString:event.title] &&
            [self.type isEqualToNumber:event.type] &&
            [self.content isEqualToString:event.content] &&
            [self.startDate isEqualToDate:event.startDate] &&
            [self.endDate isEqualToDate:event.endDate] &&
            [self.endTime isEqualToDate:event.endTime] &&
            [self.remind isEqualToNumber:event.remind] &&
            [self.repeat isEqualToNumber:event.repeat] &&
            [self.state isEqualToNumber:event.state] &&
            [self.adjustTo isEqualToNumber:event.adjustTo] &&
            [self.isAdjustdBy isEqualToNumber:event.isAdjustdBy] &&
            [self.classify isEqualToNumber:event.classify] &&
            [self.updateStateTime isEqualToDate:event.updateStateTime] &&
            [self.timeStamp isEqualToDate:event.timeStamp] &&
            [self.remindCount isEqualToNumber:event.remindCount]);
}

- (NSString *)existFilterString{
//    @property (nonatomic, strong) NSNumber *adjustTo;
//    // 被调整
//    @property (nonatomic, strong) NSNumber *isAdjustdBy;
    return [NSString stringWithFormat:@"startTime = '%@' ,title = '%@', type = '%d', content = '%@', startDate = '%@', endDate = '%@', endTime = '%@', remind = '%d', repeat = '%d', state = '%d', adjustTo = '%d', isAdjustdBy = '%d', classify = '%d', updateStateTime = '%@', timeStamp = '%@', remindCount = '%d'",[OBOStringTools stringFromTime:self.startTime], self.title, self.type.intValue, self.content, [OBOStringTools stringFromDate:self.startDate], [OBOStringTools stringFromDate:self.endDate], [OBOStringTools stringFromTime:self.endTime],self.remind.intValue, self.repeat.intValue, self.state.intValue, self.adjustTo.intValue, self.isAdjustdBy.intValue, self.classify.intValue, [NSDate stringFromDateAndTime:self.updateStateTime], [NSDate stringFromDateAndTime:self.timeStamp], self.remindCount.intValue];
}

- (NSString *)insertString{
     return [NSString stringWithFormat:@"(startTime,title, type, content, startDate, endDate, endTime, remind, repeat, state, adjustTo, isAdjustdBy, classify, updateStateTime, timeStamp, remindCount) VALUES ('%@',  '%@', '%d', '%@', '%@', '%@', '%@', '%d', '%d', '%d', '%d', '%d', '%d', '%@', '%@', '%d')",[OBOStringTools stringFromTime:self.startTime], self.title, self.type.intValue, self.content, [OBOStringTools stringFromDate:self.startDate], [OBOStringTools stringFromDate:self.endDate], [OBOStringTools stringFromTime:self.endTime],self.remind.intValue, self.repeat.intValue, self.state.intValue, self.adjustTo.intValue, self.isAdjustdBy.intValue, self.classify.intValue, [NSDate stringFromDateAndTime:self.updateStateTime], [NSDate stringFromDateAndTime:self.timeStamp], self.remindCount.intValue];
}
- (void)evaluateWithEvent:(Events *)event{
    self.ID = event.ID;
    self.startTime = event.startTime;
    self.title = event.title;
    self.type = event.type;
    self.content = event.content;
    self.startDate = event.startDate;
    self.endDate = event.endDate;
    self.endTime = event.endTime;
    self.remind = event.remind;
    self.repeat = event.repeat;
    self.state = event.state;
    self.adjustTo = event.adjustTo;
    self.adjustToEvent = event.adjustToEvent;
    self.isAdjustdBy = event.isAdjustdBy;
    self.isAdjustdByEvent = event.isAdjustdByEvent;
    self.classify = event.classify;
    self.updateStateTime = event.updateStateTime;
    self.timeStamp = event.timeStamp;
    self.remindCount = event.remindCount;
}


+(Events*)copyEvents:(Events*)model{

    Events* newEvent = [[Events alloc]init];
    
    newEvent.ID = @(model.ID.intValue);
    newEvent.type =@(model.type.intValue);
    newEvent.title = model.title==nil?nil:[NSString stringWithString:model.title];
    newEvent.content = model.content==nil?nil:[NSString stringWithString:model.content];
    newEvent.startDate = [NSDate dateWithTimeInterval:0 sinceDate:model.startDate];
    newEvent.startTime = [NSDate dateWithTimeInterval:0 sinceDate:model.startTime];
    newEvent.endDate = [NSDate dateWithTimeInterval:0 sinceDate:model.endDate];
    newEvent.endTime = [NSDate dateWithTimeInterval:0 sinceDate:model.endTime];
    newEvent.remind = @(model.remind.intValue);
    newEvent.repeat = @(model.repeat.intValue);
    newEvent.state = @(model.state.intValue);
    newEvent.classify = @(model.classify.intValue);
    newEvent.adjustTo=@(model.adjustTo.intValue);
    newEvent.isAdjustdBy=@(model.isAdjustdBy.intValue);
    newEvent.updateStateTime = [NSDate dateWithTimeInterval:0 sinceDate:model.updateStateTime];
    newEvent.timeStamp = [NSDate dateWithTimeInterval:0 sinceDate:model.timeStamp];
    newEvent.isAdjustdBy =model.isAdjustdBy;
    newEvent.adjustTo = model.adjustTo;

    return newEvent;
}

#pragma mark -- NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone{
    Events *event = [[Events alloc]init];
    event.ID = self.ID;
    event.startTime = self.startTime;
    event.title = self.title;
    event.type = self.type;
    event.content = self.content;
    event.startDate = self.startDate;
    event.endDate = self.endDate;
    event.endTime = self.endTime;
    event.remind = self.remind;
    event.repeat = self.repeat;
    event.state = self.state;
    event.adjustTo = self.adjustTo;
    event.adjustToEvent = self.adjustToEvent;
    event.isAdjustdBy = self.isAdjustdBy;
    event.isAdjustdByEvent = self.isAdjustdByEvent;
    event.classify = self.classify;
    event.updateStateTime = self.updateStateTime;
    event.timeStamp = self.timeStamp;
    event.remindCount = self.remindCount;
    
    return event;
}

- (id)copyWithZone:(NSZone *)zone{
    Events *event = [[Events alloc]init];
    event.ID = self.ID;
    event.startTime = self.startTime;
    event.title = self.title;
    event.type = self.type;
    event.content = self.content;
    event.startDate = self.startDate;
    event.endDate = self.endDate;
    event.endTime = self.endTime;
    event.remind = self.remind;
    event.repeat = self.repeat;
    event.state = self.state;
    event.adjustTo = self.adjustTo;
    event.adjustToEvent = self.adjustToEvent;
    event.isAdjustdBy = self.isAdjustdBy;
    event.isAdjustdByEvent = self.isAdjustdByEvent;
    event.classify = self.classify;
    event.updateStateTime = self.updateStateTime;
    event.timeStamp = self.timeStamp;
    event.remindCount = self.remindCount;
    
    return event;
}
@end
