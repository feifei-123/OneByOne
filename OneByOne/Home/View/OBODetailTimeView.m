//
//  OBODetailTimeView.m
//  OneByOne
//
//  Created by macbook on 15-6-20.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBODetailTimeView.h"
#import "NSDate+helper.h"
#import "UIFont+custom.h"
#import "Constants.h"
#import "OBOStringTools.h"

#define kWeatherWidth   30

//#define KColor_867b6a kColor(134, 123, 106)
//
//#define kFirstStartTimeX         20
//#define kFirstStartTimeY         53
//#define kFirstStartTimeWidth     45
//#define kFirstStartTimeHeight    18

//#define k

@interface OBODetailTimeView()

@property (nonatomic, strong) UILabel *monthView;
@property (nonatomic, strong) UILabel *weekView;
@property (nonatomic, strong) UILabel *timeView;
@property (nonatomic, strong) UIImageView *weatherView;
@property (nonatomic, strong) UILabel *dayView;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSLayoutConstraint *weatherConstraint;

@property (nonatomic, assign) BOOL isSche;

@end

@implementation OBODetailTimeView

- (void)setType:(kTimeViewType)type{
    _type = type;
    self.weatherConstraint.constant = (_type == kTimeViewTypeTime ? 0 : kWeatherWidth);
}

- (void)weatherViewWithImage:(UIImage *)icon temp1:(int)temp1 temp2:(int)temp2{
    self.weatherView.image = icon;
    self.timeView.text = [NSString stringWithFormat:@"%d℃~%d℃",temp1,temp2];
}

- (void)setDate:(NSDate *)date{
    _date = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat  = @"yyyy.MM";
    
//    return [df dateFromString: time];
    self.monthView.text = [df stringFromDate:self.date];
    df.dateFormat  = @"HH:mm";
    if (self.type == kTimeViewTypeTime) {
        if (!self.isSche) {
            self.timeView.text = @"全天";
        }
        else{
            self.timeView.text = [df stringFromDate:self.date];
        }
    }
    df.dateFormat = @"dd";
    self.dayView.text = [df stringFromDate:self.date];
    df.dateFormat = @"EEEE";
    self.weekView.text = [df stringFromDate:self.date];
}

- (instancetype)init{
    if (self = [super init]) {
        [self addViews];
        [self addMyConstraints];
    }
    return self;
}

- (void)awakeFromNib{
    [self addViews];
    [self addMyConstraints];
}

/**
 *  添加子视图
 */
- (void)addViews{
    self.monthView = [[UILabel alloc]init];
    self.monthView.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthView.textAlignment = NSTextAlignmentRight;
//    [[NSBundle mainBundle]pathForResource:@"STEELFISH BD.OTF" ofType:nil];
//    NSError *error = nil;
//    NSString *str=[NSString stringWithContentsOfFile:@"/Documents/STEELFISH BD.OTF" encoding:NSUTF8StringEncoding error:&error];
    self.monthView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH BD.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:23];//kFont(18);
    self.monthView.textColor = kColor_837963;
    self.monthView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.monthView];
    self.weekView = [[UILabel alloc]init];
    self.weekView.translatesAutoresizingMaskIntoConstraints = NO;
    self.weekView.textAlignment = NSTextAlignmentRight;
    self.weekView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH BD.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:23];
    self.weekView.textColor = kColor_837963;
    self.weekView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.weekView];
    
    self.weatherView = [[UIImageView alloc]init];
    self.weatherView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.weatherView];
    self.timeView = [[UILabel alloc]init];
    self.timeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeView.textAlignment = NSTextAlignmentRight;
    self.timeView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH BD.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:23];
    self.timeView.textColor = kColor_837963;
    self.timeView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.timeView];
    self.dayView = [[UILabel alloc]init];
    self.dayView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dayView.textAlignment = NSTextAlignmentRight;
    self.dayView.font = [UIFont customFontWithPath:[[NSBundle mainBundle]pathForResource:@"STEELFISH RG.OTF" ofType:nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     size:80];
    self.dayView.textColor = kColor_5f513f;
    self.dayView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.dayView];
}

/**
 *  添加约束
 */
- (void)addMyConstraints{
    NSDictionary *dict = NSDictionaryOfVariableBindings(_monthView,_weekView,_timeView,_dayView,_weatherView);
    // day的位置
    NSString *vfl1 = @"V:|-0-[_dayView]-0-|";
    NSString *vfl2 = @"|-0-[_monthView]-0-[_dayView(56)]-0-|";
    NSString *vfl3 = @"V:|-0-[_monthView]-0-[_weekView(_monthView)]-0-[_timeView(_monthView)]-0-|";
    NSString *vfl4 = @"|-0-[_weekView]-0-[_dayView]";
    NSString *vfl5 = @"|-0-[_weatherView]-0-[_timeView]-0-[_dayView]";
    
    self.weatherConstraint = [NSLayoutConstraint constraintWithItem:self.weatherView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4 options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl5 options:0 metrics:nil views:dict]];
    [self addConstraint:self.weatherConstraint];
}

- (void)timeViewWithDay:(NSDate *)day time:(NSDate *)time{
//    if (!time) {
//        self.date = [NSDate dateWithDay:day time:time];
//    }
//    else{
    if (!time) {
        self.isSche = NO;
    }
    else{
        self.isSche = YES;
    }
        self.date = [NSDate dateWithDay:day time:time];
//    }
}
- (void)timeViewWithDate:(NSDate *)date{
    self.isSche = YES;
    self.date = date;
}

@end
