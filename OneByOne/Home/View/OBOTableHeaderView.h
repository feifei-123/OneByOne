//
//  OBOTableHeaderView.h
//  OneByOne
//
//  Created by macbook on 15-6-15.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBOTableHeaderButton.h"

typedef enum {
    kHeadViewDateCurrent = 0,
    kHeadViewDateOther
}kHeadViewDate;

@class OBOTableHeaderView;

@protocol OBOTableHeaderViewDelegate <NSObject>

- (void)headerView:(OBOTableHeaderView *)headerView section:(NSInteger)section;

@end

@interface OBOTableHeaderView : UIView
@property (nonatomic, assign) kHeadViewDate dateType;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) OBOTableHeaderButton *btnView;
@property (nonatomic, weak) id<OBOTableHeaderViewDelegate> delegate;


- (void)headerViewWithDateType:(kHeadViewDate)dateType date:(NSString *)date section:(NSInteger)section;
-(void)showRightIcon:(BOOL)show;
@end
