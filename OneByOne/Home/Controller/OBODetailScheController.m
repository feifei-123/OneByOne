//
//  OBO_DetailScheVController.m
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBODetailScheController.h"
#import "OBONewScheController.h"
#import "OBONavigationController.h"
#import "OBODetailTimeView.h"
#import "OBODetailButton.h"
#import "OBONoHLButton.h"
#import "RATMenu.h"
#import "RATTipsView.h"
#import "OBOVerticallyAlignedLabel.h"
#import "Events.h"
#import "OBOStringTools.h"
#import "Utils.h"
#import "OBODataBase.h"
#import "UIImage+stretch.h"
#import "NSDate+helper.h"
#import "Constants.h"

#define kDetailContentFont [UIFont systemFontOfSize:12]
#define kDetailStartTimeViewX (kScreenWidth / 2 - 25.5)

#define kStateMenuButtonWidth   34
#define kStateMenuButtonHeight   34

#define kContentLineSpace   0.0f
#define kContentLineWidth   18.0f

#define kColor_cac5b4 kColor(202, 197, 180)
#define kColor_eeebe2 kColor(238, 235, 226)

@interface OBODetailScheController() <RATMenuDelegate,OBOOperateDataDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewXConstraint;

// 设置内容的宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint;
// 内容详情的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailHeightConstraint;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTrailingConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *scrollBgView;

@property (weak, nonatomic) IBOutlet UIView *headTimeView;

@property (weak, nonatomic) IBOutlet OBODetailTimeView *startTimeView;
@property (weak, nonatomic) IBOutlet OBODetailTimeView *endTimeView;
@property (weak, nonatomic) IBOutlet UIImageView *dateConnectIconView;
@property (weak, nonatomic) IBOutlet UIButton *hideEndTimeView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UIImageView *typeIconView;
@property (weak, nonatomic) IBOutlet UILabel *typeView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
//@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet OBOVerticallyAlignedLabel *contentView;
@property (weak, nonatomic) IBOutlet OBONoHLButton *stateIconView;
@property (weak, nonatomic) IBOutlet OBODetailButton *repeatView;
@property (weak, nonatomic) IBOutlet OBODetailButton *remindView;
@property (weak, nonatomic) IBOutlet UIView *firstBlackView;
@property (weak, nonatomic) IBOutlet UIView *firstWhiteView;
@property (weak, nonatomic) IBOutlet UIView *secondBlackView;
@property (weak, nonatomic) IBOutlet UIView *secondWhiteView;
@property (weak, nonatomic) IBOutlet UIView *thirdBlackView;
@property (weak, nonatomic) IBOutlet UIView *thirdWhiteView;
@property (weak, nonatomic) IBOutlet UIView *forthBlackView;
@property (weak, nonatomic) IBOutlet UIView *forthWhiteView;

@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

@property (nonatomic, assign) BOOL showEndTimeView;
@property (nonatomic, assign) BOOL showEndTimeViewAnimate;

@property (nonatomic, weak) RATMenu *stateMenu;

@end

@implementation OBODetailScheController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSLog(@"%s,%@",__func__,[NSThread currentThread]);
    //    self.tempLabel.text=@"日程详情页面";
    //    [self.view addSubview:self.tempLabel];
    // Do any additional setup after loading the view.
    self.scrollView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    //    UIImage *bgImage = [UIImage imageNamed:@"detail_bgimage"];
    //    self.view.layer.contents = (id)bgImage.CGImage;
    //    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.title = @"日程细则";
    UIImage *bgImage = [UIImage imageNamed:@"overdue_bgimage"];
    self.view.layer.contents = (id)bgImage.CGImage;
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.timeViewXConstraint.constant = kDetailStartTimeViewX;
    self.timeViewWidthConstraint.constant = kScreenWidth;
    
    [self addNavRightBtn:@"navbar_more_normal" HightLightImage:@"navbar_more_hightlighted" action:@selector(more)];
    
    // 设置scrollview背景图
    self.scrollBgView.image = [UIImage imageWithStretch:@"detail_scrollview_bgimage"];
    
    // 设置标签的字体颜色
    self.typeView.font = kFont(12);
    //    self.typeView.backgroundColor = kColor(235, 233, 227);
    self.typeView.textColor = kColor_837963;
    self.titleView.font = kFont(16);
    self.titleView.textColor = kColor_5f513f;
    self.contentView.font = kFont(12);
    self.contentView.textColor = kColor_837963;
    //    self.contentView.verticalAlignment = VerticalAlignmentTop;
    
    // 设置底部按钮
    [self.repeatView setBackgroundImage:[UIImage imageNamed:@"detail_button_bgimage"] forState:UIControlStateNormal];
    [self.repeatView setImage:[UIImage imageNamed:@"icon_repeat"] forState:UIControlStateNormal];
    self.repeatView.titleLabel.font = kDetailButtonFont;
    [self.repeatView setTitleColor:kColor_837963 forState:UIControlStateNormal];
    [self.remindView setBackgroundImage:[UIImage imageNamed:@"detail_button_bgimage"] forState:UIControlStateNormal];
    [self.remindView setImage:[UIImage imageNamed:@"icon_alarmclock"] forState:UIControlStateNormal];
    self.remindView.titleLabel.font = kDetailButtonFont;
    [self.remindView setTitleColor:kColor_837963 forState:UIControlStateNormal];
    
    // 设置分割线颜色
    self.firstBlackView.backgroundColor = kColor_cac5b4;
    self.firstWhiteView.backgroundColor = kColor_eeebe2;
    
    self.secondBlackView.backgroundColor = kColor_cac5b4;
    self.secondWhiteView.backgroundColor = kColor_eeebe2;
    
    self.thirdBlackView.backgroundColor = kColor_cac5b4;
    self.thirdWhiteView.backgroundColor = kColor_eeebe2;
    
    self.forthBlackView.backgroundColor = kColor_cac5b4;
    self.forthWhiteView.backgroundColor = kColor_eeebe2;
    
    //    // 设置状态图标为圆形
    //    self.stateIconView.layer.masksToBounds = YES;
    //    self.stateIconView.layer.cornerRadius = self.stateIconView.bounds.size.width / 2;
    //    self.stateIconView.layer.borderWidth = 2;
    
    // 设置字体间每行的间距
    self.paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.paragraphStyle.lineHeightMultiple = kContentLineWidth;
    self.paragraphStyle.maximumLineHeight = kContentLineWidth;
    self.paragraphStyle.minimumLineHeight = kContentLineWidth;
    self.paragraphStyle.lineSpacing = kContentLineSpace;// 行间距
    self.showEndTimeView = NO;
    self.showEndTimeViewAnimate = YES;
    //    self.paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //    OBOEventModel *event = [[OBOEventModel alloc]init];
    //    event.type = kEventTypeFriend;
    //    event.title = @"北航面基";
    //    event.startTime = @"下午18:00";
    //    event.content = @"首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。";
    //    event.state = kEventStatePending;
    
    //    [self setEvent:event];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)setEvent:(Events *)event{
    _event = event;
    
    // 检查需不需要加载调整到的event
    if (_event.state.intValue == kEventStateAdjusted && !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     _event.adjustToEvent) {
        [[OBODataBase sharedManager] queryEventsWithId:_event.adjustTo resultList:^(Events *event) {
            _event.adjustToEvent = event;
        }];
    }
    // 设置内容宽度
    self.contentWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width;
    // 设置日期
    self.startTimeView.type = kTimeViewTypeTime;
    [self.startTimeView timeViewWithDay:event.startDate time:event.startTime];
    self.endTimeView.type = kTimeViewTypeTime;
    [self.endTimeView timeViewWithDay:event.endDate time:event.endTime];
    
    if (event.endDate && event.endTime) {
        self.hideEndTimeView.hidden = NO;
    }
    else{
        self.hideEndTimeView.hidden = YES;
    }
    
    // 设置日程类型
    self.typeView.text = [OBOStringTools stringWithEventType:event.type.intValue];
    self.typeIconView.image = [OBOStringTools smallImageWithEventType:event.type.intValue];
    
    // 设置日程标题
    self.titleView.text = event.title;
    [self.remindView setTitle:[OBOStringTools stringWithRemind:(kRemindType)event.remind.integerValue] forState:UIControlStateNormal];
    [self.repeatView setTitle:[OBOStringTools stringWithRepeat:(kRepeatType)event.repeat.integerValue] forState:UIControlStateNormal];
    
    // 设置起始时间
    //    self.timeView.text = [OBOStringTools stringFromTime:event.startTime];
    
    // 设置结束时间
#warning 界面没有设计结束时间
    
    //    event.content = @"首先说按比例缩放，这是在Interface Builder中无法设置的内容。而在代码中，使用NSLayoutConstraint类型的初始化函数中的multiplier参数就可以非常简单的设置按比例缩放。同时也可以设置不同NSLayoutAttribute参数来达到意想不到的效果，比如“A的Width等于B的Height的2倍”这样的效果。";
    
    // 日程详情
    NSDictionary *dict = @{
                           NSParagraphStyleAttributeName : self.paragraphStyle,
                           NSFontAttributeName : kDetailContentFont
                           };
    
    CGRect rc = [event.content boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine |
                 NSStringDrawingUsesLineFragmentOrigin |
                 NSStringDrawingUsesFontLeading  attributes:dict context:nil];
    
    
    // 设置详情控件高度
    self.detailHeightConstraint.constant = ((int)rc.size.height + 5);
    //    self.contentWidthConstraint.constant = self.view.bounds.size.width;
    //    self.contentView.text = event.content;
    self.contentView.attributedText = [[NSAttributedString alloc] initWithString:event.content attributes:dict];
    self.contentView.font = kDetailContentFont;
    
    // 日程状态
    UIImage *image = [OBOStringTools detailImageWithEventState:event.state.intValue];
    [self.stateIconView setImage:image forState:UIControlStateNormal];
    [self.stateIconView removeTarget:self action:@selector(stateIconClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.stateIconView addTarget:self action:@selector(stateIconClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.showEndTimeView) {
        [self hideEndTimeBtnClick:self.hideEndTimeView];
    }
}

- (void)contentWithEvent:(Events *)event row:(NSInteger)row{
    self.event = event;
    self.row = row;
}
- (IBAction)hideEndTimeBtnClick:(UIButton *)sender {
    self.timeViewXConstraint.constant = 0;
    self.endTimeView.hidden = NO;
    self.dateConnectIconView.hidden = NO;
    self.hideEndTimeView.hidden = YES;
    self.showEndTimeView = YES;
    if (self.showEndTimeViewAnimate) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.headTimeView layoutIfNeeded];
        }];
    }
}

- (void)stateIconClick:(UIButton *)btn{
    RATMenu *menu = [RATMenu menu];
    self.stateMenu = menu;
    switch (self.event.state.intValue) {
        case kEventStatePending:
        {
            menu.animateType = kMenuAnimateTypeDiscrete;
            
            CGPoint point = [self.scrollBgView convertPoint:self.stateIconView.frame.origin toView:self.view];
            
            [menu addButtonWithText:nil image:@"detail_adjust_small_normal" highlightedImage:nil point:CGPointMake(point.x - kStateMenuButtonWidth, point.y)];
            [menu addButtonWithText:nil image:@"detail_cancel_small_normal" highlightedImage:nil point:CGPointMake(point.x + (self.stateIconView.frame.size.width - kStateMenuButtonWidth) / 2, point.y - (kStateMenuButtonHeight ))];
            [menu addButtonWithText:nil image:@"detail_complete_small_normal" highlightedImage:nil point:CGPointMake(point.x + self.stateIconView.frame.size.width, point.y)];
            menu.buttonSize = CGSizeMake(kStateMenuButtonWidth, kStateMenuButtonHeight);
            
            menu.animateStartOrigin = CGPointMake(point.x + (self.stateIconView.frame.size.width - kStateMenuButtonWidth) / 2, point.y + (self.stateIconView.frame.size.height - kStateMenuButtonHeight) / 2);
        }
            break;
        case kEventStateComplete:
        case kEventStateCancelled:
        {
            menu.animateDirection = kMenuAnimateDirectionUp;
            menu.animateType = kMenuAnimateTypeDropDown;
            
            CGPoint point = [self.scrollBgView convertPoint:self.stateIconView.frame.origin toView:self.view];
            OBONoHLButton *btn = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:[NSDate stringFromDateAndTime:self.event.updateStateTime] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"menu_popup_bottom_bgimage"] forState:UIControlStateNormal];
            [btn setTitleColor:kMenuTextColor forState:UIControlStateNormal];
            btn.titleLabel.font = kFont(kPopUpMenuFontSize);
            [menu addButtonWithBtn:btn point:CGPointZero];
            menu.buttonSize = CGSizeMake(kStateMenuButtonWidth, kStateMenuButtonHeight);
            UIImage *image = [UIImage imageNamed:@"menu_popup_bottom_bgimage"];
            menu.buttonSize = image.size;
            menu.firstBtnOrigin = CGPointMake(point.x + (self.stateIconView.frame.size.width - image.size.width) / 2, point.y - image.size.height);
            //            menu.animateStartOrigin = CGPointMake(point.x + (self.stateIconView.frame.size.width - kStateMenuButtonWidth) / 2, point.y + (self.stateIconView.frame.size.height - kStateMenuButtonHeight) / 2);
        }
            break;
        case kEventStateAdjusted:
        {
            menu.animateDirection = kMenuAnimateDirectionUp;
            menu.animateType = kMenuAnimateTypeDropDown;
            
            CGPoint point = [self.scrollBgView convertPoint:self.stateIconView.frame.origin toView:self.view];
            OBONoHLButton *btn = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
            Events *event = self.event;
            [btn setTitle:[NSDate stringFromDateAndTime:[NSDate dateWithDay:self.event.adjustToEvent.startDate time:self.event.adjustToEvent.startTime]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"menu_popup_bottom_bgimage"] forState:UIControlStateNormal];
            [btn setTitleColor:kMenuTextColor forState:UIControlStateNormal];
            btn.titleLabel.font = kFont(kPopUpMenuFontSize);
            [menu addButtonWithBtn:btn point:CGPointZero];
            menu.buttonSize = CGSizeMake(kStateMenuButtonWidth, kStateMenuButtonHeight);
            UIImage *image = [UIImage imageNamed:@"menu_popup_bottom_bgimage"];
            menu.buttonSize = image.size;
            menu.firstBtnOrigin = CGPointMake(point.x + (self.stateIconView.frame.size.width - image.size.width) / 2, point.y - image.size.height);
            //            menu.animateStartOrigin = CGPointMake(point.x + (self.stateIconView.frame.size.width - kStateMenuButtonWidth) / 2, point.y + (self.stateIconView.frame.size.height - kStateMenuButtonHeight) / 2);
        }
            break;
            
        default:
            break;
    }
    
    menu.delegate = self;
    //    menu.backgroundColor = [UIColor colorWithRed:55.0 / 255 green:55.0 / 255 blue:55.0 / 255 alpha:0.5];
    [menu show];
    
}

#pragma mark -- RATMenuDelegate

- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button
{
    
    if (menu == self.stateMenu) {
        [self operateStateMenu:button.tag];
    }
    else{
        [self operateDropDownMenu:button.tag];
    }
    
}
/**
 *  处理下拉菜单点击事件
 *
 *  @param index 点击菜单编号
 */
- (void)operateDropDownMenu:(NSInteger)index{
    switch (index) {
        case 0:
        {
            RATTipsView *tipsView = [RATTipsView sharedManager];
            if (!tipsView.isShowing) {
                tipsView.labelView.text = @"日程已分享";
                [tipsView show];
            }
            
        }
            break;
        case 1:
        {
            RATTipsView *tipsView = [RATTipsView sharedManager];
            if (!tipsView.isShowing) {
                tipsView.labelView.text = @"日程已收藏";
                [tipsView show];
            }
        }
            break;
        default:
            break;
    }
}
/**
 *  处理操作状态菜单点击事件
 *
 *  @param index 点击菜单编号
 */
- (void)operateStateMenu:(NSInteger)index{
    if (self.event.state.intValue == kEventStateCancelled || self.event.state.intValue == kEventStateComplete || (self.event.state.intValue == kEventStateAdjusted && index != 0)) {
        return;
    }
    
    switch (index) {
        case 0:
        {
            if (self.event.state.intValue == kEventStateAdjusted) {
                OBODetailScheController *detailVc = [[OBODetailScheController alloc]init];
                
                //    calendarVc.row =
                detailVc.event = self.event.adjustToEvent;
                detailVc.delegate = self;
                [self.navigationController pushViewController:detailVc animated:YES];
                
            }
            else {
                // 弹出修改页面
                OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:self.event];
                newScheController.delegete = self;
                newScheController.sheduleModel = [self.event mutableCopy];
                newScheController.operationType = kAdjustSchedule;
                [self.navigationController pushViewController:newScheController animated:YES];
            }
        }
            break;
        case 1:
        {
            Events *target = [self.event mutableCopy];
            //        Events *target = [[Events alloc]init];
            //        [target evaluateWithEvent:event];
            target.state = @(kEventStateCancelled);
            
            [self updateDataWithEvent:self.event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
                NSLog(@"%s",__func__);
                if (result) {
                    RATTipsView *tipsView = [RATTipsView sharedManager];
                    if (!tipsView.isShowing) {
                        tipsView.labelView.text = @"日程已取消";
                        [tipsView show];
                    }
                    // 修改event结果
                    //                    [self.stateIconView removeTarget:self action:@selector(stateIconClick:) forControlEvents:UIControlEventTouchUpInside];
                }
            }];
        }
            break;
        case 2:
        {
            Events *target = [self.event mutableCopy];
            //        Events *target = [[Events alloc]init];
            //        [target evaluateWithEvent:event];
            target.state = @(kEventStateComplete);
            
            [self updateDataWithEvent:self.event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
                NSLog(@"%s",__func__);
                if (result) {
                    RATTipsView *tipsView = [RATTipsView sharedManager];
                    if (!tipsView.isShowing) {
                        tipsView.labelView.text = @"日程已完成";
                        [tipsView show];
                    }
                    // 修改event结果
                    //                    [self.stateIconView removeTarget:self action:@selector(stateIconClick:) forControlEvents:UIControlEventTouchUpInside];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- OBOOperateDataDelegate


- (void)updateDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
    if ([self.delegate respondsToSelector:@selector(updateDataWithEvent:targetEvent:result:)]) {
        
        [self.delegate updateDataWithEvent:event targetEvent:targetEvent result:^(BOOL result, kInsertDataResult insertResult) {
            if (result) {
                self.showEndTimeViewAnimate = NO;
                [[OBODataBase sharedManager] queryEventsWithId:self.event.ID resultList:^(Events *event) {
                    self.event = event;
                }];
            }
            resultBlock(result, insertResult);
        }];
        //        resultBlock(YES,0);
        // 删除数据
        //        if ([event.startDate compare:[NSDate currentDate]] == NSOrderedAscending) {
        
    }
    else{
        resultBlock(NO,0);
    }
}

- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent currentPage:(BOOL)currentPage result:(boolResult)resultBlock{
    if ([self.delegate respondsToSelector:@selector(adjustDataWithEvent:targetEvent:result:)]) {
        [self.delegate adjustDataWithEvent:event targetEvent:targetEvent result:^(BOOL result, kInsertDataResult insertResult) {
            if (result) {
                self.showEndTimeViewAnimate = NO;
                event.state = @(kEventStateAdjusted);
                //                [self.scheTableView reloadData];
                if (self.event.ID.intValue == event.ID.intValue) {
                    self.event = event;
                }
                if (self.event.ID.intValue == targetEvent.ID.intValue) {
                    self.event = targetEvent;
                }
                resultBlock(YES, 0);
                if (currentPage) {
                    RATTipsView *tipsView = [RATTipsView sharedManager];
                    if (!tipsView.isShowing) {
                        tipsView.labelView.text = @"日程已调整";
                        [tipsView show];
                    }
                }
            }
        }];
    }
    else{
        resultBlock(NO,0);
        if (currentPage) {
            RATTipsView *tipsView = [RATTipsView sharedManager];
            if (!tipsView.isShowing) {
                tipsView.labelView.text = @"调整失败";
                [tipsView show];
            }
        }
    }
}

- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
    [self adjustDataWithEvent:event targetEvent:targetEvent currentPage:NO result:resultBlock];
}
@end
