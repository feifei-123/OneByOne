//
//  ILTabBar.h
//  ItheimaLottery
//
//  Created by apple on 14-9-9.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
// block作用：保存一段代码，到恰当的时候再去调用

// 如果需要传参数给其他对象，block才需要定义参数
//typedef void(^ILTabBarBlock)(int selectedIndex);

@class RATTabBar;

@protocol RATTabBarDelegate <NSObject>

@optional
- (void)tabBar:(RATTabBar *)tabBar didSelectedIndex:(int)index;

@end

@interface RATTabBar : UIView

@property (nonatomic, weak) id<RATTabBarDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) UIImage *bgImage;

// 给外界创建按钮
- (void)addTabBarButtonWithName:(NSString *)name selName:(NSString *)selName;
- (void)addTabBarButtonWithBgName:(NSString *)bgName hlBgName:(NSString *)hlBgName;


@end
