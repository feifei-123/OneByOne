//
//  OBOEventModel.h
//  OneByOne
//
//  Created by macbook on 15-5-2.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBOEventModel : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, assign) BOOL isRemind;
@property (nonatomic, assign) BOOL isRepeat;
@property (nonatomic, assign) NSInteger remindType;
@property (nonatomic, assign) NSInteger repeatType;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) BOOL isFirstCell;

+ (instancetype)eventWithDict:(NSDictionary *)dict;

@end
