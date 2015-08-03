//
//  OBO_DetailScheVController.h
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBOFatherController.h"
#import "OBOCommonDelegate.h"
@class Events;

@protocol OBODetailScheDelegate <NSObject>

@optional
- (void)modifiedEventModel:(Events *)eventModel atRow:(NSInteger)row;

@end

@interface OBODetailScheController : OBOFatherController

@property (nonatomic, strong) Events *event;
@property (nonatomic, assign) NSInteger row;

@property (nonatomic, weak) id<OBOOperateDataDelegate> delegate;

- (void)contentWithEvent:(Events *)event row:(NSInteger)row;

@end
