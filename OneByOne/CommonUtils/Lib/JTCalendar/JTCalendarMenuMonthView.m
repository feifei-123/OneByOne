//
//  JTCalendarMenuMonthView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMenuMonthView.h"

@interface JTCalendarMenuMonthView(){
    UILabel *textLabel;
}

@end

@implementation JTCalendarMenuMonthView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    {
        textLabel = [UILabel new];
        [self addSubview:textLabel];
      
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 1;
        
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        btn.backgroundColor = [UIColor blueColor];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    //textLabel.text =@"2015年10月";
    textLabel.text = self.calendarManager.calendarAppearance.monthBlock(currentDate, self.calendarManager);
}

- (void)layoutSubviews
{
    textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    // No need to call [super layoutSubviews]
}

- (void)reloadAppearance
{
    textLabel.textColor = self.calendarManager.calendarAppearance.menuMonthTextColor;
    //textLabel.backgroundColor = [UIColor greenColor];
    textLabel.layer.borderColor = [UIColor greenColor].CGColor;
    textLabel.layer.borderWidth = 3.0;
    textLabel.font = self.calendarManager.calendarAppearance.menuMonthTextFont;
    //self.backgroundColor = [UIColor redColor];
    
   
    
    
}

-(void)btnClicked:(id)sender{
    NSLog(@"111111");
    
}

@end
