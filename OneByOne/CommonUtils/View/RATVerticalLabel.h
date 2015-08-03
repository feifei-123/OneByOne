//
//  RATVerticalLabel.h
//  OneByOne
//
//  Created by macbook on 15-6-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface RATVerticalLabel : UILabel

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end

