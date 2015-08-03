//
//  OBOHomeHeadView.m
//  OneByOne
//
//  Created by macbook on 15-4-29.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import "OBOHomeHeadView.h"
#import "OBODetailTimeView.h"
#import "OBONoHLButton.h"
#import "UIImage+stretch.h"
#import "UIFont+custom.h"
#import "Constants.h"

@interface OBOHomeHeadView()
@property (weak, nonatomic) IBOutlet UIButton *iconView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UILabel *weekView;
@property (weak, nonatomic) IBOutlet UILabel *dateView;
@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (weak, nonatomic) IBOutlet OBONoHLButton *todayView;
@property (weak, nonatomic) IBOutlet OBONoHLButton *tomorrowView;
@property (weak, nonatomic) IBOutlet OBONoHLButton *postnatalView;


@end

@implementation OBOHomeHeadView

- (void)weatherViewWithImage:(UIImage *)icon temp1:(int)temp1 temp2:(int)temp2{
    self.weatherView.image = icon;
    self.tempView.text = [NSString stringWithFormat:@"%d~%d℃",temp1,temp2];
}

- (void)setDate:(NSDate *)date{
    _date = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"yyyy.MM";
    
    //    return [df dateFromString: time];
    self.timeView.text = [df stringFromDate:self.date];
    df.dateFormat  = @"HH:mm";
    df.dateFormat = @"dd";
    self.dateView.text = [df stringFromDate:self.date];
    df.dateFormat = @"EEEE";
    self.weekView.text = [OBOStringTools cTransformFromE:[df stringFromDate:self.date]];
}

- (void)selectedBtnIndex:(NSInteger)index{
    switch (index) {
        case 0:
            self.todayView.selected = YES;
//            self.todayView.titleLabel.font = [UIFont systemFontOfSize:14];
            self.tomorrowView.selected = NO;
//            self.tomorrowView.titleLabel.font = [UIFont systemFontOfSize:12];
            self.postnatalView.selected = NO;
//            self.postnatalView.titleLabel.font = [UIFont systemFontOfSize:12];
            break;
        case 1:
            self.todayView.selected = NO;
//            self.todayView.titleLabel.font = [UIFont systemFontOfSize:12];
            self.tomorrowView.selected = YES;
//            self.tomorrowView.titleLabel.font = [UIFont systemFontOfSize:14];
            self.postnatalView.selected = NO;
//            self.postnatalView.titleLabel.font = [UIFont systemFontOfSize:12];
            break;
        case 2:
            self.todayView.selected = NO;
//            self.todayView.titleLabel.font = [UIFont systemFontOfSize:12];
            self.tomorrowView.selected = NO;
//            self.tomorrowView.titleLabel.font = [UIFont systemFontOfSize:12];
            self.postnatalView.selected = YES;
//            self.postnatalView.titleLabel.font = [UIFont systemFontOfSize:14];
            break;
            
        default:
            break;
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickCalendar)];
    
    self.timeView.textColor = kColor_837963;
    self.timeView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH RG.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:22];
    self.weekView.textColor = kColor_837963;
    self.weekView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH RG.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:22];
    self.tempView.textColor = kColor_837963;
    self.tempView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH RG.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:22];
    self.dateView.textColor = kColor_5f513f;
    self.dateView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH BD.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:106];
    
    [self.todayView setBackgroundImage:[UIImage imageWithStretch:@"stateview_righttab_normal"] forState:UIControlStateNormal];
    [self.todayView setBackgroundImage:[UIImage imageWithStretch:@"stateview_righttab_selected"] forState:UIControlStateSelected];
    [self.todayView setTitleColor:kColorA(131, 121, 99, 0.4) forState:UIControlStateNormal];
    [self.todayView setTitleColor:kColor(131, 121, 99) forState:UIControlStateSelected];
    self.todayView.contentEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0);
    self.todayView.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [self.tomorrowView setBackgroundImage:[UIImage imageWithStretch:@"stateview_righttab_normal"] forState:UIControlStateNormal];
    [self.tomorrowView setBackgroundImage:[UIImage imageWithStretch:@"stateview_righttab_selected"] forState:UIControlStateSelected];
    
    
    [self.tomorrowView setTitleColor:kColorA(131, 121, 99, 0.4) forState:UIControlStateNormal];
    [self.tomorrowView setTitleColor:kColor(131, 121, 99) forState:UIControlStateSelected];
    self.tomorrowView.contentEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0);
    self.tomorrowView.titleLabel.font = kFont(14);
    
    [self.postnatalView setBackgroundImage:[UIImage imageWithStretch:@"stateview_righttab_normal"] forState:UIControlStateNormal];
    [self.postnatalView setBackgroundImage:[UIImage imageWithStretch:@"stateview_righttab_selected"] forState:UIControlStateSelected];
    
    [self.postnatalView setTitleColor:kColorA(131, 121, 99, 0.4) forState:UIControlStateNormal];
    [self.postnatalView setTitleColor:kColor(131, 121, 99) forState:UIControlStateSelected];
    self.postnatalView.contentEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0);
    self.postnatalView.titleLabel.font = kFont(14);
    
    [self.calendarView addGestureRecognizer:tap];
}

/**
 *  设置头像图标
 *
 *  @param icon 头像图标字符串
 */
- (void)iconWithName:(NSString *)icon{
    
    [self.iconView setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [self.iconView addTarget:self action:@selector(iconViewclick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.iconView setImage:[UIImage imageNamed:@"home_photo"] forState:UIControlStateNormal];
//    self.iconView.layer.masksToBounds = YES;
//    self.iconView.layer.cornerRadius = self.iconView.bounds.size.width / 2;
//    self.iconView.layer.borderColor = [UIColor grayColor].CGColor;
//    self.iconView.layer.borderWidth = 3;
    
}
/**
 *  当iconview被点击时调用该方法
 */
- (void)iconViewclick{
    if ([self.delegate respondsToSelector:@selector(homeHeadView:iconClick:)]) {
        [self.delegate homeHeadView:self iconClick:self.iconView];
    }
}

/**
 *  当calendarView被点击时调用该方法
 */
- (void)clickCalendar{
    if ([self.delegate respondsToSelector:@selector(homeHeadView:calendarClick:)]) {
        [self.delegate homeHeadView:self calendarClick:self.calendarView];
    }
}

/**
 *  当今天，明天，后天按钮被点击时调用该方法
 */
- (IBAction)clickDateButton:(UIButton *)sender {
    
    [self selectedBtnIndex:sender.tag];
    
    if ([self.delegate respondsToSelector:@selector(homeHeadView:dateButtonClick:)]) {
        [self.delegate homeHeadView:self dateButtonClick:sender];
    }
}

@end
