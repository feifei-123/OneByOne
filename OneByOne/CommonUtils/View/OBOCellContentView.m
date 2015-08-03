//
//  OBOCellContentView.m
//  OneByOne
//
//  Created by macbook on 15-5-2.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import "OBOCellContentView.h"
#import "RATVerticalLabel.h"
#import "Events.h"
#import "OBOStringTools.h"
#import "Constants.h"
#import "UIImage+stretch.h"

//#define kFirstStartTimeX         20
//#define kFirstStartTimeY         53
//#define kFirstStartTimeWidth     45
//#define kFirstStartTimeHeight    18
#define kFirstStartTimeX         20
#define kFirstStartTimeY         51
#define kFirstStartTimeWidth     45
#define kFirstStartTimeHeight    18

//#define kStartTimeX         20
//#define kStartTimeY         20
//#define kStartTimeWidth     45
//#define kStartTimeHeight    18
#define kStartTimeX         20
#define kStartTimeY         18
#define kStartTimeWidth     45
#define kStartTimeHeight    18

//#define kEndTimeX           20
//#define kEndTimeY           74
//#define kEndTimeHeight      12
//#define kEndTimeWidth       45
#define kEndTimeX           20
#define kEndTimeY           72
#define kEndTimeHeight      12
#define kEndTimeWidth       45

//#define kTitleX           120
//#define kFirstTitleY      53
//#define kTitleY           20
//#define kTitleHeight      230
//#define kTitleWidth       18
#define kTitleX           120
#define kFirstTitleY      51
#define kTitleY           18
#define kTitleHeight      18
#define kTitleWidth       230

//#define kStateTypeX           85
//#define kFirstStateTypeY      55
//#define kStateTypeY           22
//#define kStateTypeHeight      16
//#define kStateTypeWidth       16

#define kStateTypeX           85
#define kFirstStateTypeY      53
#define kStateTypeY           20
#define kStateTypeHeight      16
#define kStateTypeWidth       16

//#define kContentX           136
//#define kContentY           83
//#define kContentHeight      210
//#define kContentWidth       46
#define kContentX           136
#define kContentY           81
#define kContentHeight      46
#define kContentWidth       210

#define kStateViewWidth     60
#define kStateViewHeight    56

@interface OBOCellContentView()
@property (nonatomic, strong) UILabel *startTimeView;
//@property (nonatomic, strong) UILabel *endTimeView;
@property (nonatomic, strong) UIImageView *stateTypeView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) RATVerticalLabel *contentView;
@property (nonatomic, strong) UILabel *endTimeView;

@end

@implementation OBOCellContentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImageView *)bgImageView{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]init];
        _bgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UILabel *)startTimeView{
    if (_startTimeView == nil) {
        _startTimeView = [[UILabel alloc]init];
//        _startTimeView.numberOfLines = 0;
        _startTimeView.textAlignment = NSTextAlignmentRight;
        [self addSubview:_startTimeView];
    }
    return _startTimeView;
}

- (UILabel *)endTimeView{
    if (_endTimeView == nil) {
        _endTimeView = [[UILabel alloc]init];
        _endTimeView.textAlignment = NSTextAlignmentRight;
//        _endTimeView.numberOfLines = 0;
        [self addSubview:_endTimeView];
    }
    return _endTimeView;
}

- (UIImageView *)stateTypeView{
    if (_stateTypeView == nil) {
        _stateTypeView = [[UIImageView alloc]init];
        [self addSubview:_stateTypeView];
    }
    return _stateTypeView;
}

- (UILabel *)titleView{
    if (_titleView == nil) {
        _titleView = [[UILabel alloc]init];
//        _titleView.numberOfLines = 0;
        [self addSubview:_titleView];
    }
    return _titleView;
}

- (RATVerticalLabel *)contentView{
    if (_contentView == nil) {
        _contentView = [[RATVerticalLabel alloc]init];
        _contentView.verticalAlignment = VerticalAlignmentTop;
        _contentView.numberOfLines = 0;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)stateView{
    if (_stateView == nil) {
        _stateView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stateView addTarget:self action:@selector(stateViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_stateView];
    }
    return _stateView;
}

- (UIImageView *)iconView{
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc]init];
        [self addSubview:_iconView];
    }
    return _iconView;
}

- (void)setEvent:(Events *)event{
    
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat imageX = 0;//kPadding / 2;
    CGFloat imageY = 0;//kPadding / 2;
    CGFloat imageW = [UIScreen mainScreen].bounds.size.width ;//- kPadding;
    CGFloat imageH = self.isFirstCell ? kFirstCellHeight : kCellHeight;//- kPadding;
    
    _event = event;
    
    
    self.bgImageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    //self.bgImageView.image = [UIImage imageWithStretch:(self.isFirstCell ? @"cell_firstcellbg_normal" : @"cell_cellbg_normal")];
    
    
    if (event.classify.intValue == kEventClassifySche) {
        
        self.iconView.frame = CGRectMake(0, 0, 0, 0);
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        df.dateFormat = @"HH:mm";
        
        
        if (self.isFirstCell) {
            self.startTimeView.frame = CGRectMake(kFirstStartTimeX, kFirstStartTimeY, kFirstStartTimeWidth, kFirstStartTimeHeight);
//            self.startTimeView.backgroundColor = [UIColor greenColor];
            self.startTimeView.font = kFont(16);
            self.endTimeView.frame = CGRectMake(kEndTimeX, kEndTimeY, kEndTimeWidth, kEndTimeHeight);
            self.endTimeView.text = [df stringFromDate:event.endTime];
            self.endTimeView.font = kFont(12);
            self.endTimeView.textColor = KColor_867b6a;
//            self.endTimeView.backgroundColor = [UIColor greenColor];
        }
        else{
            self.startTimeView.frame = CGRectMake(kStartTimeX, kStartTimeY, kStartTimeWidth, kStartTimeHeight);
            self.startTimeView.font = kFont(14);
            self.endTimeView.frame = CGRectMake(0, 0, 0, 0);
        }
        
        
//        self.startTimeView.frame = eventFrame.startTimeF;
        self.startTimeView.text = [df stringFromDate:event.startTime];
        
        self.startTimeView.textColor = self.isFirstCell ? kColor_5f513f : KColor_998e7f;
        
//        self.startTimeView.numberOfLines = 0;
        
//        self.stateTypeView.frame = eventFrame.stateTypeF;
        self.stateTypeView.image = [OBOStringTools smallImageWithEventType:event.type.intValue];
        self.stateTypeView.frame = CGRectMake(kStateTypeX, self.isFirstCell ? kFirstStateTypeY : kStateTypeY, kStateTypeWidth, kStateTypeHeight);
        
        if (self.hasState && !self.isFirstCell) {
            self.stateView.frame = CGRectMake(kScreenWidth - kStateViewWidth - 4, 0, kStateViewWidth, kStateViewHeight);//eventFrame.stateF;
            
            [self.stateView setImage:[OBOStringTools imageWithEventState:event.state.intValue] forState:UIControlStateNormal];
            [self.stateView setBackgroundImage:[UIImage imageNamed:@"cell_stateView_bgImage_normal"] forState:UIControlStateNormal];
//            [self.stateView setImage:[UIImage imageNamed:@"cell_stateView_bgImage_normal"] forState:UIControlStateNormal];
//            self.stateView.backgroundColor = [UIColor greenColor];
        }
        else {
            self.stateView.frame = CGRectMake(0, 0, 0, 0);
        }
        
        
//        if (eventFrame.event.endTime) {
//            self.endTimeView.frame = eventFrame.endTimeF;
//            self.endTimeView.text = [df stringFromDate:eventFrame.event.endTime];
//            self.endTimeView.font = kSmallFont;
//            self.endTimeView.textColor = kSmallColor;
////            self.endTimeView.numberOfLines = 0;
//        }
//        else{
//            self.endTimeView.frame = CGRectMake(0, 0, 0, 0);
//        }
        
//        self.titleView.frame = eventFrame.titleF;
        self.titleView.frame = CGRectMake(kTitleX, self.isFirstCell ? kFirstTitleY : kTitleY, kTitleWidth, kTitleHeight);
//        self.titleView.backgroundColor = [UIColor greenColor];
        self.titleView.text = event.title;
        self.titleView.font = self.isFirstCell ? kFont(18) : kFont(14);
        self.titleView.textColor = self.isFirstCell ? kColor_5f513f : KColor_998e7f;
        self.titleView.textAlignment = NSTextAlignmentLeft;
        
//        self.titleView.numberOfLines = 0;
        
        if (self.isFirstCell) {
//            self.contentView.frame = eventFrame.subTitleF;
            self.contentView.frame = CGRectMake(kContentX, kContentY, kContentWidth, kContentHeight);
//            self.contentView.backgroundColor = [UIColor greenColor];
            self.contentView.text = event.content;
            self.contentView.font = kFont(12);
            self.contentView.textColor = KColor_867b6a;
//            self.contentView.numberOfLines = 0;
        }
        else{
            self.contentView.frame = CGRectMake(0, 0, 0, 0);
        }
        
        
        self.bgImageView.image = [UIImage imageWithStretch:(self.isFirstCell ? @"cell_firstcellbg_normal" : @"cell_cellbg_normal")];
        self.bgImageView.alpha = 1.0;
    }
    else if (event.classify.intValue == kEventClassifyEvent){

        //
        self.stateTypeView.frame = CGRectMake(0, 0, 0, 0);
//        self.endTimeView.frame = CGRectMake(0, 0, 0, 0);
        self.titleView.frame = CGRectMake(0, 0, 0, 0);
        self.contentView.frame = CGRectMake(0, 0, 0, 0);
        
//        self.iconView.frame = eventFrame.iconF;
        self.iconView.image = [UIImage imageNamed:@"avatar_default"];
//        self.titleView.frame = eventFrame.titleF;
        self.titleView.text = event.title;
        self.titleView.font = kSmallFont;
        self.titleView.textColor = kSmallColor;
        self.stateTypeView.image = [OBOStringTools smallImageWithEventType:event.type.intValue];
        self.stateTypeView.frame = CGRectMake(kStateTypeX, self.isFirstCell ? kFirstStateTypeY : kStateTypeY, kStateTypeWidth, kStateTypeHeight);
        
        self.startTimeView.frame = CGRectMake(kStartTimeX - 20, kStartTimeY, kEndTimeWidth + 20, kEndTimeHeight + 10);
        self.startTimeView.text = @"全 天";
        self.startTimeView.font = kFont(14);
        self.startTimeView.textColor = KColor_867b6a;
        
        if (self.hasState) {
            self.stateView.frame = CGRectMake(kScreenWidth - kStateViewWidth - 4, 0, kStateViewWidth, kStateViewHeight);//eventFrame.stateF;
            
            [self.stateView setImage:[OBOStringTools imageWithEventState:event.state.intValue] forState:UIControlStateNormal];
            [self.stateView setBackgroundImage:[UIImage imageNamed:@"cell_stateView_bgImage_normal"] forState:UIControlStateNormal];
            //            [self.stateView setImage:[UIImage imageNamed:@"cell_stateView_bgImage_normal"] forState:UIControlStateNormal];
            //            self.stateView.backgroundColor = [UIColor greenColor];
        }
        
        
        //        if (eventFrame.event.endTime) {
        //            self.endTimeView.frame = eventFrame.endTimeF;
        //            self.endTimeView.text = [df stringFromDate:eventFrame.event.endTime];
        //            self.endTimeView.font = kSmallFont;
        //            self.endTimeView.textColor = kSmallColor;
        ////            self.endTimeView.numberOfLines = 0;
        //        }
        //        else{
        //            self.endTimeView.frame = CGRectMake(0, 0, 0, 0);
        //        }
        
        //        self.titleView.frame = eventFrame.titleF;
        self.titleView.frame = CGRectMake(kTitleX, self.isFirstCell ? kFirstTitleY : kTitleY, kTitleWidth, kTitleHeight);
        //        self.titleView.backgroundColor = [UIColor greenColor];
        self.titleView.text = event.title;
        self.titleView.font = self.isFirstCell ? kFont(18) : kFont(14);
        self.titleView.textColor = self.isFirstCell ? kColor_5f513f : KColor_998e7f;
        self.titleView.textAlignment = NSTextAlignmentLeft;
        
         self.bgImageView.image = [UIImage imageWithStretch:(self.isFirstCell ? @"cell_firstcellbg_normal" : @"cell_cellbg_normal")];
        self.bgImageView.alpha = 1.0;
    }
    else if (event.classify.intValue == kEventClassifyNone){
        self.stateTypeView.frame = CGRectMake(0, 0, 0, 0);
        self.startTimeView.frame = CGRectMake(0, 0, 0, 0);
        //        self.endTimeView.frame = CGRectMake(0, 0, 0, 0);
        self.contentView.frame = CGRectMake(0, 0, 0, 0);
        
        //        self.iconView.frame = eventFrame.iconF;
        self.iconView.image = nil;
        //        self.titleView.frame = eventFrame.titleF;
        self.titleView.frame = CGRectMake(0,kTitleY, kScreenWidth, kTitleHeight);
        self.titleView.textAlignment = NSTextAlignmentCenter;
        self.titleView.text = @"今天没有日程";
        self.titleView.font = kFont(14);
        self.titleView.textColor = KColor_998e7f;
        self.stateView.frame = CGRectMake(0, 0, 0, 0);
        
        self.bgImageView.image = [UIImage imageWithStretch:@"cell_noSheduleCellbg_normal"];
        self.bgImageView.alpha = 0.5;
        
    }
    [self bringSubviewToFront:self.stateView];
}

- (void)stateViewClick{
    NSLog(@"%s",__func__);
}

-(void)setCellSelected{
    
    self.bgImageView.image = [UIImage imageNamed:@"cell_cellbg_selected"];
}

-(void)setCellUnSelected{
    
    self.bgImageView.image = [UIImage imageNamed:@"cell_cellbg_normal"];
}

@end
