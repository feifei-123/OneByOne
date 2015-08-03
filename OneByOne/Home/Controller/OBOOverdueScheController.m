//
//  OBO_OverdueScheVController.m
//  OneByOne
//
//  Created by RAT on 15-5-13.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import "OBOOverdueScheController.h"
#import "OBODetailScheController.h"
//#import "OBOEventFrameModel.h"
#import "Events.h"
#import "OBOEventDateListModel.h"
#import "MGSwipeTableCell.h"
#import "OBOCellContentView.h"
#import "RATMenu.h"
#import "RATTipsView.h"
#import "Constants.h"
#import "OBODataBase.h"
//#import "CoreDataManager.h"
#import "OBOStringTools.h"
#import "MBProgressHUD+MJ.h"
#import "MGSwipeButton.h"
#import "Utils.h"
#import "OBOTableController.h"
#import "MJRefresh.h"
#import "UIBarButtonItem+Extension.h"
#import "RATTabBar.h"
#import "OBONewScheController.h"
#import "OBONavigationController.h"
#import "OBOArrayTools.h"
#import "OBOTableHeaderView.h"
#import "NSDate+helper.h"
#import "UIImage+stretch.h"

@interface OBOOverdueScheController() <MGSwipeTableCellDelegate,RATMenuDelegate,OBOOperateDataDelegate,RATTabBarDelegate,OBOTableHeaderViewDelegate,OBOTouchTableViewDelegate>

@property (nonatomic, strong) RATTabBar *tabBar;

@property (nonatomic, strong) NSLayoutConstraint *tabBarConstraint;

@property (nonatomic, strong) NSMutableArray *eventDataList;
@property (nonatomic, strong) OBOEventDateListModel *todayData;

//@property (nonatomic, strong) NSMutableArray *cellSelectState;

@property (nonatomic, assign) NSInteger currentOperateCellRow;
@property (nonatomic, assign) NSInteger currentOperateCellSection;
//@property (nonatomic, assign) NSInteger offset;
//@property (nonatomic, assign) NSInteger limit;
//@property (nonatomic, assign) NSInteger total;

@property (nonatomic, assign) NSInteger totalSelectedCell;
@property (nonatomic, assign) NSInteger totalCell;

@property (nonatomic, assign) BOOL allSelected;
@property (nonatomic, assign) BOOL hasAddData;

@property (nonatomic, strong) NSDate *currentDate;

@end

@implementation OBOOverdueScheController

#pragma mark -- 懒加载

- (NSMutableArray *)eventDataList{
    if (_eventDataList == nil) {
        _eventDataList = [[NSMutableArray alloc]init];
    }
    return _eventDataList;
}

//- (NSMutableArray *)cellSelectState{
//    if (_cellSelectState == nil) {
//        _cellSelectState = [[NSMutableArray alloc]init];
//    }
//    return _cellSelectState;
//}

- (void)setTotalSelectedCell:(NSInteger)totalSelectedCell{
    
    _totalSelectedCell = totalSelectedCell;
    if (totalSelectedCell == 0) {
        for (UIButton *btn in self.tabBar.btnArray) {
            btn.enabled = NO;
        }
    }
    else
    {
        if (totalSelectedCell == 1) {
            for (UIButton *btn in self.tabBar.btnArray) {
                btn.enabled = YES;
            }
        }
        else{
            for (int i = 0; i < self.tabBar.btnArray.count; i++) {
                UIButton *btn = self.tabBar.btnArray[i];
                if (i == 0) {
                    btn.enabled = NO;
                }
                else{
                    btn.enabled = YES;
                }
            }
        }
    }
}

#pragma mark -- 数据加载
- (void)loadData{
    //            sql = [NSString stringWithFormat:@"%@ order by startDate desc,startTime desc",sql];
    
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
    dict1[@"property"] = @"startDate";
    dict1[@"sort"] = @"desc";
    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc]init];
    dict2[@"property"] = @"startTime";
    dict2[@"sort"] = @"desc";
    NSMutableDictionary *dict3 = [[NSMutableDictionary alloc]init];
    dict3[@"property"] = @"timeStamp";
    dict3[@"sort"] = @"desc";
    
    NSArray *arr = [NSArray arrayWithObjects:dict1, dict2,dict3, nil];
    
    [[OBODataBase sharedManager] queryEventsWithDate:self.currentDate state:kEventStatePending offset:0 limit:-1 orderBy:arr resultList:^(NSArray *result, int total) {
        
        [self.eventDataList removeAllObjects];
        if (self.todayData != nil) {
            [self.eventDataList addObject:self.todayData];
        }
        NSMutableArray *arr = result.mutableCopy;
        
        while (arr.count > 0) {
            OBOEventDateListModel *dateList = [[OBOEventDateListModel alloc]init];
            [dateList eventListWithSortedArray:arr withFormat:NO];
            OBOEventDateListModel *list = [self.eventDataList lastObject];
            
            if ([list.date isEqualToString:dateList.date]) {
                [list.eventList addObjectsFromArray:dateList.eventList];
                [list sortSelfEventListWithFormat:NO];
            }
            else{
                [self.eventDataList addObject:dateList];
            }
            
        }
        
        [self.scheTableView reloadData];
    }];
}

//- (void)setEventDataList:(NSMutableArray *)eventDataList{
//    if (_eventDataList == nil) {
//        _eventDataList = [[NSMutableArray alloc]init];
//    }
//    self.eventDataList = eventDataList;
////    [self.tableView reloadData];
//}

- (void)addData:(OBOEventDateListModel *)dataList date:(NSDate *)date{
    //    NSIndexSet *index = [NSIndexSet indexSetWithIndex:0];
    //    [self.eventDataList insertObjects:array atIndexes:index];
    //    NSMutableArray *cellStateArray = [[NSMutableArray alloc]init];
    //    for (int i = 0; i < dataList.eventList.count; i ++) {
    //        [cellStateArray addObject:[[NSNumber alloc]initWithBool:NO]];
    //    }
    if (dataList.eventList.count > 0) {
        //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        //        [dict setValue:dataList.date forKey:@"date"];
        //        [self.cellSelectState addObject:dict];
        //        [dict setValue:cellStateArray forKey:@"list"];
        self.todayData = dataList;
    }
    
    self.currentDate = date;
    
    [self loadData];
    self.hasAddData = YES;
    
}

- (void)updateTodayUntreatedData:(NSNotification *)notification{
    NSArray *arr = notification.object;
    if (self.hasAddData) {
        //        OBOEventDateListModel *dateList;
        if (self.eventDataList.count > 0) {
            self.todayData = [self.eventDataList objectAtIndex:0];
        }
        else{
            self.todayData = nil;
        }
        
        if ([self.todayData.date isEqualToString:[NSDate stringFromDate:[NSDate date]]]) {
            //                dateList =
            self.todayData.date = [NSDate stringFromDate:[NSDate date]];
            self.todayData.eventList = [arr mutableCopy];
            if (self.todayData.eventList.count == 0) {
                [self.eventDataList removeObject:self.todayData];
            }
        }
        else{
            if (arr.count != 0) {
                OBOEventDateListModel *list = [[OBOEventDateListModel alloc]init];
                list.date = [NSDate stringFromDate:[NSDate date]];
                list.eventList = [arr mutableCopy];
                [self.eventDataList insertObject:list atIndex:0];
            }
        }
        [self.scheTableView reloadData];
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTableView];
    self.scheTableView.touchDelegate = self;
    //    self.view.backgroundColor = [UIColor clearColor];
    
    //    [self.navigationController.navigationBar sett]
    self.navigationItem.title = @"过往日程";
    UIImage *bgImage = [UIImage imageNamed:@"overdue_bgimage"];
    self.view.layer.contents = (id)bgImage.CGImage;
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    //    self.view.backgroundColor = [UIColor greenColor];
    
    //导航栏 右侧按钮；
    [self addNavRightBtn:@"navbar_more_normal" HightLightImage:@"navbar_more_hightlighted" action:@selector(edit)];
    self.scheTableView.backgroundColor = [UIColor clearColor];
    [self.scheTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.scheTableView.contentInset = UIEdgeInsetsMake(kNavBarPadding, 0, 0, 0);
    //    self.scheTableView.contentOffset = CGPointMake(0, 12);
#warning 在ios7中需要设置该属性防止系统自动对scrollView进行布局，从而出现布局错乱
    self.automaticallyAdjustsScrollViewInsets = NO;
    //    self.scheTableView.backgroundColor = [UIColor greenColor];
    
    _tabBar = [[RATTabBar alloc]init];
    
    _tabBar.backgroundColor = [UIColor whiteColor];
    //    UIImage *tabBarBgImage = [UIImage imageNamed:@"navbar_menu_bgimage"];
    //    _tabBar.layer.contents = (id)tabBarBgImage.CGImage;
    //    _tabBar.layer.backgroundColor = [UIColor clearColor].CGColor;
    _tabBar.bgImage = [UIImage imageNamed:@"navbar_menu_bgimage"];
    
    _tabBar.delegate = self;
    [_tabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_tabBar addTabBarButtonWithName:@"cell_adjust_normal" selName:nil];
    [_tabBar addTabBarButtonWithName:@"cell_cancel_normal" selName:nil];
    [_tabBar addTabBarButtonWithName:@"cell_complete_normal" selName:nil];
    
    [self.view addSubview:_tabBar];
    //    //初始化数据
    //    [self initDataArray];
    //    //增加TableView
    //    [self addTableView];
    //    //初始化约束条件
    //    [self initConstraints];
    //    self.scheTableView.frame = self.view.bounds;
    //    [self addHeadRefreshController];
    
    //    [self addRefreshAnimationWithHeadAction:nil footAction:@selector(loadMoreData)];
    
    // 添加约束
    UITableView *tableView = self.scheTableView;
    //    UINavigationBar *navBar = self.navigationController.navigationBar;
    NSDictionary *dict = NSDictionaryOfVariableBindings(tableView,_tabBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[tableView]-0-|" options:0 metrics:nil views:dict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tableView]-0-[_tabBar]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_tabBar]-0-|" options:0 metrics:nil views:dict]];
    
    self.tabBarConstraint = [[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tabBar(0)]" options:0 metrics:nil views:dict] lastObject];
    
    [self.view addConstraint:self.tabBarConstraint];
    //    self.tabBarConstraint.constant = 44;
    
    // 添加通知
    [[NSNotificationCenter defaultCenter]
     
     addObserver:self selector:@selector(updateTodayUntreatedData:) name:@"updateTodayUntreatedData" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)edit{
    
    // 修改导航栏左按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:@"全部" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(selectAllCell) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    // 修改导航栏右按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(selectCancel) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    //    [UIBarButtonItem itemWithTarget:self action:@selector(dismiss) image:@"navigationbar_back" highImage:@"navigationbar_back_highlighted"];
    // 将所有可见的cell选中状态置为UITableViewCellSelectionStyleGray
    //    [self.scheTableView removeFooter];
    NSArray *arr = [self.scheTableView visibleCells];
    for (UITableViewCell *cell in arr) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.backgroundColor = [UIColor whiteColor];
    }
    //    [self.scheTableView reloadData];
    
    // 设置表格状态
    self.scheTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.scheTableView setEditing:YES animated:YES];
    
    
    // 打开所有的隐藏表格
    BOOL needReload = NO;
    for (OBOEventDateListModel *dateList in self.eventDataList) {
        if (!dateList.isShow) {
            dateList.isShow = YES;
            needReload = YES;
        }
    }
    
    [self.scheTableView reloadData];
    
    self.totalCell = 0;
    for (int i = 0; i < [self.scheTableView numberOfSections]; i++) {
        self.totalCell += [self.scheTableView numberOfRowsInSection:i];
    }
    self.totalSelectedCell = 0;
    
    //    [self.cellSelectState removeAllObjects];
    // 初始化各个cell选择状态数组
    //    for (int i = 0; i < self.eventDataList.count; i++) {
    //        OBOEventDateListModel *dateList = self.eventDataList[i];
    //
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    //        [dict setValue:dateList.date forKey:@"date"];
    //        NSMutableArray *arr = [[NSMutableArray alloc]init];
    //
    //        for (int j = 0; j < dateList.eventList.count; j++) {
    //
    //            [arr addObject:[NSNumber numberWithBool:NO]];
    //            self.totalCell++;
    //        }
    //        [dict setValue:arr forKey:@"list"];
    //        [self.cellSelectState addObject:dict];
    //    }
    
    // 显示底部的tabbar
    //    UITableView *tableView = self.scheTableView;
    //    NSDictionary *dict = NSDictionaryOfVariableBindings(tableView,_tabBar);
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[tableView]-0-|" options:0 metrics:nil views:dict]];
    //
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[_tabBar]-0-|" options:0 metrics:nil views:dict]];
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_tabBar]-0-|" options:0 metrics:nil views:dict]];
    //
    //    self.tabBarConstraint = [[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tabBar(44)]" options:0 metrics:nil views:dict] lastObject];
    
    
    //    [self.view removeConstraint:self.tabBarConstraint];
    self.tabBarConstraint.constant = 49;
    //    [self.view addConstraint:self.tabBarConstraint];
    //    [self.scheTableView reloadData];
    //    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    //    [self.scheTableView]
    
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.dismissDelegate respondsToSelector:@selector(dismissControllerWithOverdueSche:)]) {
            [self.dismissDelegate dismissControllerWithOverdueSche:self];
        }
    }];
}

- (void)selectAllCell{
    //    self.allSelected = YES;
    //    NSArray *arr = [self.scheTableView visibleCells];
    //    for (UITableViewCell *cell in arr) {
    //        [cell setSelected:YES];
    //    }
    //    [self.scheTableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    //    [self.cellSelectState removeAllObjects];
    
    // 如果为全选状态则取消全选
    if (self.totalCell == self.totalSelectedCell) {
        [self.scheTableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.totalSelectedCell = 0;
    }
    else{// 否则全选
        self.totalSelectedCell = self.totalCell;
        
        for (int i = 0; i < [self.scheTableView numberOfSections]; i++) {
            for (int j = 0; j < [self.scheTableView numberOfRowsInSection:i]; j++) {
                [self.scheTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        //        for (int i = 0; i < self.eventDataList.count; i++) {
        //            OBOEventDateListModel *dateList = self.eventDataList[i];
        //
        //            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        //            [dict setValue:dateList.date forKey:@"date"];
        //            NSMutableArray *arr = [[NSMutableArray alloc]init];
        //
        //            for (int j = 0; j < dateList.eventList.count; j++) {
        //
        //                [self.scheTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:NO scrollPosition:UITableViewScrollPositionNone];
        //                [arr addObject:[NSNumber numberWithBool:YES]];
        //            }
        //            [dict setValue:arr forKey:@"list"];
        //            [self.cellSelectState addObject:dict];
        //        }
    }
}

- (void)selectCancel{
    
    // 修改导航栏左按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"navbar_back_normal" highImage:@"navbar_back_hightlighted"];
    
    // 修改导航栏右按钮
    //    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"navigationbar_back" highImage:@"navigationbar_back_highlighted"];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(edit) image:@"navbar_more_normal" highImage:@"navbar_more_hightlighted"];
    
    [self.scheTableView setEditing:NO animated:YES];
    
    //    [self addRefreshAnimationWithHeadAction:nil footAction:@selector(loadMoreData)];
    
    NSArray *arr = [self.scheTableView visibleCells];
    for (UITableViewCell *cell in arr) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    self.tabBarConstraint.constant = 0;
}

- (void)loadMoreData
{
    [self loadData];
}


-(void)initDataArray{
    
    //    self.scheList = [[NSMutableArray alloc]init];
    //    // 加载数据
    //
    //    for (int i = 0; i<10; i++) {
    //        [self.scheList addObject:[NSString stringWithFormat:@"过往行程%d",i]];
    //    }
    
    //    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.delegate = self;
    //    self.tableView.dataSource = self;
    
    //    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    
    //    [self loadData];
    
    // Do any additional setup after loading the view.
}


#pragma mark -- tableView的delegate和datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.eventDataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    OBOEventDateListModel *data = self.eventDataList[section];
    
    //    NSString *str = data.date;
    if (data.isShow) {
        return data.eventList.count;
    }
    else{
        return 0;
    }
    //    return self.eventDateList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * reuseIdentifier = @"homeCell";
    
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        OBOCellContentView *contentView = [[OBOCellContentView alloc]init];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:contentView];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressedAct:)];
        gesture.minimumPressDuration = 1.0;
        [cell addGestureRecognizer:gesture];
        
        
        NSLog(@"未重用%ld",(long)indexPath.row);
    }
    
    
    //    cell.textLabel.text = @"123";
    //    cell.textLabel.font = [UIFont systemFontOfSize:16];
    //    cell.detailTextLabel.text = @"zwm";
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    OBOCellContentView *contentView = [cell.contentView.subviews lastObject];
    
    //    int i = indexPath.section;
    //    int n = indexPath.row;
    contentView.hasState = YES;
    if (self.eventDataList.count - 1 < indexPath.section) {
        return nil;
    }
    OBOEventDateListModel *data = self.eventDataList[indexPath.section];
    
    if (data.eventList.count - 1 < indexPath.row) {
        return nil;
    }
    Events *event = data.eventList[indexPath.row];
    //    if (frame.event.classify.intValue == kEventClassifyEvent) {
    //        int i = 0;
    //        i++;
    //    }
    //    else{
    //        int i = 0;
    //        i++;
    //    }
    contentView.hasState = YES;
    contentView.event = event;
    //    cell.selectedBackgroundView = contentView.bgImageView;
    if (tableView.editing) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //        [cell setSelected:YES];
    //    [cell setSelected:YES animated:YES];
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    NSLog(@"%d",self.eventFrameList.count);
    
    //    OBOEventDateListModel *data = self.eventDataList[indexPath.section];
    //    OBOEventFrameModel *eventFrame = data.eventList[indexPath.row];
    return kCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    OBOTableHeaderView *headerView = [[OBOTableHeaderView alloc]init];
    
    
    //    NSString *str = data.date;

    OBOEventDateListModel *model = self.eventDataList[section];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 27);
    headerView.delegate = self;
  
    if (model.isShow) {
        [headerView.btnView setImage:[UIImage imageNamed:@"overdue_dropdown_btn_selected"] forState:UIControlStateNormal];
    }
    else{
        [headerView.btnView setImage:[UIImage imageNamed:@"overdue_dropdown_btn_normal"] forState:UIControlStateNormal];
    }
    NSDate *date = [NSDate formatDateWithString:model.date];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat = @"EE";
    [headerView headerViewWithDateType:!section?kHeadViewDateCurrent: kHeadViewDateOther date:[NSString stringWithFormat:@"%@ %@",model.date,[OBOStringTools cTransformFromE:[df stringFromDate:date]]] section:section];
    
    //    UIButton *btn = [[UIButton alloc]init];
    //
    //    [btn setTitle:model.date forState:UIControlStateNormal];
    //    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ////    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    //    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    //    btn.backgroundColor = [UIColor grayColor];
    ////    label.text = model.date;
    //    btn.tag = section;
    //    [btn addTarget:self action:@selector(headerViewClick:) forControlEvents:UIControlEventTouchUpInside];
    return headerView;
}

//- (void)headerViewClick:(UIButton *)btn{
//    if (!self.scheTableView.editing) {
//        OBOEventDateListModel *dataList = self.eventDataList[btn.tag];
//        dataList.isShow = !dataList.isShow;
//        [self.scheTableView reloadData];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.scheTableView.editing) {
        //        NSMutableDictionary *dict = self.cellSelectState[indexPath.section];
        //        NSMutableArray *arr = dict[@"list"];
        //        [dict setValue:[NSNumber numberWithBool:YES] forKey:@"list"];
        //        arr[indexPath.row] = [NSNumber numberWithBool:YES];
        self.totalSelectedCell++;
        return;
    }
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    OBOCellContentView *contentView;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            contentView = (OBOCellContentView *)view;
        }
    }
    
//    contentView.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_selected"];
    
    self.currentOperateCellRow = indexPath.row;
    self.currentOperateCellSection = indexPath.section;
    CGRect rc = contentView.stateView.frame;
    if (CGRectContainsPoint(rc, cell.currentPoint)) {
        return;
    }
    
    OBODetailScheController *detailVc = [[OBODetailScheController alloc]init];
    OBOEventDateListModel * dataList = self.eventDataList[indexPath.section];
    Events *event = dataList.eventList[indexPath.row];
    
    //    calendarVc.row =
    detailVc.event = event;
    detailVc.delegate = self;
    [self.navigationController pushViewController:detailVc animated:YES];
    NSLog(@"当前选中行为：%ld",(long)indexPath.row);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.scheTableView.editing) {
        //        NSMutableDictionary *dict = self.cellSelectState[indexPath.section];
        //        NSMutableArray *arr = dict[@"list"];
        //        //        [dict setValue:[NSNumber numberWithBool:YES] forKey:@"list"];
        //        arr[indexPath.row] = [NSNumber numberWithBool:NO];
        self.totalSelectedCell--;
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:[touch view]];
    NSIndexPath * indexPath = [self.scheTableView indexPathForRowAtPoint:point];
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[self.scheTableView cellForRowAtIndexPath:indexPath];
    
    OBOCellContentView *contentView;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            contentView = (OBOCellContentView *)view;
        }
    }
    
    contentView.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_selected"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:[touch view]];
    NSIndexPath * indexPath = [self.scheTableView indexPathForRowAtPoint:point];
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[self.scheTableView cellForRowAtIndexPath:indexPath];
    
    OBOCellContentView *contentView;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            contentView = (OBOCellContentView *)view;
        }
    }
    
    contentView.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_normal"];
}

- (void)longPressedAct:(UILongPressGestureRecognizer *)gesture  {
    if(gesture.state == UIGestureRecognizerStateBegan)
        
    {
        
        CGPoint point = [gesture locationInView:self.scheTableView];
        
        NSIndexPath * indexPath = [self.scheTableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
        self.currentOperateCellSection = indexPath.section;
        self.currentOperateCellRow = indexPath.row;
        
        RATMenu *menu = [RATMenu popMenu];
        menu.delegate = self;
        menu.backgroundColor = [UIColor colorWithRed:55.0 / 255 green:55.0 / 255 blue:55.0 / 255 alpha:0.5];
        [menu show];
        
        //add your code here
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kTableHeaderHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    // (...) configure cell
//
//    if (indexPath.row < 4) {
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    } else {
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//}
/**
 *  为了解决tableview设置了contentinset后section悬停位置不是最上方的问题
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y<=kNavBarPadding && scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(kNavBarPadding - scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= kNavBarPadding) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y<=0){
        scrollView.contentInset = UIEdgeInsetsMake(kNavBarPadding, 0, 0, 0);
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

#pragma mark MGSwipeTableCell的Delegate

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    //    MGSwipeTransitionBorder
    //    MGSwipeTransitionStatic
    //    MGSwipeTransitionClipCenter
    //    MGSwipeTransitionDrag
    //    MGSwipeTransition3D
    OBOCellContentView *contentView;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            contentView = (OBOCellContentView *)view;
        }
    }
    Events *event = contentView.event;
    if (event.state.intValue == kEventStatePending) {
        swipeSettings.transition = MGSwipeTransitionStatic;
        
        if (direction == MGSwipeDirectionRightToLeft) {
            expansionSettings.buttonIndex = -1;
            expansionSettings.fillOnTrigger = YES;
            
            return [OBOArrayTools createRightButtons];
        }
    }
    
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    //    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
    //        //delete button
    //        NSIndexPath * path = [self.tableView indexPathForCell:cell];
    //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    //    }
    
    NSIndexPath *indexPath = [self.scheTableView indexPathForCell:cell];
    self.currentOperateCellSection = indexPath.section;
    self.currentOperateCellRow = indexPath.row;
    if (direction == MGSwipeDirectionRightToLeft && index == 2) {
        //delete button
        // 调整按钮
        OBOCellContentView *contentView;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[OBOCellContentView class]]) {
                contentView = (OBOCellContentView *)view;
            }
        }
        Events *event = contentView.event;
        
        // 弹出修改页面
        OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:event];
        newScheController.delegete = self;
        newScheController.sheduleModel = event;
        newScheController.operationType = kAdjustSchedule;
        OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
        navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:navVc animated:YES completion:^{
            //[self loadData];
        }];
        //        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        //delete button
        // 取消按钮
        //        OBOCellContentView *contentView = [cell.contentView.subviews firstObject];
        OBOEventDateListModel *data = self.eventDataList[self.currentOperateCellSection];
        Events *event = data.eventList[self.currentOperateCellRow];
        Events *target = [event mutableCopy];
        //        Events *target = [[Events alloc]init];
        //        [target evaluateWithEvent:event];
        target.state = @(kEventStateCancelled);
        
        [self updateDataWithEvent:event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
            NSLog(@"%s",__func__);
            if (result) {
//                [data.eventList removeObject:event];
//                //                eventFrame.event = event;
//                if (data.eventList.count == 0) {
//                    [self.eventDataList removeObject:data];
//                }
//                [self.scheTableView reloadData];
                RATTipsView *tipsView = [RATTipsView sharedManager];
                if (!tipsView.isShowing) {
                    tipsView.labelView.text = @"日程已取消";
                    [tipsView show];
                }
            }
        }];
        
        
        //        [self updateDataWithEvent:event result:^(BOOL result,kInsertDataResult insertResult) {
        //            //            [self loadData];
        //        }];
        //        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        //delete button
        // 完成按钮
        OBOEventDateListModel *data = self.eventDataList[self.currentOperateCellSection];
        Events *event = data.eventList[self.currentOperateCellRow];
        Events *target = [event mutableCopy];
        //        Events *target = [[Events alloc]init];
        //        [target evaluateWithEvent:event];
        target.state = @(kEventStateComplete);
        
        [self updateDataWithEvent:event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
            NSLog(@"%s",__func__);
            if (result) {
//                [data.eventList removeObject:event];
//                //                eventFrame.event = event;
//                if (data.eventList.count == 0) {
//                    [self.eventDataList removeObject:data];
//                }
//                [self.scheTableView reloadData];
                RATTipsView *tipsView = [RATTipsView sharedManager];
                if (!tipsView.isShowing) {
                    tipsView.labelView.text = @"日程已完成";
                    [tipsView show];
                }
            }
        }];
        //        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    return YES;
}

//-(NSArray *) createRightButtons: (int) number
//{
//    NSMutableArray * result = [NSMutableArray array];
//    NSString* titles[3] = {@"完成", @"取消", @"调整"};
//    UIColor * colors[3] = {[UIColor redColor], [UIColor lightGrayColor], [UIColor orangeColor]};
//    for (int i = 0; i < number; ++i)
//    {
//        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
//            NSLog(@"Convenience callback received (right).");
//            return YES;
//        }];
//        [result addObject:button];
//    }
//    return result;
//}
#pragma mark -- RATMenuDelegate

- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button{
    switch (button.tag) {
        case 0:
        {
            OBOEventDateListModel *data = self.eventDataList[self.currentOperateCellSection];
            Events *event = data.eventList[self.currentOperateCellRow];
            [self removeDataWithEvent:event result:^(BOOL result,kInsertDataResult insertResult) {
                NSLog(@"%s",__func__);
                if (result) {
                    [data.eventList removeObject:event];
                    if (data.eventList.count == 0) {
                        [self.eventDataList removeObject:data];
                    }
                    RATTipsView *tipsView = [RATTipsView sharedManager];
                    if (!tipsView.isShowing) {
                        tipsView.labelView.text = @"日程已删除";
                        [tipsView show];
                    }
                    [self.scheTableView reloadData];
                }
            }];
        }
            break;
        case 1:
        {
            OBOEventDateListModel *dataList = self.eventDataList[self.currentOperateCellSection];
            Events *event = dataList.eventList[self.currentOperateCellRow];
            
            // 弹出修改页面
            OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:event];
            newScheController.delegete = self;
            newScheController.sheduleModel = event;
            newScheController.operationType = kModifiedSchedule;
            OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
            navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentViewController:navVc animated:YES completion:^{
                //[self loadData];
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- OBOOperateDataDelegate


- (void)updateDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
    
    RATTipsView *tipsView = [RATTipsView sharedManager];
    
    if ([self.delegate respondsToSelector:@selector(updateDataWithEvent:targetEvent:result:)]) {
        [self.delegate updateDataWithEvent:event targetEvent:(Events *)targetEvent result:^(BOOL result, kInsertDataResult insertResult) {
            resultBlock(result,insertResult);
            if (result) {
                OBOEventDateListModel *dataList = self.eventDataList[self.currentOperateCellSection];
                [dataList.eventList removeObjectAtIndex:self.currentOperateCellRow];
                if (dataList.eventList.count == 0) {
                    [self.eventDataList removeObject:dataList];
                }
                //            flag = YES;
                //        }
                // 插入数据
                if ([targetEvent.startDate compare:[NSDate currentDate]] == NSOrderedAscending) {
                    if (targetEvent.state.intValue == kEventStatePending) {
                        [self insertIntoDataList:self.eventDataList event:targetEvent];
                    }
                    
                }
                [self.scheTableView reloadData];
                
                if (!tipsView.isShowing) {
                    tipsView.labelView.text = @"日程已修改";
                    [tipsView show];
                }
                
            }
            else{
                
                if (!tipsView.isShowing) {
                    tipsView.labelView.text = @"日程未修改";
                    [tipsView show];
                }
            }
            
        }];
        //        resultBlock(YES,0);
        // 删除数据
        //        if ([event.startDate compare:[NSDate currentDate]] == NSOrderedAscending) {
        
    }
    else{
        resultBlock(NO,0);
        if (!tipsView.isShowing) {
            tipsView.labelView.text = @"日程未修改";
            [tipsView show];
        }
    }
}

- (void)removeDataWithEvent:(Events *)event result:(boolResult)resultBlock{
    if ([self.delegate respondsToSelector:@selector(removeDataWithEvent:result:)]) {
        [self.delegate removeDataWithEvent:event result:resultBlock];
        NSLog(@"%s",__func__);
    }
    else{
        resultBlock(NO,0);
    }
}

- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent currentPage:(BOOL)currentPage result:(boolResult)resultBlock{
    if ([self.delegate respondsToSelector:@selector(adjustDataWithEvent:targetEvent:currentPage:result:)]) {
        [self.delegate adjustDataWithEvent:event targetEvent:targetEvent currentPage:NO result:^(BOOL result, kInsertDataResult insertResult) {
            if (result) {
                BOOL flag = NO;
                resultBlock(result,insertResult);
                if ([event.startDate compare:[NSDate currentDate]] == NSOrderedAscending) {
                    OBOEventDateListModel *dataList = self.eventDataList[self.currentOperateCellSection];
                    [dataList.eventList removeObjectAtIndex:self.currentOperateCellRow];
                    if (dataList.eventList.count == 0) {
                        [self.eventDataList removeObject:dataList];
                    }
                    flag = YES;
                }
                // 插入数据
                if ([targetEvent.startDate compare:[NSDate currentDate]] == NSOrderedAscending) {
                    
                    [self insertIntoDataList:self.eventDataList event:targetEvent];
                    flag = YES;
                }
                if (flag) {
                    [self.scheTableView reloadData];
                }
                
                if (currentPage) {
                    RATTipsView *tipsView = [RATTipsView sharedManager];
                    if (!tipsView.isShowing) {
                        tipsView.labelView.text = @"日程已调整";
                        [tipsView show];
                    }
                }
                
                
                //                [self.scheTableView reloadData];
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

- (void)insertIntoDataList:(NSMutableArray *)dateList event:(Events *)event{
    if (event.state.intValue != kEventStatePending) {
        return;
    }
    NSInteger num = dateList.count;
    for (int j = 0;j < num;j++) {
        OBOEventDateListModel *data = dateList[j];
        if ([data.date isEqualToString:[NSDate stringFromDate:event.startDate]]) {
            NSInteger eventNum = data.eventList.count;
            for (int i = 0; i < eventNum; i++) {
                Events *t = data.eventList[i];
                if ([event.startTime compare:t.startTime] == NSOrderedDescending || [event.startTime compare:t.startTime] == NSOrderedSame) {
                    [data.eventList insertObject:event atIndex:i];
                    break;
                }
                if (i == data.eventList.count - 1) {
                    [data.eventList addObject:event];
                }
            }
            break;
        }
        else if ([data.date compare:[NSDate stringFromDate:event.startDate]] == NSOrderedAscending){
            OBOEventDateListModel *dataList = [[OBOEventDateListModel alloc]init];
            dataList.date = [NSDate stringFromDate:event.startDate];
            [dataList.eventList addObject:event];
            [self.eventDataList insertObject:dataList atIndex:j];
            break;
        }
        if (j == self.eventDataList.count - 1) {
            OBOEventDateListModel *dataList = [[OBOEventDateListModel alloc]init];
            dataList.date = [NSDate stringFromDate:event.startDate];
            [dataList.eventList addObject:event];
            [self.eventDataList addObject:dataList];
        }
    }
}

#pragma mark -- OBOTableHeaderView

- (void)headerView:(OBOTableHeaderView *)headerView section:(NSInteger)section{
    if (!self.scheTableView.editing) {
        OBOEventDateListModel *dataList = self.eventDataList[section];
        dataList.isShow = !dataList.isShow;
        [self.scheTableView reloadData];
    }
}
#pragma mark -- RATTabBarDelegate

- (void)tabBar:(RATTabBar *)tabBar didSelectedIndex:(int)index{
    switch (index) {
        case 0:
        {
            Events *event;
            NSArray *indexArr = [self.scheTableView indexPathsForSelectedRows];
            for (int i = 0; i < indexArr.count; i ++) {
                NSIndexPath *indexPath = indexArr[i];
                OBOEventDateListModel *dateList = self.eventDataList[indexPath.section];
                event = dateList.eventList[indexPath.row];
            }
            
            // 弹出修改页面
            OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:event];
            newScheController.delegete = self;
            newScheController.sheduleModel = event;
            newScheController.operationType = kAdjustSchedule;
            OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
            navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentViewController:navVc animated:YES completion:^{
                //[self loadData];
                [self selectCancel];
            }];
        }
            break;
        case 1:
        {
            [self batchesWithState:kEventStateCancelled];
        }
            break;
        case 2:
        {
            [self batchesWithState:kEventStateComplete];
        }
            break;
            
        default:
            break;
    }
}

- (void)batchesWithState:(kEventState)state{
    if (self.totalSelectedCell == 0) {
        return;
    }
    else{
        NSMutableArray *eventArray = [[NSMutableArray alloc]init];
        //        NSMutableArray *frameArray = [[NSMutableArray alloc]init];
        NSArray *indexArray = [self.scheTableView indexPathsForSelectedRows];
        
        for (int i = 0; i < indexArray.count; i ++) {
            NSIndexPath *indexPath = indexArray[i];
            OBOEventDateListModel *dateList = self.eventDataList[indexPath.section];
            Events *event = dateList.eventList[indexPath.row];
            [eventArray addObject:event];
        }
        [self.delegate updateDataWithArray:eventArray state:state result:^(BOOL result, kInsertDataResult insertResult) {
            if (result) {
                [self loadData];
            }
            [self selectCancel];
        }];
        //        }
    }
    
}

//- (void)updateChangeStateDate:()

//=======
//}
//
//
//-(void)initConstraints{
//
//    [self.oboSearchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.scheTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//    NSDictionary *containerViews = @{@"scheTableView":super.scheTableView};
//    NSString *vfl_11 = @"H:|-0-[scheTableView]-0-|";
//    NSString *vfl_12 = @"V:|-[scheTableView]-|";
//
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_11 options:0 metrics:nil views:   containerViews]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_12 options:0 metrics:nil views:   containerViews]];
//}
//
//
//
//#pragma  UITableViewDataSource and delegate
////--------------------tableView----------------
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [self.scheList count];
//}
//
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
//    return [NSString stringWithFormat:@"day %ld",section];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.textLabel.text = [self.scheList objectAtIndex:indexPath.row];
//    return cell;
//}
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
//}
//
//
//-(void)viewWillAppear:(BOOL)animated{
//    
//    self.title = @"过往行程";
//    
//}
//
///**
// 为了保证内部不泄露，在dealloc中释放占用的内存
// */
- (void)dealloc
{
    NSLog(@"OBOOverdueScheController--dealloc---");
}

//>>>>>>> origin/master

@end
