//
//  OBOVerticallyAlignedLabel.h
//  OneByOne
//
//  Created by macbook on 15-6-22.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface OBOVerticallyAlignedLabel : UILabel {
    @private VerticalAlignment verticalAlignment_;
}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end
