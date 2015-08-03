//
//  OBOCalenderView.m
//  TestJTCalender
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOCalenderView.h"
#import "UIColor+Hex.h"

#define kTitleHeight 40   //日历标题栏 的默认高度
#define kHeaderHeight 40  //日历表头（星期一～星期日）的默认高度
#define kLeftMargin   30  //左边距
#define kRightMargin  30  //右边距
#define kBottomMargin 20  //底边距


@interface OBOCalenderView()
@property(nonatomic,strong) UIImageView*bgImageView;
@property(nonatomic,strong) NSMutableArray*layoutConstraintsArray;
@property(nonatomic,strong) NSLayoutConstraint *layoutCalenderHeight;
@end


@implementation OBOCalenderView
-(instancetype)init{
    self = [super init];
    
    if (self) {
        
        [self setCustomSizeParams];
        
        [self initSubViews];
        [self refreshConstraints];
        [self initCalender];
        
    }
    
    return self;
}


-(NSMutableArray*)layoutConstraintsArray{
    if (_layoutConstraintsArray==nil) {
        _layoutConstraintsArray = [[NSMutableArray alloc]init];
    }
    return _layoutConstraintsArray;
}

-(void)setCustomSizeParams{
   
    if (_calenderMenuBarHeight==0.0f) {
        _calenderMenuBarHeight = kTitleHeight;
    }
    
    if (_calenderHeaderHeight==0.0f) {
        _calenderHeaderHeight =kHeaderHeight;
       
    }
    
    if (_leftMargin==0.0f) {
        _leftMargin = kLeftMargin;
    }
    
    if(_rightMargin==0.0f){
        _rightMargin = kRightMargin;
    }
    
    if (_bottomMargin==0.0f) {
        _bottomMargin = kBottomMargin;
    }
    
    
}
-(void)setCalenderMenuBarHeight:(CGFloat)calenderMenuBarHeight{

    _calenderMenuBarHeight = calenderMenuBarHeight;
    [self refreshConstraints];
    
}

-(void)setCalenderHeaderHeight:(CGFloat)calenderHeaderHeight{
    _calenderHeaderHeight = calenderHeaderHeight;
     self.calendar.calendarAppearance.calenderHeaderHeight = _calenderHeaderHeight;
    [self refreshConstraints];
}
-(void)setLeftMargin:(CGFloat)leftMargin{

    _leftMargin = leftMargin;
    [self refreshConstraints];
    
}

-(void)setRightMargin:(CGFloat)rightMargin{

    _rightMargin = rightMargin;
    [self refreshConstraints];
    
}

-(void)setBottomMargin:(CGFloat)bottomMargin{
    
    _bottomMargin = bottomMargin;
    [self refreshConstraints];
}


-(NSDate*)currentDate{
    
    return self.calendar.currentDate;
}



//-(void)addUpDownSwipGesture{
//    
//    UISwipeGestureRecognizer * upDownSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeCalenderMode:)];
//    upDownSwipeGesture.direction =UISwipeGestureRecognizerDirectionUp;
//    [self addGestureRecognizer:upDownSwipeGesture];
//    
//}



-(void)addUpSwipGestureWith:(SEL)upSwipAction AndDownSwipAction:(SEL)downSwipAction{

    if (upSwipAction!=nil&&self.oboCalenderViewDelegete!=nil&&[self.oboCalenderViewDelegete respondsToSelector:upSwipAction]) {
        
        UISwipeGestureRecognizer * upSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self.oboCalenderViewDelegete action:upSwipAction];
        upSwipeGesture.direction =UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:upSwipeGesture];

    }
    
    if (downSwipAction!=nil&&self.oboCalenderViewDelegete!=nil&&[self.oboCalenderViewDelegete respondsToSelector:downSwipAction]) {
        
        UISwipeGestureRecognizer * downSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self.oboCalenderViewDelegete action:downSwipAction];
        downSwipeGesture.direction =UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:downSwipeGesture];

    }
    
    
}


-(void)initSubViews{
    
    //背景图片
    self.bgImageView = [[UIImageView alloc]init];
    [self addSubview:self.bgImageView];
   
    //界面元素
    self.OBOMenueBar = [[OBOCalenderMenuBar alloc]init];
    
    self.calendarMenuView = [[JTCalendarMenuView alloc]init];
    self.calendarContentView = [[JTCalendarContentView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.calendarMenuView.alpha = 0.0;
    
    [self addSubview:self.calendarMenuView];
    [self addSubview:self.calendarContentView];
    [self addSubview:self.OBOMenueBar];
    
    //self.calendarContentView.backgroundColor = [UIColor greenColor];

}
-(void)initCalender{
    
     self.calendar = [JTCalendar new];
    
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        
        //日历小方格 背景色的配置
        
        self.calendar.calendarAppearance.dayCircleRatio = 10.0 / 10.;
        self.calendar.calendarAppearance.dayBackgroundColor = [UIColor colorWithHexString:@"#f1f0e9" alpha:1.0];
        self.calendar.calendarAppearance.dayBorderColor = [UIColor colorWithHexString:@"#dedcda" alpha:1.0];
        self.calendar.calendarAppearance.dayBorderWidth = 1.0;
        //self.calendar.calendarAppearance.dayBackgroundImage = [UIImage imageNamed:@"day_normal"];
        self.calendar.calendarAppearance.dayCircleTodayImage = [UIImage imageNamed:@"day_current"];
        self.calendar.calendarAppearance.dayCircleTodayOtherMonthImage = [UIImage imageNamed:@"day_current"];
        self.calendar.calendarAppearance.dayCircleSelectedImage = [UIImage imageNamed:@"day_selected"];
         self.calendar.calendarAppearance.dayCircleSelectedOtherMonthImage = [UIImage imageNamed:@"day_selected"];
        
        //日历方格字体 的设置
        self.calendar.calendarAppearance.dayTextColor = [UIColor colorWithHexString:@"#5f513f" alpha:1.0];
        self.calendar.calendarAppearance.dayTextColorOtherMonth = [UIColor colorWithHexString:@"#867b6a" alpha:0.4];
        
        self.calendar.calendarAppearance.dayTextColorToday = [UIColor colorWithHexString:@"#5f513f" alpha:1.0];
        self.calendar.calendarAppearance.dayTextColorTodayOtherMonth = [UIColor colorWithHexString:@"#5f513f" alpha:1.0];
        
        self.calendar.calendarAppearance.dayTextColorSelected = [UIColor colorWithHexString:@"#ffffff" alpha:1.0];
        self.calendar.calendarAppearance.dayTextColorSelectedOtherMonth = [UIColor colorWithHexString:@"#ffffff" alpha:1.0];

        
        
        //事件小圆点 的配置
        
        self.calendar.calendarAppearance.dayDotRatio = 3.0 / 10.;
        self.calendar.calendarAppearance.dayDotImage = [UIImage imageNamed:@"calender_dot_event"];
        self.calendar.calendarAppearance.dayDotImageSelected = [UIImage imageNamed:@"calender_dot_event"];
        self.calendar.calendarAppearance.dayDotImageOtherMonth = [UIImage imageNamed:@"calender_dot_event"];
        self.calendar.calendarAppearance.dayDotImageSelectedOtherMonth = [UIImage imageNamed:@"calender_dot_event"];
        self.calendar.calendarAppearance.dayDotImageToday = [UIImage imageNamed:@"calender_dot_event"];
        self.calendar.calendarAppearance.dayDotImageTodayOtherMonth = [UIImage imageNamed:@"calender_dot_event"];
        
        //日历表头的 配置
        self.calendar.calendarAppearance.calenderHeaderHeight = self.calenderHeaderHeight;
        self.calendar.calendarAppearance.weekDayTextFont = [UIFont systemFontOfSize:12];
        self.calendar.calendarAppearance.weekDayTextColor = [UIColor colorWithHexString:@"#5f513f" alpha:1.0];
        
       
        
        
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        self.calendar.calendarAppearance.focusSelectedDayChangeMode = NO;
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%@. %ld ", monthText, comps.year];
        };
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    
    if (self.OBOMenueBar) {
        [self.calendar setOboMenuBar:self.OBOMenueBar];
        [self.OBOMenueBar setCurrentDate:self.calendar.currentDate];
    }
 
    
    [self.calendar reloadData];
    

}


-(void)refreshConstraints{

    [self.calendarMenuView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.calendarContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.OBOMenueBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bgImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    for (int i =0; i<self.layoutConstraintsArray.count; i++) {
        [self removeConstraints:[self.layoutConstraintsArray objectAtIndex:i]];
    }
    
    [self.layoutConstraintsArray removeAllObjects];
    
    
    //--------_OBOMenueBar 顶部菜单栏 的约束
    NSDictionary *containerViews = NSDictionaryOfVariableBindings(_OBOMenueBar,_calendarMenuView,_calendarContentView,_bgImageView);
    NSString *vfl_11 = @"H:|-0-[_OBOMenueBar]-0-|";
    NSString *vfl_12 =[NSString stringWithFormat: @"V:|[_OBOMenueBar(%f@750)]",self.calenderMenuBarHeight];
    
    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_11 options:0 metrics:nil views:containerViews]];

    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_12 options:0 metrics:nil views:   containerViews]];


    
    
    //--------_calendarMenuView 顶部菜单栏 的约束（被_OBOMenueBar覆盖住，不显示）
    NSString *vfl_B1 = @"H:|-0-[_calendarMenuView]-0-|";
    NSString *vfl_B2 = @"V:|[_calendarMenuView(_OBOMenueBar)]";
    
    
    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_B1 options:0 metrics:nil views:containerViews]];

    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_B2 options:0 metrics:nil views:   containerViews]];

    //--------_calendarContentView 的约束
    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|-(%f)-[_calendarContentView]-(%f)-|",self.leftMargin,self.rightMargin];
    NSString *vfl_C2 = [NSString stringWithFormat:@"V:[_OBOMenueBar][_calendarContentView]-(%f)-|",self.bottomMargin];
    
    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:containerViews]];
    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:   containerViews]];
    
    //bgImageView
    NSString *vfl_E1 = @"H:|-0-[_bgImageView]-0-|";
    NSString *vfl_E2 = @"V:|[_bgImageView]|";
    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_E1 options:0 metrics:nil views:containerViews]];
    [self.layoutConstraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_E2 options:0 metrics:nil views:   containerViews]];
    
    
    for (int i =0; i<self.layoutConstraintsArray.count; i++) {
        [self addConstraints:[self.layoutConstraintsArray objectAtIndex:i]];
    }
    
    
    
    if (self.layoutCalenderHeight!=nil) {
        [self removeConstraint:self.layoutCalenderHeight];
    }
    
    if (self.calendar.calendarAppearance.isWeekMode) {
        self.layoutCalenderHeight = [NSLayoutConstraint constraintWithItem:self.calendarContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.calendarContentView attribute:NSLayoutAttributeWidth multiplier:(1.0/7.0) constant:self.calenderHeaderHeight];
        [self addConstraint:self.layoutCalenderHeight];
    }else{
        self.layoutCalenderHeight = [NSLayoutConstraint constraintWithItem:self.calendarContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.calendarContentView attribute:NSLayoutAttributeWidth multiplier:(6.0/7.0) constant:self.calenderHeaderHeight];
        [self addConstraint:self.layoutCalenderHeight];
    }
    
    

}

-(void)setBgImage:(UIImage *)bgImage{
    _bgImage = bgImage;
    self.bgImageView.image = _bgImage;
   
}
-(void)setCalenderDataSource:(id)dataSource{

    _calenderDataSource = dataSource;
    [self.calendar setDataSource:_calenderDataSource];
    [self.calendar reloadData];
    
}

-(void)setCalenderMenuDelegate:(id)delegate{

    _calenderMenuDelegate = delegate;
    [self.OBOMenueBar setDelegate:_calenderMenuDelegate];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
