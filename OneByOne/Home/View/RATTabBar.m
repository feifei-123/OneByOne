//
//  ILTabBar.m
//  ItheimaLottery
//
//  Created by apple on 14-9-9.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "RATTabBar.h"

@interface RATTabBar()

@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation RATTabBar

- (NSMutableArray *)btnArray{
    if (_btnArray == nil) {
        _btnArray = [[NSMutableArray alloc]init];
    }
    return _btnArray;
}

- (void)setBgImage:(UIImage *)bgImage{
    _bgImage = bgImage;
    self.bgImageView.image = _bgImage;
}

- (instancetype)init{
    if (self = [super init]) {
        self.bgImageView = [[UIImageView alloc]init];
        self.bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.bgImageView];
        NSDictionary *dict = NSDictionaryOfVariableBindings(_bgImageView);
        NSString *vfl1 = @"|-0-[_bgImageView]-0-|";
        NSString *vfl2 = @"V:|-0-[_bgImageView]-0-|";
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

// 提供一个方法给外界添加按钮
- (void)addTabBarButtonWithName:(NSString *)name selName:(NSString *)selName
{
    // 创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    
    // 设置按钮的图片
    [btn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:selName] forState:UIControlStateHighlighted];
    
    // 监听按钮的点击
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:btn];
    [self.btnArray addObject:btn];
}

// 提供一个方法给外界添加按钮
- (void)addTabBarButtonWithBgName:(NSString *)bgName hlBgName:(NSString *)hlBgName
{
    // 创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    // 设置按钮的图片
    
    [btn setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:hlBgName] forState:UIControlStateHighlighted];
    
    // 监听按钮的点击
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:btn];
    [self.btnArray addObject:btn];
}


// 点击按钮的时候调用
- (void)btnClick:(UIButton *)button
{
    // 取消之前选择按钮
//    _selectedButton.selected = NO;
    // 选中当前按钮
//    button.selected = YES;
    // 记录当前选中按钮
//    _selectedButton = button;
    
    // 切换控制器
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectedIndex:)]) {
        [_delegate tabBar:self didSelectedIndex:button.tag];
    }
   
}

#warning 设置按钮的位置
- (void)layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@"++++%@",self.subviews);

    CGFloat btnW = self.bounds.size.width / self.btnArray.count;
    CGFloat btnH = self.bounds.size.height;
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    
    // 设置按钮的尺寸
    for (int i = 0; i < self.btnArray.count; i++) {
        UIButton *btn = self.btnArray[i];
        
        // 绑定角标
        btn.tag = i;
        
        btnX = i * btnW;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
//        // 默认选中第一个按钮
//        if (i == 0) {
//            [self btnClick:btn];
//        }
        
    }
    
 
//    NSLog(@"%@-",self.subviews);

   

}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
