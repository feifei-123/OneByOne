//
//  OBO_NewScheVController.m
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBONewScheController.h"
#import "Utils.h"
#import "Constants.h"
#import "OBODataBase.h"
#import "OBOCommonDelegate.h"
#import "OBONavigationController.h"
#import "OBOCustumItem.h"
#import "UIColor+Hex.h"
#import "OBOPickerViewCell.h"
#import "NSDate+helper.h"
#import "MBProgressHUD+MJ.h"
#import "UIImage+stretch.h"
#import "RATTipsView.h"


@interface OBONewScheController() <OBOOperateDataDelegate>
{
    
    NSDate * tempCalenderDate;
    NSDate * tempDatePickerTime;
    NSInteger tempSeleSchTypeID;
    NSInteger tempSeleRemindTypeID;
    NSInteger tempSeleRepeatTyepID;
    
    Events*oldScheuleModel;
    
    OBOCustumItem *fourthLineItem ; // 第四行  文本域 的容器
    OBOCustumItem *sixthLineItem; //第六行 显示更多按钮 的容器.
}


// 容器视图，容纳 “上、中、下” 三个子视图
@property(nonatomic,strong)UIImageView *containerView;

//上部视图--相关
@property(nonatomic,strong)UIImageView *topView;
@property(nonatomic,strong)UIButton *schTypeBtn;
@property(nonatomic,strong)UITextField*schNameField;
@property(nonatomic,strong)UIButton*schBeginDateBtn;
@property(nonatomic,strong)UIButton*schBeginTimeBtn;
@property(nonatomic,strong) UIImageView* scheTypeImage;
//中部视图--相关
@property(nonatomic,strong) UIView*midView;
@property(nonatomic,strong) UIButton*schEndDateBtn;
@property(nonatomic,strong) UIButton*schEndTimeBtn;
@property(nonatomic,strong) UITextView*schDateilView;
@property(nonatomic,strong) UIButton*remindTypeBtn;
@property(nonatomic,strong) UIButton *repeatTypeBtn;
@property(nonatomic,strong) UILabel *schDetailLbl;
@property(nonatomic,strong) UILabel *finishTimeLbl;

//下部视图--相关
@property(nonatomic,strong)UIImageView *bottomView;
@property(nonatomic,strong) UIButton *moreBtn;
@property(nonatomic,strong) UIButton *cancelBtn;
@property(nonatomic,strong) UIButton *finishBtn;


@property(nonatomic,assign) BOOL isFolded;
@property(nonatomic,strong)NSArray*topMidBottomConstraints;
@property(nonatomic,strong)NSArray*textViewConstraints;
//@property(nonatomic,strong)NSLayoutConstraint * containerConstraint;
@property(nonatomic,strong)NSDictionary *dict;
@property(nonatomic,strong)NSArray *schTypeArray;
@property(nonatomic,strong)NSArray *remindTypeArray;
@property(nonatomic,strong)NSArray *repeatTypeArray;

//Calender相关
@property (nonatomic, strong) OBOCalenderView * oboCalenderView;//定制的日历视图
@property (nonatomic,strong) NSCalendar * gregorian;//公历日历
@property (nonatomic,assign) NSInteger currentYear; //当前是哪一年
//DatePicker
@property(nonatomic,strong)UIDatePicker*datePicker;
//PickerView
@property(nonatomic,strong)UIPickerView * pickViewer;

@end

@implementation OBONewScheController


-(void)setOldScheuleModel:(Events*)model
{
    
    oldScheuleModel = [Events copyEvents:model];
    
}

-(instancetype)initWithModel:(Events*)model{
    
    self = [super init];
    
    if (self) {
        if (model!=nil) {
            
            self.sheduleModel = model;
            
        }else{
            
            self.sheduleModel = [[Events alloc]init];
            self.sheduleModel.type = @(0);
            self.sheduleModel.title = @"";
            self.sheduleModel.content = @"";
            self.sheduleModel.startDate =[NSDate dateCutTime];
            
            self.sheduleModel.startTime =nil;
            //self.sheduleModel.endDate=[NSDate dateCutTime];
            self.sheduleModel.endDate=nil;
            self.sheduleModel.endTime=nil;
            self.sheduleModel.remind=@(0);
            self.sheduleModel.repeat=@(0);
            self.sheduleModel.state =@(0);
            
        }
        
        //保留一份修改之前的  日程数据模型.
        [self setOldScheuleModel:self.sheduleModel];
        
    }
    
    return self;
    
}

//-(void)setOperationType:(kNewScheduleViewType)type{
//
//    _operationType = type;
//    
//    
//    
//    [self refreshView];
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //(1)
    
    if(self.operationType==kInsertNewSchedule){
        
          self.isFolded = true;
        
    }else{
        
          self.isFolded = false;
        
    }
  
    tempCalenderDate = [NSDate CutTime:[NSDate date]];
    tempSeleSchTypeID = 0;
    tempSeleRemindTypeID = 0;
    tempSeleRepeatTyepID = 0;
    self.schTypeArray = [Utils getSchTypeArray];
    
    self.remindTypeArray = [Utils getSchRemindTypeArray];
    self.repeatTypeArray = [Utils getSchRepeatTypeArray];
    self.sheduleModel = [[Events alloc]init];
    
    //(2)
    [self addSubViews];
    [self initConstraints];
    
    //(3)
    [self refreshView];
    
    //(4)
    [self initCalenderPopView];
    [self initDatePickerPopView];
    [self initItemPickerView];
    
    //(5)
    [self addGestures];
    
    // Do any additional setup after loading the view.
}

-(void)addSubViews{
    
    //整个页面的背景图片
    
    UIImageView *wholeBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"whole_page_bg"]];
    [self.view addSubview:wholeBg];
    [wholeBg setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_Bg1 = @"H:|[wholeBg]|";
    NSString *vfl_Bg2 = @"V:|[wholeBg]|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_Bg1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(wholeBg)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_Bg2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(wholeBg)]];
    
    //容器视图
    self.containerView = [[UIImageView alloc]init];
    self.containerView.image = [UIImage imageNamed:@"covering_layer"];
    self.containerView.userInteractionEnabled = YES;
    self.containerView.layer.shadowColor = [UIColor colorWithHexString:@"#a59783" alpha:1.0].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(1, 2);
    self.containerView.layer.shadowRadius = 2.0f;
    self.containerView.layer.shadowOpacity = 0.75;
    
    [self.view addSubview:self.containerView];
    
    //上部视图------------------------------------------------
    self.topView = [[UIImageView alloc]init];
    self.topView.image = [UIImage imageNamed:@"content_bg"];
    self.topView.userInteractionEnabled = YES;
    [self.containerView addSubview:self.topView];
    //self.topView.backgroundColor = [UIColor greenColor];
    
    //-------第一行-------------------------------------------
    OBOCustumItem *firstLineItem = [[OBOCustumItem alloc]init];
    firstLineItem.image=[UIImage imageNamed:@"title_bg"];
    firstLineItem.leftViewWidth = @(80);//80
    firstLineItem.userInteractionEnabled = YES;
    [self.topView addSubview:firstLineItem];
    
    [firstLineItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_C1 = @"H:|-20-[firstLineItem]-20-|";
    NSString *vfl_C2 = @"V:|-15-[firstLineItem(32)]";
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstLineItem)]];
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstLineItem)]];
    
    
    self.scheTypeImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_schetype_temp"]];
    [firstLineItem addLeftItem:self.scheTypeImage withCGRect:CGRectMake(13, 8, 16, 16)];//10 10 16 16
    //self.scheTypeImage.backgroundColor = [UIColor greenColor];
    self.schTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.schTypeBtn.tag = 1;
    [self.schTypeBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.schTypeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    //self.schTypeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.schTypeBtn.titleLabel.font = kDefaultFontSize;
    //self.schTypeBtn.backgroundColor = [UIColor blueColor];
    [firstLineItem addLeftItem:self.schTypeBtn withCGRect:CGRectMake((43-8-5), 0, 40, 32)];//51
    
    self.schNameField = [[UITextField alloc]init];
    self.schNameField.delegate = self;
    self.schNameField.placeholder= @"输入日程标题...";
    [self.schNameField setValue:kLightTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.schNameField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.schNameField.textColor = kWeightTextColor;
    //self.schNameField.font = kDefaultFontSize;
    self.schNameField.font = [UIFont systemFontOfSize:14];
    //self.schNameField.backgroundColor = [UIColor redColor];
    [firstLineItem addRightItem:self.schNameField withRect:CGRectMake(11, 0, 240, 32)];
    
    
    //-------第二行--左-------------------------------------------
    OBOCustumItem *secondLine_leftItem = [[OBOCustumItem alloc]init];
    secondLine_leftItem.image = [UIImage imageNamed:@"date_time_btn_bg"];
    secondLine_leftItem.leftViewWidth = @(kLeftViewWidth);
    [self.topView addSubview:secondLine_leftItem];
    
    // leftImage
    UIImageView* iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_calendar"]];
    [secondLine_leftItem addLeftItem:iconImage];
    
    // rightView
    self.schBeginDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.schBeginDateBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.schBeginDateBtn.tag = 2;
    [self.schBeginDateBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    self.schBeginDateBtn.titleLabel.font = kDefaultFontSize;
    [secondLine_leftItem addRightItem:self.schBeginDateBtn];
    
    //-------第二行--右-------------------------------------------
    OBOCustumItem *secondLine_rightItem = [[OBOCustumItem alloc]init];
    secondLine_rightItem.image = [UIImage imageNamed:@"date_time_btn_bg"];
    secondLine_rightItem.leftViewWidth = @(kLeftViewWidth);
    [self.topView addSubview:secondLine_rightItem];
    
    // leftImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_clock"]];
    [secondLine_rightItem addLeftItem:iconImage];
    
    // rightView
    
    self.schBeginTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.schBeginTimeBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.schBeginTimeBtn.tag = 3;
    [self.schBeginTimeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    self.schBeginTimeBtn.titleLabel.font = kDefaultFontSize;
    [secondLine_rightItem addRightItem:self.schBeginTimeBtn];
    
    
    //-------第二行--布局-------------------------------------------
    [secondLine_leftItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [secondLine_rightItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    vfl_C1 = @"H:|-20-[secondLine_leftItem(secondLine_rightItem)]-(13)-[secondLine_rightItem]-20-|";
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstLineItem,secondLine_leftItem,secondLine_rightItem)]];
    
    vfl_C1 = @"V:[firstLineItem]-14-[secondLine_leftItem(32)]";
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstLineItem,secondLine_leftItem,secondLine_rightItem)]];
    
    vfl_C1 = @"V:[firstLineItem]-14-[secondLine_rightItem(32)]";
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstLineItem,secondLine_leftItem,secondLine_rightItem)]];
    
    
    
    //----------------中部视图-----------------------
    self.midView = [[UIView alloc]init];
    [self.containerView addSubview:self.midView];
    self.finishTimeLbl = [[UILabel alloc]init];
    self.finishTimeLbl.text=@"结束时间:";
    self.finishTimeLbl.textColor = kWeightTextColor;
    self.finishTimeLbl.font = kDefaultBigFontSize;
    self.finishTimeLbl.shadowColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.9];
    self.finishTimeLbl.shadowOffset = CGSizeMake(1/2.0,1/2.0);
    [self.finishTimeLbl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.midView addSubview:self.finishTimeLbl];
    
    
    //-------第三行---左----------------------------------------
    
    OBOCustumItem *thirdLine_leftItem = [[OBOCustumItem alloc]init];
    thirdLine_leftItem.image = [UIImage imageNamed:@"other_input_bg"];
    thirdLine_leftItem.leftViewWidth = @(kLeftViewWidth);
    [self.midView addSubview:thirdLine_leftItem];
    
    // leftImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_calendar"]];
    [thirdLine_leftItem addLeftItem:iconImage];
    
    // rightView
    self.schEndDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.schEndDateBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.schEndDateBtn.tag = 4;
    [self.schEndDateBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    self.schEndDateBtn.titleLabel.font =  kDefaultFontSize;
    [thirdLine_leftItem addRightItem:self.schEndDateBtn];
    
    //-------第三行---右----------------------------------------
    OBOCustumItem *thirdLine_rightItem = [[OBOCustumItem alloc]init];
    thirdLine_rightItem.image = [UIImage imageNamed:@"other_input_bg"];
    thirdLine_rightItem.leftViewWidth = @(kLeftViewWidth);
    [self.midView addSubview:thirdLine_rightItem];
    
    // leftImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_clock"]];
    [thirdLine_rightItem addLeftItem:iconImage];
    
    // rightView
    self.schEndTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.schEndTimeBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.schEndTimeBtn.tag = 5;
    [self.schEndTimeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    self.schEndTimeBtn.titleLabel.font = kDefaultFontSize;
    [thirdLine_rightItem addRightItem:self.schEndTimeBtn];
    
    //-------第三行---布局----------------------------------------
    [thirdLine_leftItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [thirdLine_rightItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.finishTimeLbl setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary * dicts = NSDictionaryOfVariableBindings(_finishTimeLbl,thirdLine_leftItem,thirdLine_rightItem);
    
    vfl_C1 = @"H:|-24-[_finishTimeLbl(100)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"V:|[_finishTimeLbl(28)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"H:|-20-[thirdLine_leftItem(thirdLine_rightItem)]-(13)-[thirdLine_rightItem]-20-|";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"V:[_finishTimeLbl][thirdLine_leftItem(32)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"V:[_finishTimeLbl][thirdLine_rightItem(32)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    
    self.schDetailLbl = [[UILabel alloc]init];
    self.schDetailLbl.textColor = kWeightTextColor;
    self.schDetailLbl.font = kDefaultBigFontSize;
    self.schDetailLbl.text=@"日程详情:";
    self.schDetailLbl.shadowColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.9];
    self.schDetailLbl.shadowOffset = CGSizeMake(1/2.0,1/2.0);
    [self.schDetailLbl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.midView addSubview:self.schDetailLbl];
    
    //-------第四行-------------------------------------------
    fourthLineItem = [[OBOCustumItem alloc]init];
    fourthLineItem.image = [UIImage imageWithStretch:@"detail_bg"];
    fourthLineItem.leftViewWidth = @(kLeftViewWidth);
    [self.midView addSubview:fourthLineItem];
    
    // leftImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageWithStretch:@"icon_details"]];
    [fourthLineItem addLeftItem:iconImage];
    
    
    self.schDateilView = [[UITextView alloc]init];
    self.schDateilView.text=kDefaultTextViewString;
    self.schDateilView.font =  kDefaultFontSize;
    self.schDateilView.textColor = kLightTextColor;
    self.schDateilView.delegate = self;
    self.schDateilView.backgroundColor = [UIColor clearColor];
    self.schDateilView.tag = kTextView_NoInfo_Tag;
    //self.schDateilView.backgroundColor = [UIColor redColor];
    [fourthLineItem addRightItem:self.schDateilView];
    
    //-------第四行---布局----------------------------------------
    [_schDetailLbl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fourthLineItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    dicts = NSDictionaryOfVariableBindings(thirdLine_leftItem,_schDetailLbl,fourthLineItem);
    
    vfl_C1 = @"H:|-24-[_schDetailLbl(100)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"H:|-20-[fourthLineItem]-20-|";//20
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"V:[thirdLine_leftItem][_schDetailLbl(28)]-(-3)-[fourthLineItem]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = [NSString stringWithFormat:@"V:[fourthLineItem(%f)]",[self getScheDetailHeight]];
    self.textViewConstraints =[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts];
    [self.midView addConstraints:self.textViewConstraints];
    
    
    //-------第五行---左------------------------------------------
    
    OBOCustumItem *fifthLine_leftItem = [[OBOCustumItem alloc]init];
    fifthLine_leftItem.image = [UIImage imageNamed:@"other_input_bg"];
    fifthLine_leftItem.leftViewWidth = @(kLeftViewWidth);
    [self.midView addSubview:fifthLine_leftItem];
    
    // leftImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_alarmclock"]];
    [fifthLine_leftItem addLeftItem:iconImage];
    
    // rightView
    self.remindTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.remindTypeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    [self.remindTypeBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.remindTypeBtn setTitleColor:kCustomGrayColor forState:UIControlStateNormal];
    self.remindTypeBtn.tag = 6;
    [self.remindTypeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    self.remindTypeBtn.titleLabel.font = kDefaultFontSize;
    [fifthLine_leftItem addRightItem:self.remindTypeBtn];
    
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_more"]];
    [fifthLine_leftItem addRightItem:iconImage withRect:CGRectMake(99, 0, 32, 32)];
    
    //-------第五行---右------------------------------------------
    
    OBOCustumItem *fifthLine_rightItem = [[OBOCustumItem alloc]init];
    fifthLine_rightItem.image = [UIImage imageNamed:@"other_input_bg"];
    fifthLine_rightItem.leftViewWidth = @(kLeftViewWidth);
    [self.midView addSubview:fifthLine_rightItem];
    
    // leftImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_repeat"]];
    [fifthLine_rightItem addLeftItem:iconImage];
    
    self.repeatTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.repeatTypeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    [self.repeatTypeBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.repeatTypeBtn.tag = 7;
    [self.repeatTypeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    self.repeatTypeBtn.titleLabel.font = kDefaultFontSize;
    [fifthLine_rightItem addRightItem:self.repeatTypeBtn];
    
    
    
    //-------第五行---布局------------------------------------------
    [fifthLine_leftItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fifthLine_rightItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    dicts = NSDictionaryOfVariableBindings(fourthLineItem,fifthLine_leftItem,fifthLine_rightItem);
    
    vfl_C1 = @"H:|-20-[fifthLine_leftItem(fifthLine_rightItem)]-(13)-[fifthLine_rightItem]-20-|";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    vfl_C1 = @"V:[fourthLineItem]-(14)-[fifthLine_leftItem(fifthLine_rightItem)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    vfl_C1 = @"V:[fourthLineItem]-(14)-[fifthLine_rightItem(32)]";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    vfl_C1 = @"V:[fifthLine_leftItem]-(14)-|";
    [self.midView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    
    //----------------底部视图-----------------------
    self.bottomView = [[UIImageView alloc]init];
    self.bottomView.userInteractionEnabled = YES;
    [self.containerView addSubview:self.bottomView];
    //self.bottomView.backgroundColor = [UIColor redColor];
    
    //-------第六行-------------------------------------------
    
    sixthLineItem = [[OBOCustumItem alloc]init];
    sixthLineItem.leftViewWidth = @(kLeftViewWidth);
    [self.bottomView addSubview:sixthLineItem];
    
    // rightImage
    iconImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_more"]];
    iconImage.tag = kMoreTag;
    iconImage.userInteractionEnabled =NO;
    [sixthLineItem addRightItem:iconImage withRect:CGRectMake(180, 1, 32, 32)];//180
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
    self.moreBtn.titleLabel.font = kDefaultBigFontSize;
    [sixthLineItem addWholeItem:self.moreBtn];
   
    
    UIImageView * btnsView = [[UIImageView alloc]init];
    btnsView.image = [UIImage imageNamed:@"btn_bg"];
    [self.bottomView addSubview:btnsView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_normal"] forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_highlighted"] forState:UIControlStateHighlighted];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.cancelBtn.tag = 6;
    [self.cancelBtn setTitleColor:kCancelTextColor forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = kDefaultBigFontSize;
    //self.cancelBtn.backgroundColor = [UIColor redColor];
    [self.bottomView addSubview:self.cancelBtn];
    
    self.finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.finishBtn setBackgroundImage:[UIImage imageNamed:@"finish_btn_normal"] forState:UIControlStateNormal];
    [self.finishBtn setBackgroundImage:[UIImage imageNamed:@"finish__btn_hightlighted"] forState:UIControlStateHighlighted];
    self.finishBtn.tag = 7;
    [self.finishBtn setTitleColor:kFinishTextColor forState:UIControlStateNormal];
    self.finishBtn.titleLabel.font = kDefaultBigFontSize;
    self.finishBtn.titleLabel.layer.shadowColor = [UIColor colorWithHexString:@"#73a845" alpha:1.0].CGColor;
    self.finishBtn.titleLabel.layer.shadowOffset =CGSizeMake(1/2.0, 1/2.0);
    [self.bottomView addSubview:self.finishBtn];
    
    //-----底部视图--布局-----------------------------
    [_bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sixthLineItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_moreBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [btnsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_cancelBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_finishBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    dicts = NSDictionaryOfVariableBindings(_remindTypeBtn,sixthLineItem,btnsView,_cancelBtn,_finishBtn);
    
    vfl_C1 = @"H:|[sixthLineItem]|";
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    vfl_C1 = @"H:|[btnsView]|";
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    vfl_C1 = @"V:|-(0)-[sixthLineItem(30)]-(1)-[btnsView]|";
    //vfl_C1 = @"V:|-(-11)-[sixthLineItem(30)]-(1)-[btnsView]|";
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    //vfl_C1 = @"H:|-(19.5)-[_cancelBtn(_finishBtn)]-(-2)-[_finishBtn(170)]";
    //vfl_C1 = @"H:|-(17.5)-[_cancelBtn(_finishBtn)][_finishBtn(170)]-(17.5)-|";
    vfl_C1 = @"H:|-(17.5)-[_cancelBtn(_finishBtn)][_finishBtn]-(17.5)-|";
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    vfl_C1 = @"V:[sixthLineItem]-(1)-[_cancelBtn(btnsView)]";
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
    vfl_C1 = @"V:[sixthLineItem]-(1)-[_finishBtn(btnsView)]";
    [self.bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts]];
}

-(void)cancelBtnClicked:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^(){}];
    
}

-(void)showTips:(NSString*)msg{
    RATTipsView *tipsView = [RATTipsView sharedManager];
    if (!tipsView.isShowing) {
        tipsView.labelView.text = msg;
        [tipsView show];
    }
    
}

/*
 *验证 添加的事件信息 是否合理！
 *add by feifei 2015_07_19
 */
-(BOOL)validateEvent{
    
    if ((self.sheduleModel.endDate!=nil)&&[self.sheduleModel.endDate compare:self.sheduleModel.startDate]==NSOrderedAscending) {
        //[MBProgressHUD showError:@"结束日期不能早于开始日期"];
        [self showTips:@"结束日期不能早于开始日期"];
        return false;
    }

    NSDate*date_start= [NSDate combineDate:self.sheduleModel.startDate AndTime:self.sheduleModel.startTime];
    NSDate*date_end= [NSDate combineDate:self.sheduleModel.endDate AndTime:self.sheduleModel.endTime];
    
    if(self.sheduleModel.endTime!=nil&&([date_end compare:date_start]==NSOrderedAscending)){
      
          //[MBProgressHUD showError:@"结束时间不能早于开始时间"];
          [self showTips:@"结束时间不能早于开始时间"];
          return false;
    }
    
    
    return true;

}
-(void)finishBtnClicked:(id)sender{
    
    
    //信息校验！
   BOOL validateResult = [self validateEvent];
    
    if (validateResult==false) {
        return ;
    }
    
    self.sheduleModel.timeStamp = [NSDate date];
    
    if (self.sheduleModel.startTime==nil) { //没有日期默认，设置成事件
        self.sheduleModel.classify= @(kEventClassifyEvent);
    }else{ //有起始时间，则设置成日程.
        self.sheduleModel.classify = @(kEventClassifySche);
    }
    
    self.sheduleModel.state = @(kEventStatePending);
    
    if (self.operationType==kInsertNewSchedule) {//执行插入操作
        
        if (self.delegete!=nil&&[self.delegete respondsToSelector:@selector(insertDataWithEvent:result:)])
        {
            [self.delegete insertDataWithEvent:self.sheduleModel result:^(BOOL result,kInsertDataResult insertResult){
                
                if (result==YES) {
                    NSLog(@"insert events success!");
                }
            }];
            
        }
        
    }else if(self.operationType==kModifiedSchedule){//执行修改操作
        
        if(self.delegete!=nil&&[self.delegete respondsToSelector:@selector(updateDataWithEvent:targetEvent:result:)]){
            
            [self.delegete updateDataWithEvent:oldScheuleModel targetEvent:self.sheduleModel  result:^(BOOL result, kInsertDataResult insertResult) {
                
                if (result==YES) {
                    NSLog(@"update events success!");
                }
                
            }];
            
        }
        
    }else{//执行调整操作
        
        if(self.delegete!=nil&&[self.delegete respondsToSelector:@selector(adjustDataWithEvent:targetEvent:currentPage:result:)]){
            [self.delegete adjustDataWithEvent:oldScheuleModel targetEvent: [self.sheduleModel mutableCopy]  currentPage:YES result:^(BOOL result, kInsertDataResult insertResult) {
                
                if (result==YES) {
                    NSLog(@"adjust events success!");
                }
                
            }];
            
        }
        
    }
    
    [OBONavigationController backFromController:self];
}
-(void)pageBtnClicked:(id)sender{
    
    //(1)默认动作
    //点击任何按钮时，都强制使  schNameField 和 schDateilView 失去焦点
    [self.schNameField resignFirstResponder];
    [self.schDateilView resignFirstResponder];
    
    //点击输入框 按钮后，首先保存 “新建日程页面”上的文本内容－“日程标题”和”日程内容“.
    self.sheduleModel.title = self.schNameField.text;
   
    if (self.schDateilView.tag ==kTextView_WithInfo_Tag) {
          self.sheduleModel.content = self.schDateilView.text;
    }else{
          self.sheduleModel.content = @"";
    }
  
    
    
    //(2) 点击按钮的事件处理
    NSInteger flag = ((UIView*)sender).tag;
    
    CustomPopActionView * customPopView = [[CustomPopActionView alloc]initWithTitle:@"请选择时间" referView:self.view];
    customPopView.delegate = self;
    customPopView.tag = flag;
    
    if (flag==1) {//行程类别按钮  触发的 事件
        
        customPopView.title = @"请选择行程类别";
        [self initItemPickerView];
        NSInteger selectedID = self.sheduleModel.type.intValue==-1?0:self.sheduleModel.type.intValue;
        [self.pickViewer selectRow: selectedID inComponent:0 animated:YES];
        customPopView.contentViewHeight = 180;
        [customPopView addComponentView:self.pickViewer];
        
        
    }else if(flag==2){//输入起始日期按钮  触发的 事件
        
        customPopView.title = @"请选择开始日期";
        //customPopView.contentViewHeight = 350;//350
        
        if([[Utils getDeviceType] isEqualToString:@"iPhone Simulator"]){
            customPopView.contentViewHeight = 350;
            
        }else{
             customPopView.contentViewHeight = 350;
        }

        [customPopView addComponentView:self.oboCalenderView];
        
    }else if(flag ==3){//输入起始时间按钮  触发的 事件
        
        tempDatePickerTime = [NSDate date];
        customPopView.title = @"请选择开始时间";
        customPopView.contentViewHeight = 180;
        self.datePicker.minimumDate = nil;
        if (self.sheduleModel.startTime!=nil) {
            self.datePicker.date = self.sheduleModel.startTime;
        }
        
        [customPopView addComponentView:self.datePicker];
        
    }else if(flag ==4){//输入结束日期按钮  触发的 事件
        
        customPopView.title = @"请选择结束日期";
        
        if([[Utils getDeviceType] isEqualToString:@"iPhone Simulator"]){
            customPopView.contentViewHeight = 350;
            
        }else{
            customPopView.contentViewHeight = 350;//350
        }
        
        if(self.sheduleModel.endDate!=nil){
            self.oboCalenderView.currentDate = self.sheduleModel.endDate;
        }
       
        [customPopView addComponentView:self.oboCalenderView];
        
    }else if(flag ==5){//输入结束时间按钮  触发的 事件
        
        tempDatePickerTime = [NSDate date];
        customPopView.title = @"请选择结束时间";
        customPopView.contentViewHeight = 180;
        
        self.datePicker.minimumDate = [NSDate combineDate:self.sheduleModel.startDate AndTime:self.sheduleModel.startTime];
        if (self.sheduleModel.endTime!=nil) {
            self.datePicker.date = self.sheduleModel.endTime;
        }
        [customPopView addComponentView:self.datePicker];
        
    }else if(flag ==6){//提醒按钮按钮  触发的 事件
        
        [self initItemPickerView];
        NSInteger selectedID = self.sheduleModel.remind.intValue==-1?0:self.sheduleModel.remind.intValue;
        [self.pickViewer selectRow: selectedID inComponent:0 animated:NO];
        customPopView.title = @"请选择提醒时间";
        customPopView.contentViewHeight = 180;
        [customPopView addComponentView:self.pickViewer];
        
    }else{//重复按钮  触发的 事件
        
        [self initItemPickerView];
        NSInteger selectedID = self.sheduleModel.repeat.intValue==-1?0:self.sheduleModel.repeat.intValue;
        [self.pickViewer selectRow: selectedID inComponent:0 animated:NO];
        customPopView.title = @"请选择重复方式";
        customPopView.contentViewHeight = 180;
        [customPopView addComponentView:self.pickViewer];
    }
    
    [customPopView show];
    
    
}


-(void)initConstraints{
    
    //去除AutoresizingMask
    
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_topView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_midView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    //容器视图 布局
    NSDictionary *containerViews = NSDictionaryOfVariableBindings(_containerView);
    NSString *vfl_C1 = @"H:|-0-[_containerView]-0-|";
    NSString *vfl_C2 = @"V:|-76-[_containerView]";
    
    //    _containerView.backgroundColor = [UIColor redColor];
    //    _midView.backgroundColor = [UIColor blueColor];
    //    _bottomView.backgroundColor = [UIColor greenColor];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:containerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:containerViews]];
    
    
    //上、中、下 三大部分 布局
    
    self.dict = NSDictionaryOfVariableBindings(_topView, _midView,_bottomView);
    NSString *vfl1 = @"H:|-0-[_topView]-0-|";
    NSString *vfl2 = @"H:|-0-[_midView]-0-|";
    NSString *vfl3 = @"H:|-0-[_bottomView]-0-|";
    
    
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:self.dict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:self.dict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:nil views:self.dict]];
    
    
    NSString *vfl5 = @"";
    
    
    if (self.isFolded) { //60
        self.midView.alpha = 0.0;
     
        vfl5 =  @"V:|[_topView(120)]-(-11)-[_bottomView(73)]|";//84
    }else{
        self.midView.alpha = 1.0;
        vfl5 =   @"V:|[_topView(120)]-(-12)-[_midView][_bottomView(73)]|";//2
        
    }
    
    self.topMidBottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:vfl5 options:0 metrics:nil views:self.dict];
    
    
    [self.containerView addConstraints: self.topMidBottomConstraints];
    
    
}

-(void)refreshView
{
    
    
    NSString*schType=@"";
    if (self.sheduleModel.type.intValue==-1) {
        schType =@"行程类别";
    }else {
        schType =[Utils convertSchTypeID2String:self.sheduleModel.type.intValue];
    }
    [_schTypeBtn setTitle:schType forState:UIControlStateNormal];
    
    self.scheTypeImage.image = [Utils getSchTypeImage:self.sheduleModel.type.intValue];
    
    //日程名称
    _schNameField.text=self.sheduleModel.title;
    
    //日程起始日期
    if (self.sheduleModel.startDate==nil||[self.sheduleModel.startDate isEqual:@""]) {
        [_schBeginDateBtn setTitle:@"--------" forState:UIControlStateNormal];
        [_schBeginDateBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
        
    }else{
        
        [_schBeginDateBtn setTitle:[OBOStringTools stringWithDayTipsFromDate:self.sheduleModel.startDate] forState:UIControlStateNormal];
        [_schBeginDateBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
    }
    
    //日程起始时间
    if (self.sheduleModel.startTime==nil||[self.sheduleModel.startTime isEqual:@""]) {
        [_schBeginTimeBtn setTitle:@"--------" forState:UIControlStateNormal];
        [_schBeginTimeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
        
        
    }else{
        
        [_schBeginTimeBtn setTitle:[OBOStringTools stringFromTime:self.sheduleModel.startTime]forState:UIControlStateNormal];
        [_schBeginTimeBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
    }
    
    //日程结束日期
    if (self.sheduleModel.endDate==nil||[self.sheduleModel.endDate isEqual:@""]) {
        [_schEndDateBtn setTitle:@"--------" forState:UIControlStateNormal];
        [_schEndDateBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
        
    }else{
        
        [_schEndDateBtn setTitle:[OBOStringTools stringWithDayTipsFromDate:self.sheduleModel.endDate] forState:UIControlStateNormal];
        [_schEndDateBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
        
    }
    
    //日程结束时间
    if (self.sheduleModel.endTime==nil||[self.sheduleModel.endTime isEqual:@""]) {
        [_schEndTimeBtn setTitle:@"--------" forState:UIControlStateNormal];
        [_schEndTimeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
        
        
    }else{
        
        [_schEndTimeBtn setTitle:[OBOStringTools stringFromTime:self.sheduleModel.endTime] forState:UIControlStateNormal];
        [_schEndTimeBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
    }
    
    //日程内容
    if (self.sheduleModel.content==nil||[self.sheduleModel.content isEqualToString:@""]){
        self.schDateilView.textColor = kLightTextColor;
        self.schDateilView.text = kDefaultTextViewString;
    }else{
        self.schDateilView.textColor = kWeightTextColor;
        self.schDateilView.text = self.sheduleModel.content;
    }
    
    
    if (self.sheduleModel.remind.intValue==-1||self.sheduleModel.remind.intValue==0) {
        [self.remindTypeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
        
    }else{
        [self.remindTypeBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
    }
    
    NSString*remindType =[Utils convertSchRemindID2String:(self.sheduleModel.remind.intValue)];
    [self.remindTypeBtn setTitle:remindType forState:UIControlStateNormal];
    
    
    
    if (self.sheduleModel.repeat.intValue==-1||self.sheduleModel.remind.intValue==0) {
        [self.repeatTypeBtn setTitleColor:kLightTextColor forState:UIControlStateNormal];
    }else{
        [self.repeatTypeBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
    }
    
    NSString*rePeatType = [Utils convertSchRepeatTypeID2String:(self.sheduleModel.repeat.intValue)];
    [self.repeatTypeBtn setTitle:rePeatType forState:UIControlStateNormal];
    
    if (self.isFolded) {
        [self.moreBtn setTitle:@"更多选项" forState:UIControlStateNormal];
    }else{
        [self.moreBtn setTitle:@"收起更多" forState:UIControlStateNormal];
    }
    
    [self.cancelBtn setTitle:@"取 消" forState:UIControlStateNormal];
    
    if(self.operationType == kAdjustSchedule){
        [self.finishBtn setTitle:@"调 整" forState:UIControlStateNormal];
    }else if(self.operationType == kModifiedSchedule){
        [self.finishBtn setTitle:@"保 存" forState:UIControlStateNormal];
    }else if(self.operationType==kInsertNewSchedule){
        [self.finishBtn setTitle:@"确 认" forState:UIControlStateNormal];
    }
    
}

- (void)moreBtnClicked:(id)sender
{
    
//    if (self.sheduleModel.endDate==nil) {
//        self.sheduleModel.endDate = [NSDate dateCutTime];
//        
//        [_schEndDateBtn setTitle:[OBOStringTools stringWithDayTipsFromDate:self.sheduleModel.endDate] forState:UIControlStateNormal];
//        [_schEndDateBtn setTitleColor:kWeightTextColor forState:UIControlStateNormal];
//    }
    
    if (self.isFolded) {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            
            //(1)删除旧的constraints
            if (self.topMidBottomConstraints!=nil) {
                [self.containerView removeConstraints:self.topMidBottomConstraints];
            }
            
            //(2)添加新的constraints
            self.topMidBottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(120)]-(-12)-[_midView][_bottomView(73)]|" options:0 metrics:nil views:self.dict];//2
            [self.containerView addConstraints:self.topMidBottomConstraints];
            //(3) 更新layouts;
            [self.view layoutIfNeeded];
            
            // self.midView.alpha = 0.3;
        } completion:^(BOOL finished) {
            self.midView.alpha = 1.0;
            self.isFolded = false;
            
            //更换 显示更多 的图标 为“收起”.
            UIImageView* icon_more = (UIImageView*)[sixthLineItem.rightView viewWithTag:kMoreTag];
            icon_more.image = [UIImage imageNamed:@"icon_pickup"];
            
        }];
        
        [self.moreBtn setTitle:@"收起更多" forState:UIControlStateNormal];
        
    }else{
        
        self.midView.alpha = 0.0;
        [UIView animateWithDuration:0.6 animations:^{
            
            //(1)删除旧的constraints
            if (self.topMidBottomConstraints!=nil) {
                [self.containerView removeConstraints:self.topMidBottomConstraints];
            }
            
            //(2)添加新的constraints
            self.topMidBottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(120)]-(-11)-[_bottomView(73)]|" options:0 metrics:nil views:self.dict];
            [self.containerView addConstraints:self.topMidBottomConstraints];
            //(3) 更新layouts;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            self.midView.alpha = 0.0;
            self.isFolded = true;
            
            //更换 显示更多 的图标为 “展开”.
            UIImageView* icon_more = (UIImageView*)[sixthLineItem.rightView viewWithTag:kMoreTag];
            icon_more.image = [UIImage imageNamed:@"icon_more"];
            
            
        }];
        
        [self.moreBtn setTitle:@"更多选项" forState:UIControlStateNormal];
        
        
    }
    
    
    
}


-(void)initCalenderPopView{
    
    self.oboCalenderView = [[OBOCalenderView alloc]init];
    self.oboCalenderView.calenderDataSource = self;
    self.oboCalenderView.calenderMenuDelegate = self;
    self.oboCalenderView.bgImage = [UIImage imageNamed:@"calender_covering_layer"];
    self.oboCalenderView.calenderMenuBarHeight = 38;
    self.oboCalenderView.calenderHeaderHeight = 31;
    self.oboCalenderView.leftMargin = 30;
    self.oboCalenderView.rightMargin = 30;
    self.oboCalenderView.bottomMargin =2;
    
}

-(void)initDatePickerPopView{
    
    self.datePicker = [[ UIDatePicker alloc ] init];
    self.datePicker.datePickerMode = UIDatePickerModeTime ;//设置日期显示格式
    self.datePicker.date = [NSDate date];
    [self.datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
}

-(void)initItemPickerView{
    
    self.pickViewer = [[UIPickerView alloc]init];
    self.pickViewer.delegate = self;
    self.pickViewer.dataSource = self;
    
}

-(void)addGestures{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTaps:)];
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
-(void)handleTaps:(id)sender{
    [self.schNameField resignFirstResponder];
    [self.schDateilView resignFirstResponder];
}
//日历相关的delegate  dataSource
#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
  
   tempCalenderDate= [NSDate CutTime:date];
    
    NSLog(@"-------:%@",tempCalenderDate);
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
    
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
    
}

#pragma CalenderMenuBarDelegate

-(void)CalenderMenuLeftBtnClicked:(id)sender{
    
    [self.oboCalenderView.calendar loadPreviousPage];
    
}

-(void)CalenderMenuRightBtnClicked:(id)sender{
    
    [self.oboCalenderView.calendar loadNextPage];
}

-(void)CalenderMenuTitleBtnClicked:(id)sender{
    
    
    
}

-(void)bottomPopViewOkBtnClicked:(NSInteger)flag;
{
    
    if (flag==1) {
        
        self.sheduleModel.type = @(tempSeleSchTypeID);
        
    }else if(flag==2){//输入起始日期按钮  触发的 事件
        
        self.sheduleModel.startDate = tempCalenderDate;
        
    }else if(flag ==3){//输入起始时间按钮  触发的 事件
        
        self.sheduleModel.startTime = tempDatePickerTime;
        
        
    }else if(flag ==4){//输入结束日期按钮  触发的 事件
        
        self.sheduleModel.endDate = tempCalenderDate;
        
        
    }else if(flag ==5){//输入结束时间按钮  触发的 事件
        
        
        self.sheduleModel.endTime = tempDatePickerTime;
        
        
        
    }else if(flag ==6){//提醒按钮按钮  触发的 事件
        
        self.sheduleModel.remind = @(tempSeleRemindTypeID);
        
    }else{//重复按钮  触发的 事件
        
        self.sheduleModel.repeat = @(tempSeleRepeatTyepID);
    }
    [self refreshView];
}

//UIDatePicker 事件函数
-(void)datePickerValueChanged:(id)sender{
    
    tempDatePickerTime = [self.datePicker date];
    
}


// UIPickViewer dataSource  delegate
//确定picker的轮子个数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

//确定picker的每个轮子的item数
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    NSInteger  flag = pickerView.tag;
    
    if (flag==1) {
        
        return [self.schTypeArray count];
        
    }else if(flag==6){
        
        return [self.remindTypeArray count];
        
    }else{
        
        return [self.repeatTypeArray count];
    }
    
}
//确定每个轮子的每一项显示什么内容
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSInteger flag = pickerView.tag;
    
    NSString*title=@"";
    
    if (flag==1) {
        
        title= (NSString*)[self.schTypeArray objectAtIndex:row];
        
    }else if(flag==6){
        
        title= (NSString*)[self.remindTypeArray objectAtIndex:row];
        
    }else{
        
        title= (NSString*)[self.repeatTypeArray objectAtIndex:row];
    }
    
    return title;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    NSInteger flag = pickerView.tag;
    
    NSString*title=@"";
    
    if (flag==1) {
        
        title= (NSString*)[self.schTypeArray objectAtIndex:row];
        
    }else if(flag==6){
        
        title= (NSString*)[self.remindTypeArray objectAtIndex:row];
        
    }else{
        
        title= (NSString*)[self.repeatTypeArray objectAtIndex:row];
    }

    
    OBOPickerViewCell * pickerViewCell = [[OBOPickerViewCell alloc]init];
    [pickerViewCell setTItle:title];
    [pickerViewCell setTitleColor:[UIColor colorWithHexString:@"#5f513f" alpha:1.0]];
    
    if (flag==1) { //仅当 flag==1  选择日程种类时,才设置 icon图标
         [pickerViewCell setIconImage:[Utils getSchTypeImage:(kEventType)row]];
         pickerViewCell.titleLeftMargin =40.0f;
    }
   
    return pickerViewCell;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSInteger flag = pickerView.tag;
    
    if(flag==1){
        
        tempSeleSchTypeID = row;
        
    }else if(flag==6){
        
        tempSeleRemindTypeID = row;
        
    }else{
        
        tempSeleRepeatTyepID = row;
    }
    
}
#pragma UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:kDefaultTextViewString] ) {
        textView.text = @"";
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if (textView.tag == kTextView_WithInfo_Tag) {
         self.sheduleModel.content = self.schDateilView.text;
    }else{
        self.sheduleModel.content = @"";
    }
   
    
}
- (void)textViewDidChange:(UITextView *)textView{
    
    textView.tag = kTextView_WithInfo_Tag;
    
    CGRect textFrame=[[textView layoutManager]usedRectForTextContainer:[textView textContainer]];
    float height = textFrame.size.height;
    
    
    if (height>kTextViewDefaultHeight) {
        
        //对TextView的height做限制，防止其把底下的元素 挤出界面。
        if(height>=150){
            height=150;
        }
        if (self.textViewConstraints!=nil) {
            [self.midView removeConstraints:self.textViewConstraints];
        }
        
        NSDictionary*dicts = NSDictionaryOfVariableBindings(_midView,fourthLineItem);
        NSString* vfl_C1 = [NSString stringWithFormat: @"V:[fourthLineItem(%f)]",height];
        self.textViewConstraints =[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:dicts];
        [self.midView addConstraints:self.textViewConstraints];
        
        
        
    }
    
      NSLog(@"------------textViewHeight:%f",height);
  
    
    
}

#pragma   UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    self.sheduleModel.title = self.schNameField.text;
    
    [theTextField resignFirstResponder];
    
    return YES;
}


-(CGFloat)getScheDetailHeight{
    
    CGRect textFrame=[[self.schDateilView layoutManager]usedRectForTextContainer:[self.schDateilView textContainer]];
    float height = textFrame.size.height;
    if (height>kTextViewDefaultHeight) {
        return height;
    }else{
        return kTextViewDefaultHeight;
    }
}
//布局发生改变时，都会调用这个方法
- (void)viewDidLayoutSubviews
{
    //当calendar视图 bounds 由无到有时，肯定会触发viewDidLayoutSubviews方法，此时调用repositionViews,将日历 定位到代笔当前月的页面.
    [self.oboCalenderView.calendar repositionViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor: [UIColor colorWithHexString:@"#5f513f" alpha:1.0], UITextAttributeFont:[UIFont boldSystemFontOfSize:21]};
    
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
    
    if(self.operationType==kInsertNewSchedule){
        self.navigationItem.title=@"添加日程";
        self.isFolded = true;
        [_finishBtn setTitle:@"确 认" forState:UIControlStateNormal];
    }else if(self.operationType == kModifiedSchedule){
        self.navigationItem.title=@"编辑日程";
        self.isFolded = false;
        [_finishBtn setTitle:@"保 存" forState:UIControlStateNormal];
    }else if(self.operationType == kAdjustSchedule){
        self.navigationItem.title=@"调整日程";
        self.isFolded = false;
        [_finishBtn setTitle:@"调 整" forState:UIControlStateNormal];
        [_finishBtn setBackgroundImage:[UIImage imageNamed:@"adjustBtn_normal"] forState:UIControlStateNormal];
        [_finishBtn setBackgroundImage:[UIImage imageNamed:@"adjustBtn_highlighted"] forState:UIControlStateHighlighted];
    }else{
        
    }
    
    [self refreshFoldStatus];
    
    [self refreshView];
}

-(void)refreshFoldStatus{
    
    
    //(1)删除旧的constraints
    if (self.topMidBottomConstraints!=nil) {
        [self.containerView removeConstraints:self.topMidBottomConstraints];
    }

    
    if (!self.isFolded) { //状态为展开
        
            //添加新的constraints
            self.topMidBottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(120)]-(-12)-[_midView][_bottomView(73)]|" options:0 metrics:nil views:self.dict];//2
            [self.containerView addConstraints:self.topMidBottomConstraints];
        
            self.midView.alpha = 1.0;
            //更换 显示更多 的图标 为“收起”.
            UIImageView* icon_more = (UIImageView*)[sixthLineItem.rightView viewWithTag:kMoreTag];
            icon_more.image = [UIImage imageNamed:@"icon_pickup"];
        
            [self.moreBtn setTitle:@"收起更多" forState:UIControlStateNormal];
        
        
    }else{ //状态为折叠
        
            //添加新的constraints
            self.topMidBottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(120)]-(-12)-[_bottomView(73)]|" options:0 metrics:nil views:self.dict];
            [self.containerView addConstraints:self.topMidBottomConstraints];
        
            self.midView.alpha = 0.0;
            //更换 显示更多 的图标为 “展开”.
            UIImageView* icon_more = (UIImageView*)[sixthLineItem.rightView viewWithTag:kMoreTag];
            icon_more.image = [UIImage imageNamed:@"icon_more"];
        
            [self.moreBtn setTitle:@"更多选项" forState:UIControlStateNormal];
    }

    
    //(3) 更新layouts;
    [self.view layoutIfNeeded];

}
-(void)viewWillDisappear:(BOOL)animated{
    
    
}

-(void)dealloc{
    NSLog(@"%s",__func__);
}

@end
