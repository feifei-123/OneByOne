//
//  OBOArrayTools.m
//  OneByOne
//
//  Created by 白雪飞 on 15-5-28.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOArrayTools.h"
#import "Constants.h"
#import "Events.h"
#import "MGSwipeButton.h"
#import "NSDate+helper.h"
#import "OBOEventDateListModel.h"

@implementation OBOArrayTools


/*对数组 按照 特定的描述符，进行生序或降序排序。
 *参数: array－被排序的数组.
 *     sortKeyWords:描述排序条件的数组。数组中每个元素 为一个字典。
 *     字典中保存“property”和“order” 两个键，
 *     property对应排序依赖的“属性”。
 *     order==asc 表示升序；order==desc表示降序。
 */
+(void)sortArray:(NSMutableArray*)array2Sort withKeywordsArray:(NSArray*)sortKeyWords{
    
    NSMutableArray* descriptorsArr = [[NSMutableArray alloc]init];
    
    for ( NSDictionary*dic in  sortKeyWords) {
        
        NSString *key = dic[@"property"];
        NSString *order = dic[@"order"];
        BOOL order_b = [order isEqual:@"asc"]?YES:NO;
        
        NSSortDescriptor * sorter = [[NSSortDescriptor alloc]initWithKey:key ascending:order_b];
        [descriptorsArr addObject:sorter];
    }
    
    [array2Sort sortUsingDescriptors:descriptorsArr];
    
}

/*
*对数组按照日期和时间 进行对结果集进行排序。
*/

+(void)sortArrayByDateTime:(NSMutableArray*)array2Sort ascending:(BOOL)asc{
    
    
    NSString*order = @"";
    if (asc) {
        order = @"asc";
    }else{
        order = @"desc";
    }
    
    NSDictionary* dic1 = @{@"property":@"startDate",@"order":order};
    NSDictionary* dic2 = @{@"property":@"startTime",@"order":order};
    NSDictionary* dic3 = @{@"property":@"timeStamp",@"order":order};
    
    NSArray * keyWordsArray = [NSArray arrayWithObjects:dic1,dic2,dic3,nil];
    [OBOArrayTools sortArray:array2Sort withKeywordsArray:keyWordsArray];
    
}

/* 将日程和事件 按照 startDate,startTime,timeStamp 三个关键字，进行升序排序，将排在第二个位置上。
 *
 *
 */
+(void)sortScheduleAndEvents:(NSMutableArray*)array2Sort{
    
    [OBOArrayTools sortArrayByDateTime:array2Sort ascending:YES];
    
    NSMutableArray*eventArray = [[NSMutableArray alloc]init];
    int i = 0;
    
    for (Events*events in array2Sort) {
        
        if (events.classify.intValue ==kEventClassifyEvent) {
            [eventArray addObject:events];
            i++;
        }
    }
    
    NSRange range = NSMakeRange(0, i);
    [array2Sort removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    NSRange insertRange ;
    if (array2Sort.count==0) { //数组中 没有日程，则事件排在第一位.
        insertRange = NSMakeRange(0, i);
    }else{//数组中,存在至少一个日程，则事件排在第二位.
        insertRange = NSMakeRange(1, i);
    }
    [array2Sort insertObjects:eventArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:insertRange]];
}

/*
 *创建MGSwipeTableViewCell 右侧的button
 *
 */
+(NSArray *) createRightButtons
{
    NSMutableArray * result = [NSMutableArray array];
    
    NSArray* icons = [NSArray arrayWithObjects:@"cell_complete_normal", @"cell_cancel_normal",@"cell_adjust_normal", nil];

    for (int i = 0; i < icons.count ; ++i)
    {
        //指定cell 侧滑 按钮的图标
        MGSwipeButton * button = [MGSwipeButton buttonWithIcon:[UIImage imageNamed:icons[i]] hightIcon:nil backgroundColor:[UIColor clearColor]];

        [result addObject:button];
    }
    return result;
}


/**
 *补全 日程数组中,从[date_1 date_2]区间中，缺失的“当天日程”
 * 参数:scheArr必须是按startDate升序的 OBOEventDateListModel的数组. date_1:表示当前 日程列表所表示的日程的起始日期,date_2:表示当前 日程列表所表示的日程的终点日期
 *
 */
+(NSMutableArray*)improveScheArray:(NSMutableArray*)scheArr WithDate1:(NSDate*)date_1 Date_2:(NSDate*)date_2{
    
    //[OBOArrayTools  sortArrayByDateTime:scheArr ascending:YES];
    if (date_2==nil) {
        NSLog(@"date_2 was nil------------------------------------");
        NSLog(@"date_2 was nil------------------------------------");
        NSLog(@"date_2 was nil------------------------------------");
    }
    
    if (date_1==nil) {
        NSLog(@"date_1 was nil------------------------------------");
        NSLog(@"date_1 was nil------------------------------------");
        NSLog(@"date_1 was nil------------------------------------");
    }
    
    NSMutableArray* resultArr = [[NSMutableArray alloc]init];
    
    NSInteger dayCount = [date_1 dayIntervalFrom:date_2]+1;;

    //(1)数据预处理
    OBOEventDateListModel * lastModel  = (OBOEventDateListModel *)[scheArr lastObject];
    if (lastModel==nil) {
        OBOEventDateListModel * fakeDateListModel = [OBOEventDateListModel createNoScheduleModel:date_2];
        [scheArr addObject:fakeDateListModel];
        
    }else{
        if (![date_2 dateIsEqual:[NSDate formatDateWithString:lastModel.date]]) {
            OBOEventDateListModel * fakeDateListModel = [OBOEventDateListModel createNoScheduleModel:date_2];
            [scheArr addObject:fakeDateListModel];
        }
    }
    
//    NSLog(@"lastModel.date]:%@",lastModel.date);
//    if ([NSDate formatDateWithString:lastModel.date]==nil) {
//        NSLog(@"date was nil------------");
//    }
//    if (![date_2 dateIsEqual:[NSDate formatDateWithString:lastModel.date]]) {
//         OBOEventDateListModel * fakeDateListModel = [OBOEventDateListModel createNoScheduleModel:date_2];
//        [scheArr addObject:fakeDateListModel];
//    }
    
    //(2)算法过程
    int dIndex = 0; //date的index.
    int mIndex = 0; //scheArr的index.
    
    while (dIndex<dayCount) {
        
        //（1）取出 “欲比较”的date.
        NSDate* tmpDate = [NSDate dateWithStartDate:date_1 Offset:dIndex];
        
        // (2)取出 “欲比较”的dateListModel
        OBOEventDateListModel * dateListModel = (OBOEventDateListModel *)[scheArr objectAtIndex:mIndex];

        //将 tmpDate 与 dateListModel的日期标签 进行比较
        if([tmpDate dateIsEqual:[NSDate formatDateWithString:dateListModel.date]]){
            // 日期 匹配成功，则游标 双移动
            [resultArr addObject:dateListModel];
            dIndex++;
            mIndex++;
        }else{
            //若日期匹配失败，则 插入“假的”日程信息，dIndex游标下移
            OBOEventDateListModel * fakeDateListModel = [OBOEventDateListModel createNoScheduleModel:tmpDate];
            [resultArr addObject:fakeDateListModel];
            dIndex++;
        }
        
        
    }
    
    return resultArr;
   
}


@end
