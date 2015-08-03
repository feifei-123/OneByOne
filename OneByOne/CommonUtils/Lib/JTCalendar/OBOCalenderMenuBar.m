//
//  OBOCalenderMenuBar.m
//  TestJTCalender
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOCalenderMenuBar.h"
#import "UIColor+Hex.h"
#import<QuartzCore/QuartzCore.h>

@interface OBOCalenderMenuBar()
@property(nonatomic,strong)UIImageView*bgImageView;

@end

@implementation OBOCalenderMenuBar

-(instancetype)init{
    self = [super init];
    if(self){
        [self loadSubViews];
        [self initConstraints];
    }
    return self;
}
-(void)loadSubViews{

    self.bgImageView = [[UIImageView alloc]init];
    self.bgImageView.image = [UIImage imageNamed:@"calender_covering_head"];
    [self addSubview:self.bgImageView];
    
    self.leftBtn = [[UIButton alloc]init];
    [self.leftBtn setImage:[UIImage imageNamed:@"calender_leftBtn"] forState:UIControlStateNormal];
    [self.leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleBtn = [[UIButton alloc]init];
    [self.titleBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff" alpha:1.0] forState:UIControlStateNormal];
    self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    //加阴影
    [self.titleBtn setTitleShadowColor:[UIColor colorWithHexString:@"#b9944b" alpha:1.0] forState:UIControlStateNormal];
    [self.titleBtn setTitleShadowOffset:CGSizeMake(1, 1)];
    [self.titleBtn addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    
   
    
    
    self.rightBtn = [[UIButton alloc]init];
    [self.rightBtn setImage:[UIImage imageNamed:@"calender_rightBtn"] forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.leftBtn];
    [self addSubview:self.titleBtn];
    [self addSubview:self.rightBtn];
    
    self.backgroundColor = [UIColor clearColor];
    
}
-(void)initConstraints{

    [self.bgImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.leftBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rightBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *containerViews = NSDictionaryOfVariableBindings(_leftBtn,_titleBtn,_rightBtn,_bgImageView);
    NSString *vfl_11 = @"H:|-25-[_leftBtn(38)][_titleBtn][_rightBtn(38)]-25-|";
    NSString *vfl_12 = @"V:|[_leftBtn(_titleBtn)]";
    NSString *vfl_13 = @"V:|[_titleBtn(_rightBtn)]";
    NSString *vfl_14 = @"V:|[_rightBtn]|";
    
    NSString *vfl_15 = @"H:|[_bgImageView]|";
    NSString *vfl_16 = @"V:|[_bgImageView]|";
    
    NSLayoutConstraint *layoutH = [NSLayoutConstraint constraintWithItem:_titleBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_11 options:0 metrics:nil views:containerViews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_12 options:0 metrics:nil views:   containerViews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_13 options:0 metrics:nil views:   containerViews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_14 options:0 metrics:nil views:   containerViews]];
    [self addConstraint:layoutH];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_15 options:0 metrics:nil views:   containerViews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_16 options:0 metrics:nil views:   containerViews]];

}

-(void)leftBtnClicked:(id)sender{

    NSLog(@"点击了 上一个月");
    if (self.delegate!=nil) {
        [self.delegate CalenderMenuLeftBtnClicked:nil];
    }
}

-(void)titleBtnClicked:(id)sender{
    
    NSLog(@"点击了 title");
    if (self.delegate!=nil) {
        [self.delegate CalenderMenuTitleBtnClicked:nil];
    }
}

-(void)rightBtnClicked:(id)sender{
    
    NSLog(@"点击了 下一个月");
    if (self.delegate!=nil) {
        [self.delegate CalenderMenuRightBtnClicked:nil];
    }
}


-(void)setCurrentDate:(NSDate*)currentDate{
    NSDateFormatter * fomamtter = [[NSDateFormatter alloc]init];
    //fomamtter.dateFormat = @"yyyy-MM";
    fomamtter.dateFormat = @"MMMM . yyyy";
    NSString*title =[fomamtter stringFromDate:currentDate];
    
    //此处定制日期格式:
    [self.titleBtn setTitle:title forState:UIControlStateNormal];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
