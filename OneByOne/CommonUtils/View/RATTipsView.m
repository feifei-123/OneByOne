//
//  RATTipsView.m
//  OneByOne
//
//  Created by macbook on 15-7-5.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import "RATTipsView.h"
#import "Constants.h"

#define kTipsViewWidth  80
#define kTipsViewHeight 44

@interface RATTipsView()

@end
static RATTipsView *_sharedManager = nil;
@implementation RATTipsView

@synthesize labelView = _labelView;

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedManager = [[self alloc]initWithFrame:[UIScreen mainScreen].bounds];
        UIImage *bgImage = [UIImage imageNamed:@"menu_tips_bgimage"];
        CGFloat height = bgImage.size.height;
        CGFloat width = bgImage.size.width;
        _sharedManager.layer.contents = (id)bgImage.CGImage;
        _sharedManager.layer.backgroundColor = [UIColor clearColor].CGColor;
        _sharedManager.frame = CGRectMake((kScreenWidth - width) / 2, kScreenHeight - (60 + height), width, height);
        _sharedManager.autoHide = YES;
        _sharedManager.autoHideTime = 2.0;
        _sharedManager.animateTime = 0.4;
        _sharedManager.showAlpha = 1.0;
    });
    return _sharedManager;
}

//+ (instancetype)tipsView{
//    
//    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
//    
//    RATTipsView *tipsView = [[self alloc]initWithFrame:window.bounds];
//    UIImage *bgImage = [UIImage imageNamed:@"menu_tips_bgimage"];
//    CGFloat height = bgImage.size.height;
//    CGFloat width = bgImage.size.width;
//    tipsView.frame = CGRectMake((kScreenWidth - width) / 2, kScreenHeight - (60 + height), width, height);
//    tipsView.autoHide = YES;
//    tipsView.autoHideTime = 2.0;
//    tipsView.animateTime = 0.4;
//    tipsView.showAlpha = 0.7;
//    tipsView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
//    
//    [window addSubview:tipsView];
//    return tipsView;
//}

- (UILabel *)labelView{
    if (_labelView == nil) {
        _labelView = [[UILabel alloc]init];
        _labelView.translatesAutoresizingMaskIntoConstraints = NO;
        _labelView.textColor = kColor_5f513f;
        _labelView.textAlignment = NSTextAlignmentCenter;
        _labelView.backgroundColor = [UIColor clearColor];
        [self addSubview:_labelView];
        
        // 设置约束
        NSDictionary *dict = NSDictionaryOfVariableBindings(_labelView);
        NSString *vfl1 = @"|-0-[_labelView]-0-|";
        NSString *vfl2 = @"V:|-0-[_labelView]-0-|";
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict]];
    }
    return _labelView;
}

- (instancetype)init{
    if (self = [super init]) {
        self.alpha = 0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0;
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    self.layer.contents = (id)image.CGImage;
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
}

- (void)show{
    self.isShowing = YES;
    NSDictionary *dict = @{
                           NSFontAttributeName : kFont(18)
                           };
    
    CGRect rc = [self.labelView.text boundingRectWithSize:CGSizeMake(kScreenWidth, kTipsViewHeight) options:NSStringDrawingTruncatesLastVisibleLine |
                 NSStringDrawingUsesLineFragmentOrigin |
                 NSStringDrawingUsesFontLeading  attributes:dict context:nil];
    
    self.frame = CGRectMake((kScreenWidth - rc.size.width) / 2, kScreenHeight - (60 + kTipsViewHeight), rc.size.width, kTipsViewHeight);
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self];
    [UIView animateWithDuration:self.animateTime animations:^{
        self.alpha = self.showAlpha;
    } completion:^(BOOL finished) {
        if (self.autoHide) {
            [NSTimer scheduledTimerWithTimeInterval:self.autoHideTime target:self selector:@selector(hide) userInfo:nil repeats:NO];
        }
    }];
}

- (void)hide{

    [UIView animateWithDuration:self.animateTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.isShowing = NO;
    }];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}
@end
