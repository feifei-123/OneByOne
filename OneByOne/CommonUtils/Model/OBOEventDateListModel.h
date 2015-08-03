//
//  OBOEventDateListModel.h
//  OneByOne
//
//  Created by macbook on 15-5-8.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBOEventDateListModel : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) NSMutableArray *eventList;
//标志位，判断该组“日程”数据 是否显示。isShow==YES,展开显示；isShow==NO,折叠隐藏。
@property (nonatomic,assign) BOOL isShow;

- (void)eventListWithArray:(NSMutableArray *)array;
- (void)eventListWithSortedArray:(NSMutableArray *)sortedArray withFormat:(BOOL)format;
-(void)sortSelfEventListWithFormat:(BOOL)format;

+(OBOEventDateListModel*)createNoScheduleModel:(NSDate*)date;
@end
