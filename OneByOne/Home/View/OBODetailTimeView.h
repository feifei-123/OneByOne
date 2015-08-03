//
//  OBODetailTimeView.h
//  OneByOne
//
//  Created by macbook on 15-6-20.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kTimeViewTypeTime = 0,
    kTimeViewTypeWeather
}kTimeViewType;

@interface OBODetailTimeView : UIView

@property (nonatomic, assign) kTimeViewType type;

- (void)timeViewWithDay:(NSDate *)day time:(NSDate *)time;
- (void)timeViewWithDate:(NSDate *)date;

@end
