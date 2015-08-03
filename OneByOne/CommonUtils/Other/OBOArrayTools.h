//
//  OBOArrayTools.h
//  OneByOne
//
//  Created by 白雪飞 on 15-5-28.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBOArrayTools : NSObject
+(void)sortArray:(NSMutableArray*)array withKeywordsArray:(NSArray*)sortKeyWords;
+(void)sortArrayByDateTime:(NSMutableArray*)array2Sort ascending:(BOOL)asc;
+(void)sortScheduleAndEvents:(NSMutableArray*)array2Sort;
+(NSArray *) createRightButtons;
+(NSMutableArray*)improveScheArray:(NSMutableArray*)scheArr WithDate1:(NSDate*)date_1 Date_2:(NSDate*)date_2;
@end
