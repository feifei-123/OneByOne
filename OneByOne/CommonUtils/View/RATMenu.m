//
//  OBODropDownMenu.m
//  OneByOne
//
//  Created by macbook on 15-5-4.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import "RATMenu.h"
#import "OBONoHLButton.h"
#import "NSDate+helper.h"
#import "Events.h"
#import "Constants.h"
#import "OBOStringTools.h"

#define kButtonWidth        100
#define kButtonHeight       40
#define kFirstButtonY       64
#define kFirstButtonX       [UIScreen mainScreen].bounds.size.width - kButtonWidth
#define KColor_5f513f kColor(95, 81, 63)


@interface RATMenu()

@end

@implementation RATMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(NSMutableArray *)buttonList{
    if (_buttonList == nil) {
        _buttonList = [[NSMutableArray alloc]init];
    }
    return _buttonList;
}

- (NSMutableArray *)pointList{
    if (_pointList == nil) {
        _pointList = [[NSMutableArray alloc]init];
    }
    return _pointList;
}

- (UILabel *)titleView{
    if (_titleView == nil) {
        _titleView = [[UILabel alloc]init];
        [self addSubview:_titleView];
    }
    return _titleView;
}

+ (instancetype)menu{
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    RATMenu *menu = [[self alloc]initWithFrame:window.bounds];
    menu.buttonSize = CGSizeMake(kButtonWidth, kButtonHeight);
    menu.firstBtnOrigin = CGPointMake(kFirstButtonX, kFirstButtonY);
    menu.backgroundColor = [UIColor clearColor];

    
    [window addSubview:menu];
    
    return menu;
}

+ (instancetype)popUpMenuWithTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath event:(Events *)event{
    RATMenu *menu = [RATMenu menu];
    
    CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
    
    CGRect rect = [tableView convertRect:rectInTableView toView:[tableView superview]];
    menu.animateDirection = kMenuAnimateDirectionUp;
    menu.animateType = kMenuAnimateTypeDropDown;
    
    OBONoHLButton *btn = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
    if (event.state.intValue == kEventStateAdjusted) {
        [btn setTitle:[NSDate stringFromDateAndTime:[NSDate dateWithDay:event.adjustToEvent.startDate time:event.adjustToEvent.startTime]] forState:UIControlStateNormal];
    }
    else{
        [btn setTitle:[NSDate stringFromDateAndTime:event.updateStateTime] forState:UIControlStateNormal];
    }
    
    [btn setBackgroundImage:[UIImage imageNamed:@"menu_popup_bgimage"] forState:UIControlStateNormal];
    [btn setTitleColor:kMenuTextColor forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    btn.titleLabel.font = kFont(kPopUpMenuFontSize);
    [menu addButtonWithBtn:btn point:CGPointZero];
    
    UIImage *image = [UIImage imageNamed:@"menu_popup_bottom_bgimage"];
    menu.buttonSize = image.size;
    menu.firstBtnOrigin = CGPointMake(kScreenWidth - image.size.width, rect.origin.y - image.size.height);
    return menu;
}

+ (instancetype)popMenu{
    RATMenu *menu = [RATMenu menu];
//    [menu addButtonWithText:@"删除" image:@"" highlightedImage:@""];
//    [menu addButtonWithText:@"修改" image:@"" highlightedImage:@""];
    
    OBONoHLButton *btn = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
    OBONoHLButton *btn2 = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"删 除" forState:UIControlStateNormal];
    [btn2 setTitle:@"修 改" forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageNamed:@"menu_popup_bgimage"] forState:UIControlStateNormal];
//    [btn2 setBackgroundImage:[UIImage imageNamed:@"menu_popup_bgimage"] forState:UIControlStateNormal];
    [btn setTitleColor:KColor_5f513f forState:UIControlStateNormal];
    //    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    btn.titleLabel.font = kFont(18);
    [btn2 setTitleColor:KColor_5f513f forState:UIControlStateNormal];
    btn2.titleLabel.font = kFont(18);
    [menu addButtonWithBtn:btn point:CGPointZero];
    [menu addButtonWithBtn:btn2 point:CGPointZero];
    
    menu.buttonSize = CGSizeMake(kScreenWidth * 2 / 3, 40);
    menu.firstBtnOrigin = CGPointMake((kScreenWidth - menu.buttonSize.width) / 2, (kScreenHeight - menu.buttonSize.height * menu.buttonList.count) / 2);
    UIImage *image = [UIImage imageNamed:@"menu_longpressed_bgimage"];
    menu.bgImageView.image = image;
    CGRect rc = CGRectMake((kScreenWidth - image.size.width) / 2, (kScreenHeight  - 168) / 2, image.size.width, image.size.height);
    menu.bgImageView.frame = rc;
    menu.titleView.text = @"菜 单";
    menu.titleView.textAlignment = NSTextAlignmentCenter;
    menu.titleView.frame = CGRectMake((kScreenWidth - image.size.width) / 2, (kScreenHeight  - 168) / 2, image.size.width, 34);
    return menu;
}
- (instancetype)init{
    if (self = [super init]) {
        self.bgImageView = [[UIImageView alloc]init];
        [self addSubview:self.bgImageView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.bgImageView = [[UIImageView alloc]init];
        [self addSubview:self.bgImageView];
    }
    return self;
}

- (void)dismiss{
    
    if (self.animateType != kMenuAnimateTypeNone) {
        [UIView animateWithDuration:0.2 animations:^{
            for (UIButton *btn in self.subviews) {
                if (CGPointEqualToPoint(self.animateStartOrigin, CGPointZero)) {
                    btn.frame = CGRectMake(self.firstBtnOrigin.x, self.firstBtnOrigin.y, self.buttonSize.width, self.buttonSize.height);
                }
                else{
                    btn.frame = CGRectMake(self.animateStartOrigin.x, self.animateStartOrigin.y, self.buttonSize.width, self.buttonSize.height);
                }
            }
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    else{
        [self removeFromSuperview];
    }
    
}

- (void)addButtonWithText:(NSString *)text image:(NSString *)image{
    [self addButtonWithText:text image:image highlightedImage:nil point:CGPointZero];
}

- (void)addButtonWithText:(NSString *)text image:(NSString *)image highlightedImage:(NSString *)hlImage
{
    [self addButtonWithText:text image:image highlightedImage:hlImage point:CGPointZero];
}
- (void)addButtonWithText:(NSString *)text image:(NSString *)image highlightedImage:(NSString *)hlImage point:(CGPoint)point{
    OBONoHLButton *btn = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
    if (text != nil) {
        [btn setTitle:text forState:UIControlStateNormal];
    }
    if (image != nil) {
        [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
    if (hlImage != nil) {
        [btn setImage:[UIImage imageNamed:hlImage] forState:UIControlStateHighlighted];
    }
    
//    btn.backgroundColor = [UIColor greenColor];
    
    [self addButtonWithBtn:btn point:point];
}

- (void)addButtonWithBtn:(OBONoHLButton *)btn point:(CGPoint)point{
    
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.firstBtnOrigin.x, self.firstBtnOrigin.y, self.buttonSize.width, self.buttonSize.height);
    btn.tag = self.buttonList.count;
    
    [self.pointList addObject:[NSValue valueWithCGPoint:point]];
    
    [self.buttonList addObject:btn];
    [self addSubview:btn];
}

- (void)show{
    int direction = self.animateDirection == kMenuAnimateDirectionDown ? 1 : -1;
    for (int i = 0; i < self.buttonList.count; i ++) {
        UIButton *btn = self.buttonList[i];
        //（1）为每个button设置点击事件.
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        //(2) 设置按钮的Frame
        if (CGPointEqualToPoint(self.animateStartOrigin, CGPointZero)) {
            btn.frame = CGRectMake(self.firstBtnOrigin.x, self.firstBtnOrigin.y, self.buttonSize.width, self.buttonSize.height);
        }
        else{
            btn.frame = CGRectMake(self.animateStartOrigin.x, self.animateStartOrigin.y, self.buttonSize.width, self.buttonSize.height);
        }
        
        if (self.animateType == kMenuAnimateTypeDropDown) {
            [UIView animateWithDuration:0.2 animations:^{
                btn.frame = CGRectMake(self.firstBtnOrigin.x, self.firstBtnOrigin.y + (self.buttonSize.height + self.padding) * i * direction, self.buttonSize.width, self.buttonSize.height);
            } completion:^(BOOL finished) {
            }];
        }
        else if (self.animateType == kMenuAnimateTypeNone){
            btn.frame = CGRectMake(self.firstBtnOrigin.x, self.firstBtnOrigin.y + (self.buttonSize.height + self.padding) * i * direction, self.buttonSize.width, self.buttonSize.height);
        }
        else if (self.animateType == kMenuAnimateTypeDiscrete){
            NSValue *value = self.pointList[i];
            [UIView animateWithDuration:0.2 animations:^{
            btn.frame = CGRectMake(value.CGPointValue.x , value.CGPointValue.y, self.buttonSize.width, self.buttonSize.height);
            }]                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ;
        }
        
    }
}

- (void)btnClick:(UIButton *)button{
//    NSLog(@"%ld",(long)button.tag);
    [self bringSubviewToFront:button];
    if ([self.delegate respondsToSelector:@selector(menu:clickedButton:)]) {
        [self.delegate menu:self clickedButton:button];
    }
    [self dismiss];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
