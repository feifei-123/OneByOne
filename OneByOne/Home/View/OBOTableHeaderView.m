//
//  OBOTableHeaderView.m
//  OneByOne
//
//  Created by macbook on 15-6-15.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOTableHeaderView.h"
#import "UIImage+stretch.h"
#import "Constants.h"

@interface OBOTableHeaderView()

@property (nonatomic, strong) UIImageView *bgImageView;

//@property (nonatomic, strong) OBONoHLButton *btnView;



@end

@implementation OBOTableHeaderView



- (OBOTableHeaderButton *)btnView{

    if (_btnView == nil) {
        _btnView = [OBOTableHeaderButton buttonWithType:UIButtonTypeCustom];
        _btnView.translatesAutoresizingMaskIntoConstraints = NO;
        _btnView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _btnView.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        _btnView.contentEdgeInsets = UIEdgeInsetsMake(6, 10, 0, 0);

        [_btnView setImage:[UIImage imageNamed:@"overdue_dropdown_btn_normal"] forState:UIControlStateNormal];

        _btnView.titleLabel.font = kFont(12);
        [_btnView addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnView];
        
        NSDictionary *dict = NSDictionaryOfVariableBindings(_btnView);
        NSString *vfl1 = @"|-0-[_btnView]-0-|";
        NSString *vfl2 = @"V:|-0-[_btnView]-0-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict]];
    }
    return _btnView;
}

- (void)setDateType:(kHeadViewDate)dateType{
    _dateType = dateType;
    
    [self.btnView setBackgroundImage:[UIImage imageNamed:dateType==kHeadViewDateCurrent ? @"overdue_currentdate" : @"overdue_otherdate"] forState:UIControlStateNormal];
    
    if(_dateType ==kHeadViewDateCurrent){//当天
        _btnView.titleLabel.font = kTableHeaderFont;
        [_btnView setTitleColor:kCurrentTableHeaderColor forState:UIControlStateNormal];
    }else{//非当天
        _btnView.titleLabel.font = kTableHeaderFont;
        [_btnView setTitleColor:kOthersTableHeaderColor forState:UIControlStateNormal];
    }
}

- (void)setDate:(NSString *)date{
    _date = date;
    [self.btnView setTitle:date forState:UIControlStateNormal];
}

- (void)headerViewWithDateType:(kHeadViewDate)dateType date:(NSString *)date section:(NSInteger)section{
    self.dateType = dateType;
    self.date = date;
    self.btnView.tag = section;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        
        _bgImageView = [[UIImageView alloc]init];
        _bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bgImageView.image = [UIImage imageWithStretch:@"overdue_dateinfo_normal"];
        [self addSubview:_bgImageView];
    
        
        NSDictionary *dict = NSDictionaryOfVariableBindings(_bgImageView);
        NSString *vfl1 = @"H:|-0-[_bgImageView]-0-|";
        NSString *vfl2 = @"V:|-0-[_bgImageView]-0-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict]];
   
    }
    return self;
}

- (void)btnClick:(UIButton *)btn{
    
    if ([self.delegate respondsToSelector:@selector(headerView:section:)]) {
        [self.delegate headerView:self section:btn.tag];
    }
    
    
}



@end
