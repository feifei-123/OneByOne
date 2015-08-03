//
//  OBODropDownMenu.h
//  OneByOne
//
//  Created by macbook on 15-5-4.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RATMenu;
@class OBONoHLButton;
@class Events;

typedef enum {
    kMenuAnimateTypeNone = 0,       // 没有动画样式
    kMenuAnimateTypeDropDown,        // 下拉动画样式
    kMenuAnimateTypeDiscrete
}kMenuAnimateType;

typedef enum {
    kMenuAnimateDirectionDown = 0,       // 下拉
    kMenuAnimateDirectionUp        // 上拉
}kMenuAnimateDirection;

@protocol RATMenuDelegate <NSObject>

@optional
- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button;

@end
/*
 *RATMenu 完成的功能:
 *(1)在window 覆盖一个子视图，半透明。
 *(2)在子视图上 由上到下 添加一组按钮.
 */
@interface RATMenu : UIView

@property (nonatomic, assign) CGPoint firstBtnOrigin;
@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, weak) id<RATMenuDelegate> delegate;
@property (nonatomic, assign) kMenuAnimateType animateType;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) kMenuAnimateDirection animateDirection;
@property (nonatomic, assign) CGPoint animateStartOrigin;

@property (nonatomic, strong) NSMutableArray *buttonList;
@property (nonatomic, strong) NSMutableArray *pointList;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleView;


+ (instancetype)menu;
+ (instancetype)popMenu;
+ (instancetype)popUpMenuWithTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath event:(Events *)event;
- (void)addButtonWithBtn:(OBONoHLButton *)btn point:(CGPoint)point;
- (void)addButtonWithText:(NSString *)text image:(NSString *)image highlightedImage:(NSString *)hlImage point:(CGPoint)point;
- (void)addButtonWithText:(NSString *)text image:(NSString *)image highlightedImage:(NSString *)hlImage;
- (void)addButtonWithText:(NSString *)text image:(NSString *)image;
- (void)show;
- (void)dismiss;

@end
