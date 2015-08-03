//
//  OBOCellContentView.h
//  OneByOne
//
//  Created by macbook on 15-5-2.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Events;

@interface OBOCellContentView : UIView

@property (nonatomic, assign) BOOL isFirstCell;
@property (nonatomic, assign) BOOL hasState;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *stateView;
@property (nonatomic, strong) Events *event;
-(void)setCellSelected;
-(void)setCellUnSelected;
@end
