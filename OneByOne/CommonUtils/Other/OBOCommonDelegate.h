//
//  OBOCommonDelegate.h
//  OneByOne
//
//  Created by macbook on 15-5-17.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#ifndef OneByOne_OBOCommonDelegate_h
#define OneByOne_OBOCommonDelegate_h
#import "OBOStringTools.h"
@class Events;

typedef void(^boolResult)(BOOL result,kInsertDataResult insertResult);

@protocol OBOOperateDataDelegate <NSObject>

@optional
/**
 *  更新数据
 *
 *  @param targetEvent 要更新成的数据
 *  @param event 原始数据(用来定位)
 *
 *  @return 更新是否成功
 */
- (void)updateDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock;

/**
 *  批量更新数据
 *
 *  @param event 要更新的数据数组
 *  @param event 更新的状态
 *
 *  @return 更新是否成功
 */
- (void)updateDataWithArray:(NSArray *)eventArray state:(kEventState)state result:(boolResult)resultBlock;
/**
 *  删除数据
 *
 *  @param event 需要删除的数据
 *
 *  @return 是否删除成功
 */
- (void)removeDataWithEvent:(Events *)event result:(boolResult)resultBlock;
/**
 *  添加数据
 *
 *  @param event 需要添加的数据
 *
 *  @return 是否添加成功
 */
- (void)insertDataWithEvent:(Events *)event result:(boolResult)resultBlock;
/**
 *  调整日程
 *
 *  @param event 需要调整的数据
 *
 *  @param targetEvent 被调整的数据
 *
 *  @return 是否调整成功
 */
- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock;

/**
 *  调整日程
 *
 *  @param event 需要调整的数据
 *
 *  @param targetEvent 被调整的数据
 *
 *  @param currentPage 是否是当前页面
 *
 *  @return 是否调整成功
 */
- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent currentPage:(BOOL)currentPage result:(boolResult)resultBlock;

@end


#endif
