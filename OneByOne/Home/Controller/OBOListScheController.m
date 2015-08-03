//
//  OBO_ListScheVController.m
//  OneByOne
//
//  Created by RAT on 15-4-29.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import "OBOListScheController.h"
#import "OBODataBase.h"
#import "MBProgressHUD+MJ.h"
#import "MGSwipeTableCell.h"
#import "OBOCellContentView.h"
#import "OBOEventDateListModel.h"
//#import "OBOEventFrameModel.h"
#import "CalendarView.h"
#import "OBOStringTools.h"
#import "Utils.h"
#import "MJRefresh.h"
#import "Constants.h"
#import "UIBarButtonItem+Extension.h"
#import "OBOArrayTools.h"
#import "RATMenu.h"


typedef void(^ActionBlock)(BOOL success);


@interface OBOListScheController()<MGSwipeTableCellDelegate,RATMenuDelegate>{

}
//保存搜索 行程数据的数组.
@property (strong,nonatomic)  NSMutableArray * scheSearchDataArray;
//保存所有 行程的数组.
@property (strong,nonatomic)  NSMutableArray * scheAllDataArray;
//保存  下拉刷新 加载固定条数行程  的起始加载位置.
@property (assign,nonatomic)  NSNumber* overDueDataOffset;
//保存  下拉刷新可以获得的数据 的总和.
@property (assign,nonatomic)  NSNumber *overDueDataTotal;
//保存搜索的 关键字.
@property (strong,nonatomic)  NSString*keyWords;

//标志位, toShowSearchTableView==YES TableView显示模糊搜索出的数据，toShowSearchTableView==NO 显示全部日程 的行程.
@property (assign,nonatomic)  BOOL toShowSearchTableView;

@property (nonatomic, assign) NSInteger currentLongPresswdCellRow;
@property (nonatomic, assign) NSInteger currentLongPresswdCellSection;
@end



@implementation OBOListScheController

/*
 * scheSearchDataArray 的getter方法
 */
-(NSMutableArray*)scheSearchDataArray{
    if (_scheSearchDataArray==nil) {
        _scheSearchDataArray = [[NSMutableArray alloc]init];
    }
    return _scheSearchDataArray;
}

/*
 * scheAllDataArray 的getter方法
 */
-(NSMutableArray*)scheAllDataArray{
    if (_scheAllDataArray==nil) {
        _scheAllDataArray = [[NSMutableArray alloc]init];
    }
    return _scheAllDataArray;
}

/*
 * overDueDataOffset 的getter方法
 */
-(NSNumber*)overDueDataOffset{
    if (_overDueDataOffset==nil) {
        _overDueDataOffset = @(0);
    }
    return _overDueDataOffset;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //增加导航栏右侧切换按钮
    [self addNavRightBtn:@"navigationbar_more" HightLightImage:@"navigationbar_more_highlighted" action:@selector(switch2CaldnerView)];
     //加载数据
    [self loadData:kLoadDataAll withAction:^(BOOL success){
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [self.scheTableView reloadData];
            });
        }
        
    }];
    
    
    //页面布局
    [self addSearchBar];
    [self addTableView];
    [self initConstraints];
    [self addHeadRefreshController];
    [self addRefreshAnimationWithHeadAction:@selector(getMoreOldSchedule) footAction:nil];
    //[MBProgressHUD showMessage:@"正在加载数据"];
    // 异步加载数据库中的数据
}


/**上拉获得更多的过期日程*/
-(void)getMoreOldSchedule{

    [self loadData:kLoadPullDownRefresh withAction:^(BOOL success){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self.scheTableView reloadData];
            [self.scheTableView.header endRefreshing];
            
            //如果所有的数据 均已加载完毕，则去除下拉的下拉的功能。
            if(self.overDueDataOffset == self.overDueDataOffset){
                
                [self.scheTableView removeHeader];
                
            }
            
        });

    }];
    
}


/*
 *加载数据
 * 参数：loadType -kLoadDataAll 加载现在和将来的全部日程
 *               -kLoadPullDownRefresh 加载下拉刷新的数据
 */
-(void)loadData:(kLoadDataType)loadType withAction:(ActionBlock)actionBlock{
    
    
    if (loadType==kLoadDataAll) {
        
        //设置标志位，标志 加载 全部日程 的数据
        self.toShowSearchTableView = NO;
        
        //清空数据
        [self.scheAllDataArray  removeAllObjects];
        
        //加载初始数据
        [[OBODataBase sharedManager]queryAllEventsAfterDate:[NSDate date] ResultList:^(NSArray*result){
            
            NSMutableArray*arr = result.mutableCopy;
            
            //将arr 进行初步排序
            [OBOArrayTools sortArrayByDateTime:arr ascending:YES];
            
            while (arr.count > 0) {
                OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                
                [self.scheAllDataArray addObject:sameDateEvents];
            }
            
            
            //数据加载成功之后，进行后续操作.
            actionBlock(YES);

            
        }];
        
    }else if(loadType == kLoadPullDownRefresh){//下拉刷新，加载过往数据.
        
        //设置标志位，标志 加载 全部日程 的数据
        self.toShowSearchTableView = NO;
        
        //加载固定条数的过往的行程数据
        [[OBODataBase sharedManager]queryEventsBeforeDate:[NSDate date] offset:self.overDueDataOffset Limit:@(kPageSize) ResultList:^(NSArray*result,int total){
            
            
            //更新overDueDataOffset 过期行程的 offset.
            self.overDueDataOffset = @(self.overDueDataOffset.intValue+result.count);
            //记录 数据总数
            self.overDueDataTotal =@(total);
            
            
            //result 已经是有序的了，按照日期，时间降序.
            NSMutableArray *arr = result.mutableCopy;
            
            while (arr.count>0) {
                
                //取出一组数据
                OBOEventDateListModel * sameDateEvents = [[OBOEventDateListModel alloc]init];
                [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                
                
                OBOEventDateListModel*firstEventModel = [self.scheAllDataArray firstObject];
                
                NSLog(@"-------------:%@",sameDateEvents.date);
                
                if ([firstEventModel.date  isEqualToString:sameDateEvents.date]) {//若取出的数组和scheAllDataArray第一组数据的日期相同，则将新取出的数据合并到cheAllDataArray第一组数据
                    for (int i = 0; i<sameDateEvents.eventList.count; i++) {
                         [firstEventModel.eventList insertObject:[sameDateEvents.eventList objectAtIndex:i] atIndex:0];
                    }
                    
                }else{
                
                    [self.scheAllDataArray insertObject:sameDateEvents atIndex:0];
                
                }
                
            }
            
            //数据加载成功之后，进行后续操作.
            actionBlock(YES);

        }];
        
      
        
    }else if(loadType == kLoadDataSearch){
        
        
            //设置标志位，标志 加载 全部日程 的数据
            self.toShowSearchTableView = YES;
        
    
            //清空数据源头
            [self.scheSearchDataArray removeAllObjects];
            
            //重新加载搜索数据
            [[OBODataBase sharedManager] queryAllEventsWithSearchKeywords:self.keyWords ResultList:^(NSArray*result){
                
                NSMutableArray * arr = result.mutableCopy;
                //[self sortArrayByDateTime:arr];
                [OBOArrayTools sortArrayByDateTime:arr ascending:YES];
                
                while (arr.count > 0) {
                    OBOEventDateListModel *sameDateEvents = [[OBOEventDateListModel alloc]init];
                    [sameDateEvents eventListWithSortedArray:arr withFormat:YES];
                    
                    [self.scheSearchDataArray addObject:sameDateEvents];
                    
                }
                
                //数据加载成功之后，进行后续操作.
                actionBlock(YES);
            }];

    }
    
    
    if (self.toShowSearchTableView) {
        [self.scheTableView removeHeader];
    }
    
}



-(void)initConstraints{
    
    [self.oboSearchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scheTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *containerViews = @{@"oboSearchBar":super.oboSearchBar, @"scheTableView":super.scheTableView};
    NSString *vfl_11 = @"H:|-0-[oboSearchBar]-0-|";
    NSString *vfl_12 = @"H:|-0-[scheTableView]-0-|";
    NSString *vfl_13 = @"V:|-60-[oboSearchBar(50)]-[scheTableView(550)]";
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_11 options:0 metrics:nil views:   containerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_12 options:0 metrics:nil views:   containerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_13 options:0 metrics:nil views:   containerViews]];
}



#pragma  UITableViewDataSource and delegate
//--------------------tableView----------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = [self.scheAllDataArray count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    OBOEventDateListModel* dateList = nil;
    if (self.toShowSearchTableView) {
        dateList = [self.scheSearchDataArray objectAtIndex:section];
    }else{
        dateList = [self.scheAllDataArray objectAtIndex:section];
    }
   
    NSInteger rowCount = 0;
    if (dateList.isShow) {
        rowCount = [dateList.eventList count];
    }else{
        rowCount = 0;
    }
    
    return rowCount;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
   
    OBOEventDateListModel* dateList = nil;
    if (self.toShowSearchTableView) {
        dateList = [self.scheSearchDataArray objectAtIndex:section];
    }else{
        dateList = [self.scheAllDataArray objectAtIndex:section];
    }
    
    return dateList.date;
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
        [cell.contentView addSubview:contentView];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressedAct:)];
        gesture.minimumPressDuration = 1.0;
        [cell addGestureRecognizer:gesture];
        
        NSLog(@"未重用%ld",(long)indexPath.row);
    }
    
    OBOCellContentView *contentView = [cell.contentView.subviews lastObject];
    
    OBOEventDateListModel * eventDateList =nil;
    if (self.toShowSearchTableView) {
    
       eventDateList = [self.scheSearchDataArray objectAtIndex:indexPath.section];
        
    }else{
        
        eventDateList = [self.scheAllDataArray objectAtIndex:indexPath.section];
        
    }
    
    Events *event = [eventDateList.eventList objectAtIndex:indexPath.row];

    contentView.event = event;

    
    return cell;
}



// 定义头标题的视图，添加点击事件
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   // MyData *data = [dataArray objectAtIndex:section];
    OBOEventDateListModel* dateList = nil;
    if (self.toShowSearchTableView) {
        dateList = [self.scheSearchDataArray objectAtIndex:section];
    }else{
        dateList = [self.scheAllDataArray objectAtIndex:section];
    }
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 30);
    [btn setTitle:dateList.date forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.tag = section;
    [btn addTarget:self action:@selector(tableHeaderViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor lightGrayColor];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    
    //设置HeaderView的背景颜色。
    if (section%2) {
        btn.backgroundColor = kEvenHeaderColor;
    }else{
        btn.backgroundColor = kOddHeaderColor;
    }
    
    return btn;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OBOEventDateListModel * eventDateList =nil;
    if (self.toShowSearchTableView) {
        
        eventDateList = [self.scheSearchDataArray objectAtIndex:indexPath.section];
        
    }else{
        
        eventDateList = [self.scheAllDataArray objectAtIndex:indexPath.section];
        
    }
    
//    OBOEventFrameModel*eventFramemodel = [eventDateList.eventList objectAtIndex:indexPath.row];
    return kCellHeight;
    
}

-(void)tableHeaderViewClicked:(UIView*)sender{
    
    NSInteger index = sender.tag;
    
    OBOEventDateListModel* dateList = nil;
    if (self.toShowSearchTableView) {
        dateList = [self.scheSearchDataArray objectAtIndex:index];
    }else{
        dateList = [self.scheAllDataArray objectAtIndex:index];
    }
    
    dateList.isShow=!dateList.isShow;
    
    [self.scheTableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)switch2CaldnerView{
    

    [self.navigationController popViewControllerAnimated:NO];

}


//------------------搜索栏

#pragma searchBarDelegate
/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    // NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
    self.keyWords = searchBar.text;
    
    NSLog(@"keywords---------------:%@",self.keyWords);

    [self loadData:kLoadDataSearch withAction:^(BOOL success){
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [self.scheTableView reloadData];
            });
        }

    }];
    
    [self.oboSearchBar resignFirstResponder];
}
//cancel button clicked...
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
    NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
    
    [self.oboSearchBar resignFirstResponder];
    
}
//搜索结果按钮 被点击
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    
    NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
    
}


- (void)longPressedAct:(UILongPressGestureRecognizer *)gesture  {
    if(gesture.state == UIGestureRecognizerStateBegan)
        
    {
        
        CGPoint point = [gesture locationInView:self.scheTableView];
        
        NSIndexPath * indexPath = [self.scheTableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
        self.currentLongPresswdCellSection = indexPath.section;
        self.currentLongPresswdCellRow = indexPath.row;
        
        RATMenu *menu = [RATMenu menu];
        [menu addButtonWithText:@"删除" image:@"" highlightedImage:@""];
        [menu addButtonWithText:@"修改" image:@"" highlightedImage:@""];
        menu.buttonSize = CGSizeMake(kScreenWidth * 2 / 3, 40);
        menu.firstBtnOrigin = CGPointMake((kScreenWidth - menu.buttonSize.width) / 2, (kScreenHeight - menu.buttonSize.height * menu.buttonList.count) / 2);
        menu.delegate = self;
        menu.backgroundColor = [UIColor colorWithRed:55.0 / 255 green:55.0 / 255 blue:55.0 / 255 alpha:0.5];
        [menu show];
        
        //add your code here
        
    }
    
}

//RATMenu delegate!
#pragma mark -- RATMenuDelegate
    
- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button{
        
        
        OBOEventFrameModel*eventFramemodel = nil;
        
        switch (button.tag) {
            case 0://删除操作
            {
                NSLog(@"触发了删除操作");
                break;
                
            case 1: //修改操作.
                
                  NSLog(@"触发了修改操作");
                break;
                
            default:
                break;
        }
        }
}




#pragma MGSwipeTableCell Delegate

//使能 或禁止 左滑 右滑.
-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction{
    
    if (direction==MGSwipeDirectionRightToLeft) {
        return YES;
    }else{
        return NO;
    }
}


//设置 左滑 或 右滑 的按钮数组，以及按钮的转换样式，扩张选项
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings{
    
    if (direction==MGSwipeDirectionRightToLeft) {
        
        //变换方式
        swipeSettings.transition = MGSwipeTransition3D;
        
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
    
    if(direction ==MGSwipeDirectionRightToLeft){
        switch (index) {
            case 0:
                NSLog(@"您点击了完成按钮");
                break;
            case 1:
                NSLog(@"您点击了调整按钮");
                break;
            case 2:
                NSLog(@"您点击了取消按钮");
                break;
            default:
                break;
        }
    }
    return YES;
}


-(void)back2HomeView:(id)sender{

    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}




-(void)viewWillAppear:(BOOL)animated{
    
    self.title = @"全部行程";
    [self addNavLeftBtn:@"navigationbar_back" HightLightImage:@"navigationbar_back_highlighted" action:@selector(back2HomeView:)];
    
}

/**
 为了保证内部不泄露，在dealloc中释放占用的内存
 */
- (void)dealloc
{
    NSLog(@"OBOListScheController--dealloc---");
}

@end
