//
//  OBO_OverdueScheVController.h
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBOFatherController.h"
#import "OBODetailScheController.h"
#import "OBOTableController.h"
@class OBOOverdueScheController;

@protocol OBOOverdueScheDelegate <NSObject>

- (void)dismissControllerWithOverdueSche:(OBOOverdueScheController *)vc;

@end

@class OBOEventDateListModel;

@interface OBOOverdueScheController : OBOTableController

@property (nonatomic, weak) id<OBOOperateDataDelegate> delegate;
@property (nonatomic, weak) id<OBOOverdueScheDelegate> dismissDelegate;

- (void)addData:(OBOEventDateListModel *)dataList date:(NSDate *)date;

@end
