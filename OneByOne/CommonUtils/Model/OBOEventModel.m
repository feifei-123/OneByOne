//
//  OBOEventModel.m
//  OneByOne
//
//  Created by macbook on 15-5-2.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import "OBOEventModel.h"

@implementation OBOEventModel
-(instancetype)init{
    self = [super init];
    
    if (self) {
        
    
        self.type =  -1; // －1代表不属于行程类别
        self.title = @"";
        self.content = @"";
        self.startDate =@"";
        self.startTime =@"";
        self.endDate=@"";
        self.endTime=@"";;
        self.remindType=-1;//－1代表不属于提醒类别
        self.repeatType=-1;//－1代表不属于重复类别
        
        self.isRemind=NO;
        self.isRepeat=NO;
        self.isFirstCell=NO;
    }
    return self;
}

+ (instancetype)eventWithDict:(NSDictionary *)dict{
    
    OBOEventModel *event = [[OBOEventModel alloc]init];
    [event setValuesForKeysWithDictionary:dict];
    
    
    return event;
}

@end
