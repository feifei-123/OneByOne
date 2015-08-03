//
//  OBOCalendarScheduleController.m
//  OneByOne
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOCalendarScheduleController.h"
#import "OBODetailScheController.h"
#import "RATMenu.h"
#import "OBONoHLButton.h"
#import "Utils.h"
#import "Constants.h"
#import "OBONavigationController.h"
#import "OBOCommonDelegate.h"
#import "OBOEventDateListModel.h"
#import "OBODataBase.h"
#import "NSDate+helper.h"
#import "OBOArrayTools.h"
#import "MBProgressHUD+MJ.h"
#import "MJRefresh.h"
#import "OBOTableHeaderView.h"
#import "UIImage+stretch.h"
#import "RATTipsView.h"

#define kStateMenuButtonWidth   34
#define kStateMenuButtonHeight   34

typedef void(^ActionBlock)(BOOL success);

@interface OBOCalendarScheduleController () <OBOOperateDataDelegate,RATMenuDelegate,OBOTableHeaderViewDelegate,OBOTouchTableViewDelegate>{
    
    int y_prev;//y坐标初始值
    int y_next;//y坐标变化后值
    
    //临时记录 DatePicker选中的时间。
    NSDate * tempDatePickerDate;
    
    
    
}
@property (strong, nonatomic) SRMonthPicker *monthPicker;
@property (strong,nonatomic)  RATTabBar*oboFootTabBar;
//保存搜索模式下 行程数据的数组，包括日历模式下的搜索和 列表模式下的搜索
@property (strong,nonatomic)  NSMutableArray * scheSearchDataArray;
//保存日历模式下 某个日期 行程的数组
@property (strong,nonatomic)  NSMutableArray * scheDateDataArray;
//保存列表模式下,全部日程的列表
@property (nonatomic,strong)  NSMutableArray * scheListAllDataArray;
//记录 某页日历中，是否存在日程的字典
@property (strong,nonatomic)  NSMutableDictionary *calenderEvents;
//记录日历选中的日期
@property (strong,nonatomic)  NSDate *selectedDate;
//记录搜索的关键字
@property (strong,nonatomic)  NSString*keyWords;

//标志位,toShowSearchTableView==YES TableView显示模糊搜索出的数据，toShowSearchTableView==YES 显示日历某一天的数据。
//标志位：isSearchMode==YES,表示处于搜索模式(日历隐藏,tableview显示模糊搜素哦的数据;);isSearchMode==false,表示处于日历模式(日历显示,tableview显示日历中选中的日期的日程).
//@property (assign,nonatomic)  BOOL isSearchMode;
@property (assign,nonatomic)  kShowPageType toShowPage;
//用于标识UItableView的滑动方向: -1 向下滑动 ，0未滑动， 1向上滑动
@property (assign,nonatomic) kScrollDirection isTableViewScroll;

@property (nonatomic, assign) NSInteger currentOperateCellRow;
@property (nonatomic, assign) NSInteger currentOperateCellSection;
@property (nonatomic,assign) BOOL searchBarShowing;

//保存  下拉刷新 加载固定条数行程 的日期偏移.
@property (strong,nonatomic)  NSDate* oldDateOffset;
////保存  下拉刷新可以获得的数据 的总和.
//@property (assign,nonatomic)  NSNumber *overDueDataTotal;

//保存  上拉刷新 加载未来日程  的日期偏移.
@property(strong,nonatomic) NSDate *futureDateOffset;

@property (nonatomic, strong) RATMenu *menu;
@property (nonatomic, strong) Events *currentEvent;

@end

@implementation OBOCalendarScheduleController

/*
 *_scheSearchDataArray的getter方法
 */
-(NSMutableArray*)scheSearchDataArray{
    if (_scheSearchDataArray==nil) {
        _scheSearchDataArray = [[NSMutableArray alloc]init];
    }
    
    return _scheSearchDataArray;
}

/*
 *_scheDateDataArray的getter方法
 */
-(NSMutableArray*)scheDateDataArray{
    
    if (_scheDateDataArray==nil) {
        _scheDateDataArray = [[NSMutableArray alloc]init];
    }
    return _scheDateDataArray;
}

/*
 *_scheListAllDataArray的getter方法
 */
-(NSMutableArray*)scheListAllDataArray{
    if (_scheListAllDataArray==nil) {
        _scheListAllDataArray = [[NSMutableArray alloc]init];
    }
    return _scheListAllDataArray;
}
/*
 *_calenderEvents 的getter方法
 */
-(NSMutableDictionary*)_calenderEvents{
    
    if (_calenderEvents==nil) {
        _calenderEvents = [[NSMutableDictionary alloc]init];
    }
    return _calenderEvents;
}

-(NSDate*)selectedDate{
    if (_selectedDate==nil) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}
/*
 * overDueDataOffset 的getter方法
 */
//-(NSDate*)overDueDateOffset{
//    if (_overDueDateOffset==nil) {
//        _overDueDateOffset = [NSDate date];
//    }
//    return _overDueDateOffset;
//}

-(NSDate*)oldDateOffset{
    if (_oldDateOffset==nil) {
        _oldDateOffset = [NSDate date];
    }
    return _oldDateOffset;
}

-(NSDate*)futureDateOffset{
    if (_futureDateOffset==nil) {
        _futureDateOffset = [NSDate date];
    }
    return _futureDateOffset;
}

-(NSString*)getCalenderHeightVFL{
    
    
    NSString* vfl_H= @"";
    
    if (self.toShowPage==kCalenderNormal) {
        
        if (self.oboCalenderView.calendar.calendarAppearance.isWeekMode) {
            vfl_H= @"V:[_oboCalenderView(130)]";
        }else{
            //vfl_H= @"V:[_oboCalenderView(325)]";
            vfl_H= @"V:[_oboCalenderView(375)]";
        }
        
        self.oboCalenderView.alpha = 1.0;
        
    }else if(self.toShowPage == kCalenderSearch){
        
        vfl_H= @"V:[_oboCalenderView(0)]";
        self.oboCalenderView.alpha = 0.0;
        
    }else if(self.toShowPage == kListNormal){
        
        vfl_H= @"V:[_oboCalenderView(0)]";
        self.oboCalenderView.alpha = 0.0;
        
    }else if(self.toShowPage==kListSearch){
        
        vfl_H= @"V:[_oboCalenderView(0)]";
        self.oboCalenderView.alpha = 0.0;
        
    }else{
        
        vfl_H= @"V:[_oboCalenderView(0)]";
        self.oboCalenderView.alpha = 0.0;
    }
    
    
    return vfl_H;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    [self.scheTableView removeHeader];
    //初始化标志位
    _isTableViewScroll = kTabviewNotScroll;
    _toShowPage = kCalenderNormal;//默认显示日历页面～
    _searchBarShowing = NO;
    //(1)加载数据------------------------
    [self  loadData:kLoadDataAll withAction:^(BOOL success){}];
    
    //(2)页面布局------------------------
    
    //背景图片
    [self addBgImage];
    
    //导航栏
    [self setNavRightBtn:@"searchBtn_nomal" HightLightImage:@"searchBtn_heighlighted" action:@selector(switchSearchBar:)];
    [self initNavigationControllerContent];
    //－搜索栏
    [self addSearchBar];
    
    //增加日历视图
    [self addCalenderView];
    
    //增加tableView
    [self addTableView];
    self.scheTableView.touchDelegate = self;
    //增加下拉刷新
    [self addRefreshAnimationWithHeadAction:@selector(getMoreOldSchedule) footAction:@selector( getMoreFutureSchedule)];
    
    //增加底部的➕号按钮
    [self addFooterView];
    
    [self initConstraints];
    
    // Do any additional setup after loading the view.
}

-(void)addBgImage{
    UIImageView*bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"whole_page_bg"]];
    [self.view addSubview:bgImage];
    bgImage.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary * dicts = NSDictionaryOfVariableBindings(bgImage);
    NSString*vfl_H = @"H:|[bgImage]|";
    NSString*vfl_V = @"V:|[bgImage]|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_H options:0 metrics:nil views:dicts]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_V options:0 metrics:nil views:dicts]];
    
}
-(void)initNavigationControllerContent{
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithStretch:@"nav_CenterNormalState"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *calenderNavBtn = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth-kNavBtnWidth*2)/2.0, (kNavHeight-kNavBtnHeight)/2.0, kNavBtnWidth, kNavBtnHeight)];
   
    [calenderNavBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    calenderNavBtn.tag = kNavCalBtnTag;
    [calenderNavBtn addTarget:self action:@selector(navBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:calenderNavBtn];
    
    UIButton *listNavBtn = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth-kNavBtnWidth*2)/2.0+kNavBtnWidth,(kNavHeight-kNavBtnHeight)/2.0, kNavBtnWidth, kNavBtnHeight)];
    listNavBtn.tag = kNavaListBtnTag;
    [listNavBtn addTarget:self action:@selector(navBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:listNavBtn];
    
    if (self.toShowPage==kListNormal||self.toShowPage==kListSearch) {
        
        [listNavBtn setImage:[UIImage imageNamed:@"list_NavBtn"] forState:UIControlStateNormal];
        [calenderNavBtn setImage:nil forState:UIControlStateNormal];

    }else{

        [calenderNavBtn setImage:[UIImage imageNamed:@"calender_NavBtn"] forState:UIControlStateNormal];
        [listNavBtn setImage:nil forState:UIControlStateNormal];
    }
    
}

-(void)addCalenderView{
    
    self.oboCalenderView = [[OBOCalenderView alloc]init];
    self.oboCalenderView.calenderDataSource = self;
    self.oboCalenderView.calenderMenuDelegate = self;
    self.oboCalenderView.oboCalenderViewDelegete = self;
    self.oboCalenderView.bgImage = [UIImage imageNamed:@"calender_covering_layer"];
    self.oboCalenderView.calenderMenuBarHeight = 38;
    self.oboCalenderView.calenderHeaderHeight = 31;
    self.oboCalenderView.leftMargin = 27;
    self.oboCalenderView.rightMargin = 27;
    self.oboCalenderView.bottomMargin =22;
    [self.view addSubview:self.oboCalenderView];
    [self.oboCalenderView addUpSwipGestureWith:@selector(upSwipAction:) AndDownSwipAction:@selector(downSwipAction:)];
    
}

-(void)addFooterView{
    
    //底部按钮
    self.oboFootTabBar = [[RATTabBar alloc]init];
    [self.oboFootTabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    //self.oboFootTabBar.backgroundColor = [UIColor greenColor];
    [self.oboFootTabBar addTabBarButtonWithName:@"tabbar_addbtnbg_normal" selName:@"tabbar_addbtnbg_highlighted"];
    self.oboFootTabBar.delegate = self;
    self.oboFootTabBar.tag = 1;//1-代表显示，0-d代表隐藏
    [self.view addSubview:self.oboFootTabBar];
}
-(void)initDatePicker{
    
    if (self.monthPicker==nil) {
        self.monthPicker = [[SRMonthPicker alloc]init];
        // I will be using the delegate here
        self.monthPicker.monthPickerDelegate = self;
        self.monthPicker.maximumYear = @2050;
        self.monthPicker.minimumYear = @1900;
        self.monthPicker.enableColourRow = NO;
        self.monthPicker.yearFirst = NO;
    }
    
}

- (void)addRefreshAnimationWithHeadAction:(SEL)headAction footAction:(SEL)footAction{
    if (self.toShowPage ==kListNormal) {
        [super addRefreshAnimationWithHeadAction:headAction footAction:footAction];
    }else if(self.toShowPage == kListSearch){
        [self.scheTableView removeHeader];
    }else if(self.toShowPage == kCalenderNormal){
        [self.scheTableView removeHeader];
    }else if(self.toShowPage == kCalenderSearch){
        [self.scheTableView removeHeader];
    }
    
    //设置footer的文字颜色
    [self.scheTableView setFooterTextColor:[UIColor colorWithHexString:@"#5f513f" alpha:1.0]];
    //[self.scheTableView setFooterTextColor:[UIColor redColor]];
}


/**上拉获得更多的过期日程*/
-(void)getMoreOldSchedule{
    
    [self loadData:kLoadPullDownRefresh withAction:^(BOOL success){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self.scheTableView reloadData];
            [self.scheTableView.header endRefreshing];
            
            //            //如果所有的数据 均已加载完毕，则去除下拉的下拉的功能。
            //            if(self.overDueDataOffset == self.overDueDataTotal){
            //
            //                [self.scheTableView removeHeader];
            //
            //            }
            
        });
        
    }];
    
}

//下拉 获得 更多将来的日程.
-(void)getMoreFutureSchedule{
    
    [self loadData:kLoadPushUpRefresh withAction:^(BOOL success){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self.scheTableView reloadData];
            [self.scheTableView.footer endRefreshing];
            
        });
        
    }];
    
}


-(void)loadData:(kLoadDataType)loadType withAction:(ActionBlock)actionBlock{
    
    if (self.toShowPage ==kCalenderNormal) {
        
        [self loadCalenderEvents];
        
        [self.scheDateDataArray removeAllObjects];
        
        [[OBODataBase sharedManager]queryEventsWithDate:self.selectedDate state:kEventStateNone byNow:NO resultList:^(NSArray *result) {
            
            NSMutableArray * arr = result.mutableCopy;
            [OBOArrayTools sortArrayByDateTime:arr ascending:YES];
            
            while (arr.count > 0) {
                OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                sameDateEvents.isShow = YES;
                [self.scheDateDataArray addObject:sameDateEvents];
                
            }
            
            [self.scheTableView reloadData];
            
            
            //数据加载成功之后，进行后续操作.
            actionBlock(YES);
            
        }];
        
    }else if(self.toShowPage == kListNormal){
        
        if (loadType == kLoadDataAll) {
            //清空数据
            [self.scheListAllDataArray  removeAllObjects];
            
            
            //加载初始数据
            [[OBODataBase sharedManager]queryAllEventsAfterDate:[NSDate date] ResultList:^(NSArray*result){
                
                NSMutableArray*arr = result.mutableCopy;
                
                //将arr 进行初步排序
                [OBOArrayTools sortArrayByDateTime:arr ascending:YES];
                
                while (arr.count > 0) {
                    OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                    [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                    sameDateEvents.isShow = YES;
                    [self.scheListAllDataArray addObject:sameDateEvents];
                }
                
                //数据加载成功之后，进行后续操作.
                actionBlock(YES);
                
                [self.scheTableView reloadData];
            }];
            
        }else if(loadType == kLoadDataInit){
            
            //清空数据
            [self.scheListAllDataArray  removeAllObjects];
            
            //加载初始数据
            
            //[[OBODataBase sharedManager]queryEventsAfterDate:[NSDate date] dayLimit:@(kPageSize) ResultList:^(NSArray *result) {
            
            [[OBODataBase sharedManager]queryEventsWithDate:[NSDate date] Direction:After dayLimit:@(kPageSize)  ResultList:^(NSArray *result) {
                NSMutableArray*arr = result.mutableCopy;
                
                //------------------------------------
                //将arr 进行初步排序
                [OBOArrayTools sortArrayByDateTime:arr ascending:YES];
                
                NSMutableArray*tmpArr = [[NSMutableArray alloc]init];
                while (arr.count > 0) {
                    OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                    [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                    sameDateEvents.isShow = YES;
                    [tmpArr addObject:sameDateEvents];
                    //[self.scheListAllDataArray addObject:sameDateEvents];
                }
                //为新请求的数据，补全空缺的“当日日程”
                tmpArr = [OBOArrayTools improveScheArray:tmpArr WithDate1:self.futureDateOffset Date_2:[NSDate dateWithStartDate:self.futureDateOffset Offset:(kPageSize-1)]];
                //------------------------------------
                
                
                [self.scheListAllDataArray addObjectsFromArray:tmpArr];
                
                self.futureDateOffset = [NSDate dateWithOffset:kPageSize];
                
                [self.scheTableView reloadData];
                
                //数据加载成功之后，进行后续操作.
                actionBlock(YES);
            }];
            
            
            
        }else if(loadType == kLoadPullDownRefresh){
            
            //加载固定条数的过往的行程数据
            
            //[[OBODataBase sharedManager]queryEventsBeforeDate:self.oldDateOffset dayLimit:@(kPageSize) ResultList:^(NSArray *result)  {
            
            [[OBODataBase sharedManager]queryEventsWithDate:self.oldDateOffset Direction:Before dayLimit:@(kPageSize)  ResultList:^(NSArray *result) {
                
                //result 已经是有序的了，按照日期，时间升序
                NSMutableArray *arr = result.mutableCopy;
                
                
                //------------------------------------
                NSMutableArray* tmpArr = [[NSMutableArray alloc]init];
                
                while (arr.count>0) {
                    
                    //取出一组数据
                    OBOEventDateListModel * sameDateEvents = [[OBOEventDateListModel alloc]init];
                    [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                    sameDateEvents.isShow = YES;
                    [tmpArr addObject:sameDateEvents];
                    
                    //[self.scheListAllDataArray insertObject:sameDateEvents atIndex:0];
                    
                }
                //为新请求的数据，补全空缺的“当日日程”
                tmpArr = [OBOArrayTools improveScheArray:tmpArr WithDate1:[NSDate dateWithStartDate:self.oldDateOffset Offset:-(kPageSize)] Date_2:[NSDate dateWithStartDate:self.oldDateOffset Offset:-1]];
                
                //------------------------------------
                
                for (int i = 0;i<tmpArr.count;i++) {
                    
                    [self.scheListAllDataArray insertObject: [tmpArr objectAtIndex:tmpArr.count-1-i] atIndex:0];
                }
                
                
                self.oldDateOffset = [NSDate dateWithStartDate:self.oldDateOffset Offset:-(kPageSize)];
                
                
                //数据加载成功之后，进行后续操作.
                actionBlock(YES);
                
            }];
            
        }else if(loadType ==kLoadPushUpRefresh){
            
            
            //加载初始数据
            
            //[[OBODataBase sharedManager]queryEventsAfterDate:self.futureDateOffset dayLimit:@(kPageSize) ResultList:^(NSArray *result) {
            
            [[OBODataBase sharedManager]queryEventsWithDate:self.futureDateOffset Direction:After dayLimit:@(kPageSize)  ResultList:^(NSArray *result) {
                
                NSMutableArray*arr = result.mutableCopy;
                
                
                //------------------------------------
                NSMutableArray* tmpArr = [[NSMutableArray alloc]init];
                while (arr.count > 0) {
                    OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                    [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                    sameDateEvents.isShow = YES;
                    //[self.scheListAllDataArray addObject:sameDateEvents];
                    [tmpArr addObject:sameDateEvents];
                }
                
                //为新请求的数据，补全空缺的“当日日程”
                tmpArr = [OBOArrayTools improveScheArray:tmpArr WithDate1:self.futureDateOffset Date_2:[NSDate dateWithStartDate:self.futureDateOffset Offset:(kPageSize-1)]];
                
                [self.scheListAllDataArray addObjectsFromArray:tmpArr];
                
                //------------------------------------
                
                self.futureDateOffset = [NSDate dateWithStartDate:self.futureDateOffset Offset:kPageSize];
                
                [self.scheTableView reloadData];
                
                //数据加载成功之后，进行后续操作.
                actionBlock(YES);
            }];
            
            
            
            
        }else if(loadType==kReloadCurrentPageData){//重新加载当前页面的数据
            
            //首先清空数据.
            [self.scheListAllDataArray  removeAllObjects];
            
            [[OBODataBase sharedManager]queryEventsWithDate1:self.oldDateOffset Date2:self.futureDateOffset ResultList:^(NSArray *result) {
                
                NSMutableArray * tmpResult = result.mutableCopy;
                
                //--------------------------------
                while (tmpResult.count > 0) {
                    
                    OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                    [sameDateEvents eventListWithSortedArray:tmpResult withFormat:YES];
                    sameDateEvents.isShow = YES;
                    [self.scheListAllDataArray addObject:sameDateEvents];
                }
                
                //为新请求的数据，补全空缺的“当日日程”
                self.scheListAllDataArray  = [OBOArrayTools improveScheArray:self.scheListAllDataArray  WithDate1:self.oldDateOffset Date_2:[NSDate dateWithStartDate:self.futureDateOffset Offset:-1]];
                //--------------------------------
                
                //重新加载表格
                [self.scheTableView reloadData];
                
                //数据加载成功之后，进行后续操作.
                actionBlock(YES);
            }];
            
            
        }else{
            
            
        }
    }else if(self.toShowPage == kCalenderSearch||self.toShowPage == kListSearch){
        
        [self.scheSearchDataArray removeAllObjects];
        
        [[OBODataBase sharedManager] queryAllEventsWithSearchKeywords:self.keyWords ResultList:^(NSArray*result){
            
            NSMutableArray * arr = result.mutableCopy;
            [OBOArrayTools sortArrayByDateTime:arr ascending:YES];
            
            while (arr.count > 0) {
                
                OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                sameDateEvents.isShow = YES;
                [self.scheSearchDataArray addObject:sameDateEvents];
                
            }
            
            [self.scheTableView reloadData];
            
            //数据加载成功之后，进行后续操作.
            actionBlock(YES);
            
        }];
    }
    
}

-(void)navBtnClicked:(id)sender{
    
    
    //(1)切换模式
    [self changePageMode_fromNav:sender];
    
    
    //(2)重新加载数据
    [self  loadData:kLoadDataInit withAction:^(BOOL success){
        
        //(3)数据加载完成之后，重新进行布局.
        [self refreshPageLayout];
        
    }];
    
    
    
    //(3)更换导航栏"日历btn"和"列表btn"的背景图片.
    
    UIButton*clickedBtn = (UIButton*)sender;
    UIButton*calenderBtn = (UIButton*)[self.navigationController.navigationBar viewWithTag:kNavCalBtnTag];
    UIButton*listBtn = (UIButton*)[self.navigationController.navigationBar viewWithTag:kNavaListBtnTag];
    
    
    if (clickedBtn == calenderBtn) {//点击了日历按钮
        
        [calenderBtn setImage:[UIImage imageNamed:@"calender_NavBtn"] forState:UIControlStateNormal];
        [listBtn setImage:nil forState:UIControlStateNormal];
        
    }else{//点击了列表按钮
        
        [calenderBtn setImage:nil forState:UIControlStateNormal];
        [listBtn setImage:[UIImage imageNamed:@"list_NavBtn"] forState:UIControlStateNormal];
    }
    
}


-(void)changePageMode_fromNav:(UIButton*)sender{
    
    NSInteger tag = sender.tag;
    if (tag==kNavCalBtnTag) {
        self.toShowPage = kCalenderNormal;
    }else{
        self.toShowPage = kListNormal;
    }
    
    [self pageModeChanged];
    //[self refreshPageLayout];
    
}

-(void)changePageMode_fromeSearch:(id)sender{
    
    if (self.toShowPage == kCalenderNormal) {
        self.toShowPage = kCalenderSearch;
    }else if(self.toShowPage == kListNormal){
        self.toShowPage =kListSearch;
    }
    [self pageModeChanged];
    
}

-(void)changePageMode_fromBackBtn:(id)sender{
    
    if (self.toShowPage == kCalenderSearch) {
        self.toShowPage = kCalenderNormal;
    }
    
    if(self.toShowPage == kListSearch){
        self.toShowPage = kListNormal;
    }
    
    [self pageModeChanged];
    
    [self refreshPageLayout];
    
}

-(void)pageModeChanged{
    
    
    //复位 上拉 下拉 刷新标志
    self.oldDateOffset = [NSDate date];
    self.futureDateOffset =[NSDate date];
    
    //只有在常规的列表日程页面  才设置上拉刷新和下拉刷新
    if (self.toShowPage == kCalenderNormal) {
        [self addRefreshAnimationWithHeadAction:nil footAction:nil];
        [self.scheTableView removeHeader];
        [self.scheTableView removeFooter];
    }else if(self.toShowPage == kCalenderSearch){
        [self addRefreshAnimationWithHeadAction:nil footAction:nil];
        [self.scheTableView removeHeader];
        [self.scheTableView removeFooter];
    }else if(self.toShowPage == kListNormal){
        
        [self addRefreshAnimationWithHeadAction:@selector(getMoreOldSchedule) footAction:@selector(getMoreFutureSchedule)];
        
    }else if(self.toShowPage == kListSearch){
        [self addRefreshAnimationWithHeadAction:nil footAction:nil];
        [self.scheTableView removeHeader];
        [self.scheTableView removeFooter];
    }
    
    
}

/*
 *加载 日历页 中当前月 中所包含的 事件。
 */
-(void)loadCalenderEvents{
    
    if (self.oboCalenderView.currentDate==nil) {
        [self loadCalenderEventsWithDate:[NSDate currentDate]];
    }else{
        [self loadCalenderEventsWithDate:self.oboCalenderView.currentDate];
    }
}

-(void)loadCalenderEventsWithDate:(NSDate*)date{
    
    // NSLog(@"currentDate:%@",self.oboCalenderView.calendar.currentDate);
    NSMutableArray* allDaysOfSelectedMonth = [NSDate getAllDaysOfCalenderMounth:date];
    
    [[OBODataBase sharedManager]queryAllCalenderEventsWithDateArray:allDaysOfSelectedMonth ResultList:^(NSMutableDictionary*resultDic){
        
        self.calenderEvents = resultDic;
        
    }];
    
    [self.oboCalenderView.calendar reloadData];
}
#pragma  SRMonthPickerDelegate

- (void)monthPickerWillChangeDate:(SRMonthPicker *)monthPicker
{
    
    
}

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker
{
    tempDatePickerDate = monthPicker.date;
}


- (void)viewDidLayoutSubviews
{
    [self.oboCalenderView.calendar repositionViews];
}

-(void)initConstraints{
    
    [self.oboSearchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.oboCalenderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scheTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.oboFootTabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *containerViews = @{@"_oboSearchBar":super.oboSearchBar,@"_oboCalenderView":self.oboCalenderView, @"_scheTableView":super.scheTableView,@"_oboFootTabBar":self.oboFootTabBar};
    
    NSString *vfl_11 = @"H:|-0-[_oboSearchBar]-0-|";
    NSString *vfl_12 = @"H:|-0-[_oboCalenderView]-0-|";
    NSString *vfl_13 = @"H:|-0-[_scheTableView]-0-|";
    NSString *vfl_14 = @"H:|-0-[_oboFootTabBar]-0-|";
    //NSString *vfl_15 = @"V:[_oboSearchBar(42)]-(12)-[_oboCalenderView][_scheTableView][_oboFootTabBar]";
    
    NSString *vfl_15 = @"V:[_oboCalenderView]-(3)-[_scheTableView][_oboFootTabBar]";//0
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_11 options:0 metrics:nil views:   containerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_12 options:0 metrics:nil views:   containerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_13 options:0 metrics:nil views:   containerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_14 options:0 metrics:nil views:   containerViews]];
    
    self.calenderLayout = [NSLayoutConstraint constraintsWithVisualFormat:vfl_15 options:0 metrics:nil views:   containerViews];
    [self.view addConstraints:self.calenderLayout];
    
    //设置搜索栏的高度
    self.searchBarConstraint = [NSLayoutConstraint constraintsWithVisualFormat: kSearchBarHideConstraint options:0 metrics:nil views:  @{@"_oboSearchBar":super.oboSearchBar,@"_oboCalenderView":_oboCalenderView}];
    [self.view addConstraints:self.searchBarConstraint];
    
    
    self.footerViewLayout = [NSLayoutConstraint constraintsWithVisualFormat:kFooterHideLayout options:0 metrics:nil views:   containerViews];
    [self.view addConstraints:self.footerViewLayout];
    
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [self.oboCalenderView.calendar setCurrentDate:[NSDate date]];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    
    NSString*key = [OBOStringTools stringFromDate:date];
    
    //NSLog(@"test Date Events%@",key);
    
    NSNumber*count= (NSNumber*)self.calenderEvents[key];
    
    if(count.intValue>0){
        
        return YES;
    }
    
    return NO;
}
/*
 *选中了日历上某个日期
 */
- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    
    //更新选中的日期
    self.toShowPage = kCalenderNormal;
    self.selectedDate = date;
    [self  loadData:kLoadDataAll withAction:^(BOOL success){}];
}

- (void)calendarDidLoadPreviousPage
{
    
    //加载 该页日历页中的 “事件数据”
    [self loadCalenderEvents];
    
}

- (void)calendarDidLoadNextPage
{
    //加载 该页日历页中的 “事件数据”
    [self loadCalenderEvents];
    
}


#pragma CalenderMenuBarDelegate

-(void)CalenderMenuLeftBtnClicked:(id)sender{
    
    [self.oboCalenderView.calendar loadPreviousPage];
    
}

-(void)CalenderMenuRightBtnClicked:(id)sender{
    
    [self.oboCalenderView.calendar loadNextPage];
}

-(void)CalenderMenuTitleBtnClicked:(id)sender{
    
    NSInteger flag =((UIView*)sender).tag;
    
    [self initDatePicker];
    CustomPopActionView * customPopView = [[CustomPopActionView alloc]initWithTitle:@"请选择日期" referView:self.view];
    customPopView.delegate = self;
    customPopView.tag = flag;
    customPopView.contentViewHeight = 200;
    [customPopView addComponentView:self.monthPicker];
    [customPopView show];
    
}

//------------------搜索栏

#pragma searchBarDelegate

//搜索框 become firstResponder
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    UIButton * cancelBtn = [[UIButton alloc]init];
    cancelBtn.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-70);
    [cancelBtn addTarget:self action:@selector(hideKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = kCandelBtnTag;
    cancelBtn.backgroundColor = [UIColor colorWithHexString:@"#eeeeee" alpha:0.5];
    [self.view addSubview:cancelBtn];
    
    return YES;
}
-(void)hideKeyBoard:(id)sender{
    
    UISearchBar* realSearchBar = (OBOSearchBar*)[self.oboSearchBar viewWithTag:kSearchBarTag];
    
    if (realSearchBar!=nil) {
        [realSearchBar resignFirstResponder];
    }
    
    UIButton * cancelBtn = (UIButton*)[self.view viewWithTag:kCandelBtnTag];
    if (cancelBtn!=nil) {
        [cancelBtn removeFromSuperview];
    }
    
}

/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    //    [self changePageMode_fromeSearch:nil];
    //    [self refreshPageLayout];
    //    //进行搜索
    //    self.keyWords = searchBar.text;
    //    [self  loadData:kLoadDataAll withAction:^(BOOL success){}];
    //
    //    //退去键盘
    //    OBOSearchBar*realSearchBar = nil;
    //    for (UIView *view  in self.oboSearchBar.leftView.subviews) {
    //        if ([view isKindOfClass:[OBOSearchBar class]]) {
    //            realSearchBar = (OBOSearchBar*)view;
    //        }
    //    }
    //
    //    if (realSearchBar!=nil) {
    //        [realSearchBar resignFirstResponder];
    //    }
    
    [self begin2Search:nil];
    
}

-(void)begin2Search:(id)sender{
    
    //去除 蒙板
    UIButton * cancelBtn = (UIButton*)[self.view viewWithTag:kCandelBtnTag];
    if (cancelBtn!=nil) {
        [cancelBtn removeFromSuperview];
    }
    
    [self changePageMode_fromeSearch:nil];
    [self refreshPageLayout];
    //进行搜索
    
    OBOSearchBar*realSearchBar = nil;
    //    for (UIView *view  in self.oboSearchBar.subviews) {
    //        if ([view isKindOfClass:[OBOCustumItem class]]) {
    //
    //            for (UIView *v in view.subviews) {
    //                if ([v isKindOfClass:[OBOSearchBar class]]) {
    //
    //                    realSearchBar = (OBOSearchBar*)v;
    //
    //                    break;
    //                }
    //            }
    //
    //        }
    //    }
    realSearchBar = (OBOSearchBar*)[self.oboSearchBar viewWithTag:kSearchBarTag];
    
    //退去键盘
    if (realSearchBar!=nil) {
        self.keyWords = realSearchBar.text;
        [self  loadData:kLoadDataAll withAction:^(BOOL success){}];
        [realSearchBar resignFirstResponder];
    }
    
}

////cancel button clicked...
//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
//{
//    NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
//
//    [self.oboSearchBar resignFirstResponder];
//
//}
////搜索结果按钮 被点击
//- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
//
//    NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
//
//}

#pragma mark -- TableViewDataSource  TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.toShowPage ==kCalenderNormal) {
        return self.scheDateDataArray.count;
    }else if(self.toShowPage == kListNormal){
        return  self.scheListAllDataArray.count;
    }else{
        return  self.scheSearchDataArray.count;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    OBOEventDateListModel* dateList = nil;
    
    if (self.toShowPage == kCalenderNormal) {
        
        dateList = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:section];
        
    }else if(self.toShowPage == kCalenderSearch){
        
        dateList = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
        
        
    }else if(self.toShowPage == kListNormal){
        
        dateList = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:section];
        
    }else if(self.toShowPage ==kListSearch){
        
        dateList = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
        
    }
    
    NSInteger rowCount = 0;
    if (dateList.isShow) {
        rowCount = [dateList.eventList count];
    }else{
        rowCount = 0;
    }
    
    return rowCount;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat height = 0.0f;
    
    if (self.toShowPage == kCalenderNormal) {
        
        height = 0.0f;
        
    }else if(self.toShowPage == kCalenderSearch){
        
        height = kTableHeaderHeight;
        
        
    }else if(self.toShowPage ==kListSearch){
        
        height = kTableHeaderHeight;
    }else{
        
        height = kTableHeaderHeight;
    }
    
    return height;
    
}


// 定义头标题的视图，添加点击事件
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    OBOEventDateListModel*model;
    if (self.toShowPage == kCalenderNormal) { //日历正常
        model = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:section];
        
    }else if(self.toShowPage == kCalenderSearch){//日历搜索
        model = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
        
    }else if(self.toShowPage == kListNormal){//列表正常
        model = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:section];
        
    }else{//列表搜索
        model = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
        
    }
    
    //日历页面 不显示 tableHeader
    
    if (self.toShowPage == kCalenderNormal) {
        return nil;
    }
    
    
    OBOTableHeaderView *headerView = [[OBOTableHeaderView alloc]init];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 27);
    headerView.delegate = self;
    
    NSDate *date = [NSDate formatDateWithString:model.date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"EE";
    
    kHeadViewDate headViewType= [date dateIsEqual:[NSDate date]]?kHeadViewDateCurrent:kHeadViewDateOther;
    
    [headerView headerViewWithDateType:headViewType date:[NSString stringWithFormat:@"%@  %@",model.date,[OBOStringTools cTransformFromE:[df stringFromDate:date]]] section:section];
    
    
    if (model.isShow) {
        [headerView.btnView setImage:[UIImage imageNamed:@"overdue_dropdown_btn_selected"] forState:UIControlStateNormal];
    }
    else{
        [headerView.btnView setImage:[UIImage imageNamed:@"overdue_dropdown_btn_normal"] forState:UIControlStateNormal];
    }

    return headerView;
    
    
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
//
//    if (self.toShowPage == kCalenderNormal) {
//        OBOEventDateListModel*model = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:section];
//        return model.date;
//    }else if(self.toShowPage == kCalenderSearch){
//        OBOEventDateListModel*model = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
//        return model.date;
//    }else if(self.toShowPage == kListNormal){
//        OBOEventDateListModel*model = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:section];
//        return model.date;
//    }else{
//        OBOEventDateListModel*model = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
//        return model.date;
//    }
//
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //    OBOEventFrameModel*eventFramemodel = nil;
    //    if (self.toShowPage == kCalenderNormal) {
    //
    //        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:indexPath.section];
    //        eventFramemodel = [dateListmodel.eventList objectAtIndex:indexPath.row];
    //
    //    }else if(self.toShowPage ==kCalenderSearch){
    //
    //        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:indexPath.section];
    //        eventFramemodel = [dateListmodel.eventList objectAtIndex:indexPath.row];
    //    }else if(self.toShowPage == kListNormal){
    //
    //        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:indexPath.section];
    //        eventFramemodel = [dateListmodel.eventList objectAtIndex:indexPath.row];
    //
    //    }else{
    //
    //        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:indexPath.section];
    //        eventFramemodel = [dateListmodel.eventList objectAtIndex:indexPath.row];
    //    }
    
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * reuseIdentifier = @"homeCell";
    
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        OBOCellContentView *contentView = [[OBOCellContentView alloc]init];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.userInteractionEnabled = YES;
        [cell.contentView addSubview:contentView];
        
        NSLog(@"未重用%ld",(long)indexPath.row);
    }
    
    
    OBOCellContentView *contentView = [cell.contentView.subviews lastObject];
    
 //    NSIndexPath * indexSelected= [tableView indexPathForSelectedRow];
    
//    
//    if (indexPath.section == indexSelected.section &&  indexPath.row == indexSelected.row) {
//        [contentView setCellSelected];
//    }else{
//        [contentView setCellUnSelected];
//    }
    
    
    contentView.hasState = YES;
    
    Events *event = nil;
    
    if (self.toShowPage ==kCalenderNormal) {
        
        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:indexPath.section];
        event = [dateListmodel.eventList objectAtIndex:indexPath.row];
    }else if(self.toShowPage ==kCalenderSearch){
        
        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:indexPath.section];
        event = [dateListmodel.eventList objectAtIndex:indexPath.row];
        
    }else if(self.toShowPage ==kListNormal){
        
        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:indexPath.section];
        event = [dateListmodel.eventList objectAtIndex:indexPath.row];
        
        
    }else{
        
        OBOEventDateListModel* dateListmodel = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:indexPath.section];
        event = [dateListmodel.eventList objectAtIndex:indexPath.row];
        
    }
    contentView.event = event;
    
    //首先去除 cell的长按手势
    [cell removeLongPressGesture];
    //然后将 将“非空”日程 添加长按手势
    if (event.classify.intValue!=kEventClassifyNone) {// “空日程”之外，都设置长按手势
        UILongPressGestureRecognizer *  longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressedAct:)];
        longPressGesture.minimumPressDuration = 1.0;
        [cell addLongPressGesture:longPressGesture];
        
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    OBOCellContentView *cellContentView;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            cellContentView = (OBOCellContentView *)view;
        }
    }
    self.currentEvent = cellContentView.event;
    
    //如果是“空日程”,则无任何操作，直接返回.
    if (self.currentEvent.classify.intValue == kEventClassifyNone) {
        return;
    }
    
    
    CGRect rc = cellContentView.stateView.frame;
    
    //如果点击了 状态区域，并且当前状态为 未处理，则无动作.
    if (CGRectContainsPoint(rc, cell.currentPoint)&&(self.currentEvent.state.intValue == kEventStatePending)) {
        return;
        
    }else if (CGRectContainsPoint(rc, cell.currentPoint) && self.currentEvent.state.intValue != kEventStatePending)
    {//如果点击了 状态区域，并且当前状态 不为 未处理，则弹出时间提示！
        RATMenu *menu = [RATMenu popUpMenuWithTable:tableView indexPath:indexPath event:cellContentView.event];
        
        menu.delegate = self;
//        menu.backgroundColor = [UIColor colorWithRed:55.0 / 255 green:55.0 / 255 blue:55.0 / 255 alpha:0.5];
        [menu show];
    
    }else{ //点击了cell,但是未点击 右侧状态区 时
        
      
        //首先设置 当前cell 背景为 选中状态.
        cellContentView.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_selected"];
        
        
        
      

        OBODetailScheController *detailVc = [[OBODetailScheController alloc]init];
        detailVc.event = self.currentEvent;
        detailVc.delegate = self;
        [self.navigationController pushViewController:detailVc animated:YES];
        
        
        // 设置当前 cell的背景 为 未选中状态.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSelector:@selector(deSelectCell:) withObject:cellContentView afterDelay:1.0];
        
        NSLog(@"当前选中行为：%ld",(long)indexPath.row);
    }
    
}
-(void)deSelectCell:(OBOCellContentView*)cellContentView{
    
    cellContentView.bgImageView.image =[UIImage imageWithStretch:@"cell_cellbg_normal"];

}

- (void)headerView:(OBOTableHeaderView *)headerView section:(NSInteger)section{
    
    OBOEventDateListModel* dateList = nil;
    
    if (self.toShowPage == kCalenderNormal) {
        dateList = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:section];
        
    }else if(self.toShowPage == kCalenderSearch){
        dateList = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
        
    }else if(self.toShowPage == kListNormal){
        dateList = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:section];
        
    }else{
        dateList = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:section];
        
    }
    
    dateList.isShow=!dateList.isShow;
    
    [self.scheTableView reloadData];
    
}

//-(void)tableHeaderViewClicked:(UIButton*)sender{
//
//
//    NSInteger index = sender.tag;
//
//    OBOEventDateListModel* dateList = nil;
//    if (self.toShowPage == kCalenderNormal) {
//        dateList = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:index];
//
//    }else if(self.toShowPage == kCalenderSearch){
//        dateList = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:index];
//
//    }else if(self.toShowPage == kListNormal){
//        dateList = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:index];
//
//    }else{
//        dateList = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:index];
//
//    }
//
//    dateList.isShow=!dateList.isShow;
//
//    [self.scheTableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
//
//
//}
//


- (void)longPressedAct:(UILongPressGestureRecognizer *)gesture  {
    
    
    if(gesture.state == UIGestureRecognizerStateBegan)
        
    {
        
        CGPoint point = [gesture locationInView:self.scheTableView];
        
        NSIndexPath * indexPath = [self.scheTableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
        // 设置 选中该cell!
        [self.scheTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        self.currentOperateCellSection = indexPath.section;
        self.currentOperateCellRow = indexPath.row;
        
        self.menu = [RATMenu popMenu];
        self.menu.delegate = self;
        self.menu.backgroundColor = [UIColor colorWithRed:55.0 / 255 green:55.0 / 255 blue:55.0 / 255 alpha:0.5];
        [self.menu show];
        
        //add your code here
        
    }
    
}

#pragma mark OBOTouchTableViewDelegate

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self tableView:tableView touches:touches selected:YES];
}

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self tableView:tableView touches:touches selected:NO];
}

- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self tableView:tableView touches:touches selected:NO];
}

- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self tableView:tableView touches:touches selected:NO];
}

- (void)tableView:(UITableView *)tableView touches:(NSSet *)touches selected:(BOOL)selected
{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:tableView];
    NSIndexPath * indexPath = [tableView indexPathForRowAtPoint:point];
    
    if (!indexPath) {
        return;
    }
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    OBOCellContentView *contentView;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            contentView = (OBOCellContentView *)view;
        }
    }
    
    UIImage *bgImage;
    if (selected) {
        bgImage = [UIImage imageWithStretch:@"cell_cellbg_selected"];
    }
    else{
        bgImage = [UIImage imageWithStretch:@"cell_cellbg_normal"];
    }
    
    
    contentView.bgImageView.image = bgImage;
}


#pragma mark -- RATMenuDelegate

- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button{
    
    if (menu == self.menu) {
        switch (button.tag) {
                
            case 0://删除操作
            {
                [self deleteScheIn_DB_Page];
            }
                break;
                
            case 1: //修改操作.
            {
                [self go2AdjustScheIn_DB_Page];
                
            }
                break;
                
            default:
                break;
        }
    }
    else{
        switch (button.tag) {
                
            case 0: //修改操作.
            {
                OBODetailScheController *detailVc = [[OBODetailScheController alloc]init];
                
                //    calendarVc.row =
                detailVc.event = self.currentEvent.adjustToEvent;
                detailVc.delegate = self;
                [self.navigationController pushViewController:detailVc animated:YES];
                
            }
                break;
                
            default:
                break;
        }
    }
    
}


/*
 *从数据库和当前页面 中删除 一个日程
 */
-(void)deleteScheIn_DB_Page{
    
    Events *event =[self getSelectedEventModel];
    
    //(1)删除DB中的选中的日程.
    [self removeDataWithEvent:event result:^(BOOL result,kInsertDataResult insertResult) {
        
        NSLog(@"从数据库 删除了一条记录！！！！！！！");
        
        if (result) {
            //（2）从页面中删除选中的日程
            [self deleteSelectedSche_FromPage];
            [self.scheTableView reloadData];
        }
    }];
    
    
}

/*
 *从页面中删除 选中cell对应的日程
 */

-(void)deleteSelectedSche_FromPage{
    
    Events*eventModel =[self getSelectedEventModel];
    OBOEventDateListModel* dateListmodel = [self getSelectedEventDateListModel];
    [dateListmodel.eventList removeObject:eventModel];
    if (dateListmodel.eventList.count == 0) {
        
        NSMutableArray *orginDataModal = [self getCurrentDateModel];
        [orginDataModal removeObject:dateListmodel];
        
    }
    
}
/*
 *弹出修改日程页面，进行修改日程操作.
 *
 */
-(void)go2AdjustScheIn_DB_Page{
    
    Events *event =[self getSelectedEventModel];
    
    // 弹出修改页面
    OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:event];
    newScheController.delegete = self;
    newScheController.operationType = kModifiedSchedule;
    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
    navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:navVc animated:YES completion:^{
        
    }];
    
}

-(OBOEventDateListModel*)getDateListModel:(NSInteger)index{
    
    OBOEventDateListModel* dateListmodel =nil;
    
    
    if (self.toShowPage == kCalenderNormal) {
        
        dateListmodel = (OBOEventDateListModel *)[self.scheDateDataArray objectAtIndex:index];
        
    }else if(self.toShowPage == kCalenderSearch){
        
        dateListmodel = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:index];
        
    }else if(self.toShowPage == kListNormal){
        
        dateListmodel = (OBOEventDateListModel *)[self.scheListAllDataArray objectAtIndex:index];
        
    }else{
        
        dateListmodel = (OBOEventDateListModel *)[self.scheSearchDataArray objectAtIndex:index];
    }
    
    return dateListmodel;
}



-(Events*)getEventModelWithSection:(NSInteger)section Row:(NSInteger)row{
    
    OBOEventDateListModel *datelistModel = [self getDateListModel:section];
    Events *event = [datelistModel.eventList objectAtIndex:row];
    
    return event;
}


/*
 *取得 当前选中的 cell 对应的OBOEventDateListModel.
 *
 */
-(OBOEventDateListModel*)getSelectedEventDateListModel{
    return [self getDateListModel:self.currentOperateCellSection];
}


/*
 *取得 当前选中cell  对应的日程数据模型  OBOEventModel
 */
-(Events*)getSelectedEventModel{
    
    return [self getEventModelWithSection:self.currentOperateCellSection Row:self.currentOperateCellRow];
    
}

/*
 *取得 当前模式下 该页面的 数据源。
 */
-(NSMutableArray*)getCurrentDateModel{
    
    if (self.toShowPage == kCalenderNormal) {
        return self.scheDateDataArray;
    }else if(self.toShowPage == kListNormal){
        return self.scheListAllDataArray;
    }else{
        return self.scheSearchDataArray;
    }
}

#pragma UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    y_next = scrollView.contentOffset.y;
    
    // NSLog(@" contentSize Height:%f ,frameSizeHeight:%f, contentOffset.y:%f",scrollView.contentSize.height,scrollView.frame.size.height,scrollView.contentOffset.y);
    
    //    if (scrollView.contentOffset.y>=(scrollView.contentSize.height-scrollView.frame.size.height)) {
    //        _isTableViewScrollUp = 1;
    //    }else if(scrollView.contentOffset.y<=0){
    //         _isTableViewScrollUp = -1;
    //    }else{
    //        _isTableViewScrollUp = 0;
    //    }
    
    
    if ((y_next-y_prev >0)&&(scrollView.contentOffset.y>20)) {
        _isTableViewScroll = kTabviewScrollUp;
    }else if((y_next-y_prev <0)&&(scrollView.contentOffset.y<-20)){
        _isTableViewScroll = kTabviewScrollDown;
    }else{
        _isTableViewScroll = kTabviewNotScroll;
    }
    
    
    if (self.toShowPage==kCalenderNormal) {//日历模式下,检测tableView滑动方向,calenderView 切换周视图和月视图.
        [self detectScollDirection];
    }
    
    
}

-(void)upSwipAction:(id)sender{

    //NSLog(@"upSwip-----");
    
    _isTableViewScroll = kTabviewScrollUp;
    [self detectScollDirection];
    
}

-(void)downSwipAction:(id)sender{

    
    //NSLog(@"downSwip-----");
    _isTableViewScroll = kTabviewScrollDown;
    [self detectScollDirection];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    
    y_prev = y_next = scrollView.contentOffset.y;
    
    NSLog(@"%s",__func__);
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    NSLog(@"%s",__func__);
    
}
#pragma 监视tableView的滑动，日历周视图和月视图切换.
-(void)detectScollDirection{
    
    if(_isTableViewScroll==kTabviewScrollUp){//上滑
        
        if(self.oboCalenderView.calendar.calendarAppearance.isWeekMode==NO){
            
            //TableView 向上滑,日历切换到周视图
            self.oboCalenderView.calendar.calendarAppearance.isWeekMode = YES;
            //[self updateCalenderViewH_WithAnimation:YES];
            [self refreshPageLayoutWithAnimation:YES];
            
            NSLog(@"TableView 向上滑,日历切换到周视图");
            
        }
        
        
        if(self.oboFootTabBar.tag ==kFooterHide){
            
            //显示底部的footerView
            [self hideFooterView:NO];
            self.oboFootTabBar.tag = kFooterShow;
            
        }
        
    }else if(_isTableViewScroll==kTabviewScrollDown){//下滑
        
        if(self.oboCalenderView.calendar.calendarAppearance.isWeekMode==YES){
            
            //(1)TableView 向下滑,日历切换到月视图
            self.oboCalenderView.calendar.calendarAppearance.isWeekMode = NO;
            
            //[self updateCalenderViewH_WithAnimation:YES];
            [self refreshPageLayoutWithAnimation:YES];
            
            //(2)隐藏底部的footerView
            [self hideFooterView:YES];
        }
        
        if(self.oboFootTabBar.tag == kFooterShow){
            
            //隐藏底部的footerView
            [self hideFooterView:YES];
            self.oboFootTabBar.tag = kFooterHide;
            
        }
        
    }
    
}

#pragma 更新页面的布局
-(void)refreshPageLayout{
    
    [self refreshPageLayoutWithAnimation:NO];
    
}

-(void)refreshPageLayoutWithAnimation:(BOOL)animation{
    
    //更新日历的layout.
    [self updateCalenderViewH_WithAnimation:animation];
    
    
}


-(void)hiddenCalender:(BOOL)hide{
    
    
    if (self.calenderLayout!=nil) {
        [self.view removeConstraints:self.calenderLayout];
    }
    
    
    NSDictionary *containerViews = @{@"_oboSearchBar":super.oboSearchBar,@"_oboCalenderView":self.oboCalenderView, @"_scheTableView":super.scheTableView,@"_oboFootTabBar":self.oboFootTabBar};
    
    
    NSString *vfl = @"";
    
    if (hide==NO) {
        vfl = @"V:[_oboSearchBar(42)]-(12)-[_oboCalenderView][_scheTableView][_oboFootTabBar]";
        self.oboCalenderView.alpha = 1.0;
    }else{
        vfl = @"V:[_oboSearchBar(42)]-(12)-[_scheTableView][_oboFootTabBar]";
        self.oboCalenderView.alpha = 0.0;
    }
    
    self.calenderLayout = [NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:   containerViews];
    
    [self.view addConstraints:self.calenderLayout];
}

#pragma 更新CalenderViewHeight
-(void)updateCalenderViewH_WithAnimation:(BOOL)animation{
    
    
    if (!animation) {//无动画效果
        
        //if(self.toShowPage == kCalenderNormal||self.toShowPage==kCalenderSearch){
        if(self.toShowPage == kCalenderNormal){
            
            [self hiddenCalender:NO];
            
        }else{
            
            [self hiddenCalender:YES];
            
        }
        
        [self.oboCalenderView refreshConstraints];
        
        
    }else{//有动画效果
        
        [UIView animateWithDuration:.5
                         animations:^{
                             
                             //                             [self.view removeConstraints:self.calenderHeight];
                             //                             self.calenderHeight = [NSLayoutConstraint constraintsWithVisualFormat:[self getCalenderHeightVFL] options:(0) metrics:nil views:NSDictionaryOfVariableBindings(_oboCalenderView)];
                             //                             [self.view addConstraints:self.calenderHeight];
                             //                             [self.view layoutIfNeeded];
                             [self.oboCalenderView refreshConstraints];
                         }];
        
        [UIView animateWithDuration:.25
                         animations:^{
                             self.oboCalenderView.calendarContentView.layer.opacity = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.oboCalenderView.calendar reloadAppearance];
                             
                             [UIView animateWithDuration:.25
                                              animations:^{
                                                  self.oboCalenderView.calendarContentView.layer.opacity = 1;
                                              }];
                         }];
        
    }
    
}

#pragma CustomPopActionDelegate
-(void)bottomPopViewOkBtnClicked:(NSInteger)flag{
    
    [self.oboCalenderView.calendar setCurrentDate:tempDatePickerDate];
    
}

#pragma RATTabBarDelegate
- (void)tabBar:(RATTabBar *)tabBar didSelectedIndex:(int)index{
    
    Events *scheModel = [[Events alloc]init];
    scheModel.startDate = self.selectedDate;
    scheModel.endDate = self.selectedDate;
    scheModel.type = @(0);
    
    OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:scheModel];
    newScheController.operationType = kInsertNewSchedule;
    newScheController.delegete = self;
    //newScheController.sheduleModel = scheModel;
    [self.navigationController pushViewController:newScheController animated:YES];
    
}
#pragma 隐藏 显示 footerView
-(void)hideFooterView:(BOOL)hidden{
    NSDictionary *containerViews = NSDictionaryOfVariableBindings(_oboFootTabBar);
    
    if (self.footerViewLayout!=nil) {
        [self.view removeConstraints:self.footerViewLayout];
    }
    
    if (hidden) {
        self.footerViewLayout = [NSLayoutConstraint constraintsWithVisualFormat:kFooterHideLayout options:0 metrics:nil views:   containerViews];
    }else{
        self.footerViewLayout = [NSLayoutConstraint constraintsWithVisualFormat:kFooterShowLayout options:0 metrics:nil views:   containerViews];
        
    }
    
    [UIView animateWithDuration:.5 animations:^{
        
        [self.view addConstraints:self.footerViewLayout];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished){
        
    }];
    
}

-(void)switchSearchBar:(UIButton*)btn{
    
    if (self.searchBarShowing==YES) {
        self.searchBarShowing = NO;
        
        [self setNavRightBtn:@"searchBtn_nomal" HightLightImage:@"searchBtn_heighlighted" action:@selector(switchSearchBar:)];
        // 隐藏搜索栏 的操作
        
    }else{
        self.searchBarShowing = YES;
        
        [self setNavRightBtn:@"searchBtn_heighlighted" HightLightImage:@"searchBtn_heighlighted" action:@selector(switchSearchBar:)];
        //显示搜索栏 的操作
    }
    
    
    [self refreshSearchBarLayout];
}

-(void)refreshSearchBarLayout{
    
    if (self.searchBarConstraint!=nil) {
        [self.view removeConstraints:self.searchBarConstraint];
    }
    
    if (self.searchBarShowing) {
        
        self.searchBarConstraint = [NSLayoutConstraint constraintsWithVisualFormat: kSearchBarShowConstraint options:0 metrics:nil views:  @{@"_oboSearchBar":super.oboSearchBar,@"_oboCalenderView":_oboCalenderView}];
    }else{
        
        //self.oboSearchBar.alpha = 0.0;
        self.searchBarConstraint = [NSLayoutConstraint constraintsWithVisualFormat: kSearchBarHideConstraint options:0 metrics:nil views:  @{@"_oboSearchBar":super.oboSearchBar,@"_oboCalenderView":_oboCalenderView}];
    }
    
    [UIView animateWithDuration:.35 animations:^{
        
        [self.view addConstraints:self.searchBarConstraint];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished){
        
        //        if (self.searchBarShowing) {
        //             self.oboSearchBar.alpha = 1.0;
        //        }
    }];
    
    
}
#pragma 导航栏左侧的 返回按钮 动作！
-(void)backBtnClicked:(id)sender{
    
    
    if (self.toShowPage == kCalenderSearch||self.toShowPage == kListSearch) {
        
        [self changePageMode_fromBackBtn:nil];
        
        
        //--feifei 此处重新加载数据
        [self  loadData:kLoadDataAll withAction:^(BOOL success){}];
        
    }else{//如果当前处于日历正常模式或这列表正常模式，则当前页面消失，退回到主页.
        
        [self dismissViewControllerAnimated:YES completion:^{}];
        
    }
    
}


#pragma OBONewScheduleDelegate
-(void)addNewSchedule:(BOOL)sucess WithDay:(NSInteger)day AndScheModel:(Events*)model{
    
    
}

//显示提示信息！
-(void)showTips:(NSString*)msg{
    RATTipsView *tipsView = [RATTipsView sharedManager];
    if (!tipsView.isShowing) {
        tipsView.labelView.text = msg;
        [tipsView show];
    }
    
}

#pragma mark -- OBOOperateDataDelegate

- (void)updateDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
    
    
    //if (self.operateDelegate!=nil &&[self.operateDelegate respondsToSelector:@selector(updateDataWithEvent:targetEvent:result:)]) {
    
    [self.operateDelegate updateDataWithEvent:event targetEvent:(Events *)targetEvent result:^(BOOL result, kInsertDataResult updateResult) {
        
        //优先显示上层的tips！
         resultBlock(result,0);
        
        
        if (result) {
            [self  loadData:kReloadCurrentPageData withAction:^(BOOL success){
                //然后再显示 默认的tips
                [self showTips:@"日程已修改"];
            }];
        }else{
                //然后再显示 默认的tips
                [self showTips:@"日程修改失败！"];
            
        }
       
       
    }];
    // }
    
}



- (void)insertDataWithEvent:(Events *)event result:(boolResult)resultBlock{
    
    [[OBODataBase sharedManager]insertEventWithEvent:event result:^(BOOL result,kInsertDataResult insertResult){
        if (result == YES) {
            NSLog(@"插入新日程成功");
            [self showTips:@"日程已添加"];//@"添加日程成功！"
            //[MBProgressHUD showSuccess:@"添加日程成功！"];
        }else {
            //NSLog(@"插入新日程失败");
            [self showTips:@"日程添加失败"];
            //[MBProgressHUD showError:@"添加日程失败！"];
            
        }
        
        //此处刷新界面  feifei-
        
        [self  loadData:kLoadDataAll withAction:^(BOOL success){}];
        
        
        resultBlock(result,insertResult);
    }];
    
}

- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent currentPage:(BOOL)currentPage result:(boolResult)resultBlock{

    if ([self.operateDelegate respondsToSelector:@selector(adjustDataWithEvent:targetEvent:currentPage:result:)]) {
        [self.operateDelegate adjustDataWithEvent:event targetEvent:targetEvent currentPage:currentPage result:^(BOOL result, kInsertDataResult insertResult) {
            
            if (result) {
                [self  loadData:kReloadCurrentPageData withAction:^(BOOL success){
                    [self showTips:@"日程已调整"];
                }];
                
            }
            resultBlock(result,0);
        }];
    }
    else{
        resultBlock(NO,0);
    }
    
}

//- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
//    
//    if ([self.operateDelegate respondsToSelector:@selector(adjustDataWithEvent:targetEvent:result:)]) {
//        [self.operateDelegate adjustDataWithEvent:event targetEvent:targetEvent result:^(BOOL result, kInsertDataResult insertResult) {
//            
//            if (result) {
//                [self  loadData:kReloadCurrentPageData withAction:^(BOOL success){}];
//                
//            }
//            resultBlock(result,0);
//        }];
//    }
//    else{
//        resultBlock(NO,0);
//    }
//}

/*
 *从数据库 删除一条记录
 */
- (void)removeDataWithEvent:(Events *)event result:(boolResult)resultBlock{
    if (self.operateDelegate!=nil&&[self.operateDelegate respondsToSelector:@selector(removeDataWithEvent:result:)])
    {
        [self.operateDelegate removeDataWithEvent:event result:^(BOOL result,kInsertDataResult insertResult){
            if (result) {
                [self showTips:@"日程已删除"];
                //[MBProgressHUD showSuccess:@"删除日程成功！"];
            }else{
                [self showTips:@"日程删除失败"];
                //[MBProgressHUD showError:@"删除日程失败！"];
            }
            resultBlock(result,insertResult);
        }];
        NSLog(@"%s",__func__);
        
    }else{
        resultBlock(NO,0);
    }
}

#pragma MGSwipeTableCell Delegate

//使能 或禁止 左滑 右滑.
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction{
    
    if (direction==MGSwipeDirectionRightToLeft) {
        
        
        OBOCellContentView *contentView;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[OBOCellContentView class]]) {
                contentView = (OBOCellContentView *)view;
            }
        }
        if ((contentView!=nil)&&(contentView.event!=nil)) {
            
            Events *event = contentView.event;
            if (event.classify.intValue!=kEventClassifyNone) { //"非空日程" 可以右滑
                return YES;
            }else{                                              //"空日程"不可以右滑
                return NO;
            }
            
        }else{
            
            return NO;
        }
        
        
    }else{
        return NO;
    }
}


//设置 左滑 或 右滑 的按钮数组，以及按钮的转换样式，扩张选项
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings{
    
    if (direction==MGSwipeDirectionRightToLeft) {
        
        //变换方式
        swipeSettings.transition = MGSwipeTransitionStatic;
        
        //扩张方式
        expansionSettings.buttonIndex = -1;//所有按钮均不扩张
        expansionSettings.fillOnTrigger = NO;//扩张按钮，不填充全部cell.
        
        return [OBOArrayTools createRightButtons];
    }else{
        
        return nil;
    }
    
    
    
}

//点击侧边按钮的动作
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    
    NSIndexPath *indexPath = [self.scheTableView indexPathForCell:cell];
    self.currentOperateCellSection = indexPath.section;
    self.currentOperateCellRow = indexPath.row;
    Events *event = [self getSelectedEventModel];
    
    if(direction ==MGSwipeDirectionRightToLeft){
        switch (index) {
                
            case 0:
            {
                Events *target = [event mutableCopy];
                target.state = @(kEventStateComplete);
                
                [self updateDataWithEvent:event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
                    
                    NSLog(@"%s",__func__);
                    [self showTips:@"日程已完成"];
                    
                }];
                
                NSLog(@"您点击了完成按钮");
            }
                break;
                
            case 1:
                
            {
                
                Events *target = [event mutableCopy];
                target.state = @(kEventStateCancelled);
                
                [self updateDataWithEvent:event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
                    
                      NSLog(@"%s",__func__);
                     [self showTips:@"日程已取消"];
                
                }];
                NSLog(@"您点击了取消按钮");
                
            }
                
                break;
                
                
            case 2:
            {
                // 弹出修改页面
                OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:event];
                newScheController.delegete = self;
                newScheController.operationType = kAdjustSchedule;
                OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
                navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                
                [self presentViewController:navVc animated:YES completion:^{
                    
                }];
                
                NSLog(@"您点击了调整按钮");
                
            }
                
                break;
                
            default:
                break;
        }
    }
    return YES;
}






-(void)viewWillAppear:(BOOL)animated{
    
    [self setNavLeftBtn:@"navbar_back_normal" HightLightImage:@"navbar_back_hightlighted" action:@selector(backBtnClicked:)];
    
    [self initNavigationControllerContent];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
 
    
    
    UIButton*calenderBtn = (UIButton*)[self.navigationController.navigationBar viewWithTag:kNavCalBtnTag];
    [calenderBtn removeFromSuperview];
    
    UIButton*listBtn = (UIButton*)[self.navigationController.navigationBar viewWithTag:kNavaListBtnTag];
    [listBtn removeFromSuperview];
    

    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithStretch:@"navbar_bgImage"] forBarMetrics:UIBarMetricsDefault];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}
@end
