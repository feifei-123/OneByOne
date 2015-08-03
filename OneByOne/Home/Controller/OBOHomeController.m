//
//  OBOHomeController.m
//  OneByOne
//
//  Created by macbook on 15-4-28.
//  Copyright (c) 2015年 rat. All rights reserved.
//

#import "OBOHomeController.h"
#import "OBOTouchTableView.h"
#import "RATTabBar.h"
#import "OBOHomeHeadView.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "OBOCellContentView.h"
#import "OBOHomeTableHeaderView.h"
#import "OBONavigationController.h"
#import "OBONewScheController.h"
#import "OBODetailScheController.h"
#import "OBOSettingController.h"
#import "OBOStringTools.h"
#import "Constants.h"
#import "RATMenu.h"
#import "RATTipsView.h"
#import "OBODetailTimeView.h"
#import "Events.h"
#import "mmDAO.h"
#import "NSManagedObject+helper.h"
#import "OBOOverdueScheController.h"
#import "OBOEventDateListModel.h"
#import "OBOCalendarScheduleController.h"
#import "OBOOverdueScheController.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "OBOArrayTools.h"
#import "NSDate+helper.h"
#import "UIImage+stretch.h"
#import "MBProgressHUD+MJ.h"

#import "OBODataBase.h"
#import <AFURLRequestSerialization.h>
#import <AFHTTPRequestOperationManager.h>
#import <UIImageView+WebCache.h>
//#import "CoreDataManager.h"
#define kEventRemindTime        5 * 60
#define kTableTopPadding        36
#define kWeatherQuerySpan       5 * 60
#define kWeatherQueryErrorSpan  60

@interface OBOHomeController() <RATTabBarDelegate, OBOHomeHeadViewDelegate,UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, RATMenuDelegate, OBOOperateDataDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate, OBOOverdueScheDelegate, OBOTouchTableViewDelegate>

@property (nonatomic, strong) RATTabBar *footTabBar;
@property (nonatomic, strong) OBOHomeHeadView *headView;
@property (nonatomic, strong) OBOHomeTableHeaderView *untreatedView;
@property (nonatomic, strong) OBOTouchTableView *currentTableView;
@property (nonatomic, strong) OBOTouchTableView *todayTableView;
@property (nonatomic, strong) OBOTouchTableView *tomorrowTableView;
@property (nonatomic, strong) OBOTouchTableView *postnatalTableView;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) AVAudioPlayer *remindPlayer;
@property (nonatomic, strong) UIAlertView *remindAlert;

@property (nonatomic, assign) NSInteger untreatedEventNum;

@property (nonatomic, strong) NSMutableArray *todayScheDataList;
@property (nonatomic, strong) NSMutableArray *todayEventDataList;
@property (nonatomic, strong) NSMutableArray *tomorrowScheDataList;
@property (nonatomic, strong) NSMutableArray *tomorrowEventDataList;
@property (nonatomic, strong) NSMutableArray *postnatalScheDataList;
@property (nonatomic, strong) NSMutableArray *postnatalEventDataList;

@property (nonatomic, strong) NSMutableArray *todayUntreatedDataList;

@property (nonatomic, assign) NSInteger currentLongPresswdCellSection;
@property (nonatomic, assign) NSInteger currentLongPresswdCellRow;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, assign) BOOL reminding;
@property (nonatomic, assign) NSInteger timeAfterRemind;

@property (nonatomic, assign) BOOL overdueControllerPresent;
@property (nonatomic, strong) Events *currentOverdueEvent;

@property (nonatomic, assign) int weatherCount;

@end

@implementation OBOHomeController

#pragma mark -- 懒加载

- (UIAlertView *)remindAlert{
    if (_remindAlert == nil) {
        _remindAlert = [[UIAlertView alloc] initWithTitle:@"日程提醒"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:nil];
    }
    return _remindAlert;
}

- (AVAudioPlayer *)remindPlayer{
    if (_remindPlayer == nil) {
        _remindPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"123" ofType:@"mp3"]] error:nil];
    }
    return _remindPlayer;
}

- (OBOTouchTableView *)todayTableView{
    if (_todayTableView == nil) {
        _todayTableView = [self createTableView];
        BOOL flag = NO;
        if (self.todayScheDataList.count > 0) {
            Events *event = self.todayScheDataList[0];
            if (event.classify.intValue != kEventClassifySche) {
                flag = YES;
            }
        }
        self.todayTableView.contentInset = UIEdgeInsetsMake((self.untreatedView.hidden || !flag) ? 0:kTableTopPadding, 0, 0, 0);
        
//        [self.view addSubview:_todayTableView];
    }
    return _todayTableView;
}

- (OBOTouchTableView *)tomorrowTableView{
    if (_tomorrowTableView == nil) {
        _tomorrowTableView = [self createTableView];
        _tomorrowTableView.contentInset = UIEdgeInsetsMake(self.untreatedView.hidden ? 0:kTableTopPadding, 0, 0, 0);
//        [self.view addSubview:_tomorrowTableView];
    }
    return _tomorrowTableView;
}

- (OBOTouchTableView *)postnatalTableView{
    if (_postnatalTableView == nil) {
        _postnatalTableView = [self createTableView];
//        [self.view addSubview:_postnatalTableView];
        _postnatalTableView.contentInset = UIEdgeInsetsMake(self.untreatedView.hidden ? 0:kTableTopPadding, 0, 0, 0);
    }
    return _postnatalTableView;
}

- (OBOHomeTableHeaderView *)untreatedView{
    if (_untreatedView == nil) {
        _untreatedView = [[OBOHomeTableHeaderView alloc]init];
        [_untreatedView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_untreatedView setBackgroundImage:[UIImage imageWithStretch:@"untreatedviewbg_normal"] forState:UIControlStateNormal];
        [_untreatedView setBackgroundImage:[UIImage imageWithStretch:@"untreatedviewbg_selected"] forState:UIControlStateHighlighted];
        _untreatedView.titleLabel.font = [UIFont systemFontOfSize:12];
        [_untreatedView setTitleColor:kColor(158, 148, 134) forState:UIControlStateNormal];
        [self.view addSubview:_untreatedView];
    }
    [self.view bringSubviewToFront:_untreatedView];
    return _untreatedView;
}

- (NSMutableArray *)todayUntreatedDataList{
    if (_todayUntreatedDataList == nil) {
        _todayUntreatedDataList = [[NSMutableArray alloc]init];
    }
    return _todayUntreatedDataList;
}

- (NSMutableArray *)todayScheDataList{
    if (_todayScheDataList == nil) {
        _todayScheDataList = [[NSMutableArray alloc]init];
    }
    return _todayScheDataList;
}

- (NSMutableArray *)todayEventDataList{
    if (_todayEventDataList == nil) {
        _todayEventDataList = [[NSMutableArray alloc]init];
    }
    return _todayEventDataList;
}

- (NSMutableArray *)tomorrowScheDataList{
    if (_tomorrowScheDataList == nil) {
        _tomorrowScheDataList = [[NSMutableArray alloc]init];
    }
    return _tomorrowScheDataList;
}

- (NSMutableArray *)tomorrowEventDataList{
    if (_tomorrowEventDataList == nil) {
        _tomorrowEventDataList = [[NSMutableArray alloc]init];
    }
    return _tomorrowEventDataList;
}

- (NSMutableArray *)postnatalScheDataList{
    if (_postnatalScheDataList == nil) {
        _postnatalScheDataList = [[NSMutableArray alloc]init];
    }
    return _postnatalScheDataList;
}

- (NSMutableArray *)postnatalEventDataList{
    if (_postnatalEventDataList == nil) {
        _postnatalEventDataList = [[NSMutableArray alloc]init];
    }
    return _postnatalEventDataList;
}

- (void)setUntreatedEventNum:(NSInteger)untreatedEventNum{
    
    if (untreatedEventNum < 0) {
        untreatedEventNum = 0;
    }
    if (untreatedEventNum == 0) {
        self.untreatedView.hidden = YES;
        
    }
    else{
        self.untreatedView.hidden = NO;
    }
    BOOL flag = NO;
    if (self.todayScheDataList.count > 0) {
        Events *event = self.todayScheDataList[0];
        if (event.classify.intValue != kEventClassifySche) {
            flag = YES;
        }
    }
    self.todayTableView.contentInset = UIEdgeInsetsMake((self.untreatedView.hidden || !flag) ? 0:kTableTopPadding, 0, 0, 0);
    self.tomorrowTableView.contentInset = UIEdgeInsetsMake(self.untreatedView.hidden ? 0:kTableTopPadding, 0, 0, 0);
    self.postnatalTableView.contentInset = UIEdgeInsetsMake(self.untreatedView.hidden ? 0:kTableTopPadding, 0, 0, 0);
#warning 需要知道能否插入当前时间之前的未处理事件
    if (!self.overdueControllerPresent) {
        if (_untreatedEventNum < untreatedEventNum) {
            if (self.currentOverdueEvent) {
                NSDate *lastDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastCheckDate"];
                NSDate *lastTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastCheckTime"];
                
                if (([self.currentOverdueEvent.startDate compare:lastDate] == NSOrderedAscending) || (([self.currentOverdueEvent.startDate compare:lastDate] == NSOrderedSame) && ([self.currentOverdueEvent.startTime compare:lastTime] == NSOrderedAscending))) {
                    [[NSUserDefaults standardUserDefaults] setValue:self.currentOverdueEvent.startDate forKey:@"lastCheckDate"];
                    [[NSUserDefaults standardUserDefaults] setValue:self.currentOverdueEvent.startTime forKey:@"lastCheckTime"];
                    [self.untreatedView setImage:[UIImage imageNamed:@"untreatedviewbtn_normal"] forState:UIControlStateNormal];
                }
                // 设置当前未处理事件图标
                self.currentOverdueEvent = nil;
            }
        }
    }
    
     _untreatedEventNum = untreatedEventNum;
    
    NSString *title = [NSString stringWithFormat:@"您有%ld条待处理行程",(long)_untreatedEventNum];
    
    [self.untreatedView setTitle:title forState:UIControlStateNormal];
   
}
//- (NSMutableArray *)eventFrameList{
//    if (_eventFrameList == nil) {
////        _eventFrameList = [[NSMutableArray alloc]init];
////        for (int i = 0; i < 20; i++) {
////            OBOEventModel *event = [[OBOEventModel alloc]init];
////            event.startTime = @"16:00";
////            event.endTime = @"17:00";
////            event.title = @"你好";
////            event.content = @"OS6,7测试没问题,5我没试,我不想再像安卓一样弄适配了,草.";
////            
////            if (i == 0) {
////                event.isFirstCell = YES;
////            }
////            
////            OBOEventFrameModel *eventFrame = [[OBOEventFrameModel alloc]init];
////            eventFrame.event = event;
////            [_eventFrameList addObject:eventFrame];
////        }
//        _eventFrameList = [OBODataBase queryAllEvents].mutableCopy;
//    }
//    return _eventFrameList;
//}

#pragma mark -- 数据加载
- (void)loadData{
    
//    for (int i = 0; i < 10; i++) {
//        [CoreDataManager insertCoreDataWithOperationResult:^(NSError *error) {
//            
//        }];
//    }
//    @property (nonatomic, strong) NSDate * startTime;
//    @property (nonatomic, copy) NSString * title;
//    @property (nonatomic, strong) NSNumber * type;
//    @property (nonatomic, copy) NSString * content;
//    @property (nonatomic, strong) NSDate * startDate;
//    @property (nonatomic, strong) NSDate * endDate;
//    @property (nonatomic, strong) NSDate * endTime;
//    @property (nonatomic, strong) NSNumber * remind;
//    @property (nonatomic, strong) NSNumber * repeat;
//    @property (nonatomic, strong) NSNumber * state;
//    // 调整到
//    @property (nonatomic, strong) NSNumber *adjustTo;
//    // 被调整
//    @property (nonatomic, strong) NSNumber *isAdjustdBy;
//    for (int i = 0; i < 6; i++) {
//        Events *event = [[Events alloc]init];
//        event.startTime = [NSDate currentTimeWithOffset:100];
//        event.startDate = [NSDate currentDate];
////        event.startDate = [NSDate dateWithOffset:1];
//        
//        event.title = [NSString stringWithFormat:@"测试数据%d,%@",i,[NSDate stringFromDate:event.startDate]];
//        event.type = @0;
//        event.content = @"看看能不能成功";
//        
//        event.endDate = [NSDate currentDate];
//        event.endTime = [NSDate currentTime];
//        event.remind = @0;
//        event.repeat = @0;
//        event.adjustTo = @0;
//        event.isAdjustdBy = @0;
//        event.classify = @0;
//        [[OBODataBase sharedManager] insertEventWithEvent:event result:^(BOOL result, kInsertDataResult insertResult) {
//            
//        }];
//    }
    self.currentDate = [OBOStringTools currentDate];
    [self.todayUntreatedDataList removeAllObjects];
    [self.todayScheDataList removeAllObjects];
    [self.todayEventDataList removeAllObjects];
    [self.tomorrowScheDataList removeAllObjects];
    [self.tomorrowEventDataList removeAllObjects];
    [self.postnatalScheDataList removeAllObjects];
    [self.postnatalEventDataList removeAllObjects];
    
    [[OBODataBase sharedManager] queryUntreatedEventNumBeforeTodayWithResultList:^(int num) {
        
        _untreatedEventNum = num;
        
    }];
    
    [[OBODataBase sharedManager]queryEventsWithDate:self.currentDate state:kEventStatePending byNow:NO resultList:^(NSArray *result) {
        // 加载今天数据
        NSLog(@"当前先成为%@",[NSThread currentThread]);
        for (int i = 0; i < result.count; i++) {
            Events *event = [result objectAtIndex:i];

            if (event.classify.intValue == kEventClassifyEvent) {
                [self.todayEventDataList addObject:event];
                
            }
            else{
                [self.todayScheDataList addObject:event];
            }
        }
        
        // 将事件插入到显示数组中
        if (self.todayEventDataList.count > 0) {
            if (self.todayScheDataList.count > 0) {
                for (int i = 0; i < self.todayEventDataList.count; i++) {
                    [self.todayScheDataList insertObject:self.todayEventDataList[i] atIndex:i + 1];
                }
                
            }
            else{
                [self.todayScheDataList addObjectsFromArray:self.todayEventDataList];
            }
        }
        if (![self removeOverdueEvents]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTodayUntreatedData" object:self.todayUntreatedDataList];
            self.untreatedEventNum = _untreatedEventNum;
            [self.todayTableView reloadData];
        }
        // 查看今天是否有未处理并且已过期数据

        if (self.todayUntreatedDataList.count == 0){
            // 查询之前的最晚的未处理事件是否已查看
            [[OBODataBase sharedManager] queryLastEventBeforeDate:self.currentDate result:^(Events *event) {
                if (event != nil) {
                    [self untreatedViewStateWithDate:event.startDate time:event.startTime];
                }
            }];
        }
        [self.todayTableView reloadData];
    }];
    
    [[OBODataBase sharedManager]queryEventsWithDate:[NSDate dateWithOffset:1] state:kEventStatePending byNow:NO resultList:^(NSArray *result) {
        // 加载今天数据
        NSLog(@"当前先成为%@",[NSThread currentThread]);
        for (int i = 0; i < result.count; i++) {
            //            Events *event = [result objectAtIndex:i];
            //            NSManagedObjectID *objectID = event.objectID;
            //                NSURL *url = objectID.URIRepresentation;
            //                NSLog(%)
            //                NSDate *date = event.startTime;
           
            [self.tomorrowScheDataList addObject:[result objectAtIndex:i]];
        }
//        if (![self removeOverdueEvents]) {
//            self.untreatedEventNum = _untreatedEventNum;
//            [self.todayTableView reloadData];
//        }
        [self.tomorrowTableView reloadData];
    }];
    
    [[OBODataBase sharedManager]queryEventsWithDate:[NSDate dateWithOffset:2] state:kEventStatePending byNow:NO resultList:^(NSArray *result) {
        // 加载今天数据
        NSLog(@"当前先成为%@",[NSThread currentThread]);
        for (int i = 0; i < result.count; i++) {
            //            Events *event = [result objectAtIndex:i];
            //            NSManagedObjectID *objectID = event.objectID;
            //                NSURL *url = objectID.URIRepresentation;
            //                NSLog(%)
            //                NSDate *date = event.startTime;
            [self.postnatalScheDataList addObject:[result objectAtIndex:i]];
        }
        //        if (![self removeOverdueEvents]) {
        //            self.untreatedEventNum = _untreatedEventNum;
        //            [self.todayTableView reloadData];
        //        }
        [self.postnatalTableView reloadData];
    }];
}

/**
 *  删除今天过期日程
 */
- (BOOL)removeOverdueEvents{
    BOOL flag = NO,first = NO;
    NSMutableArray *remindArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < self.todayScheDataList.count; i++) {
        Events *event = self.todayScheDataList[i];
        if (event.classify.intValue == kEventClassifyEvent) {
            continue;
        }
        else{
            if ([event.startTime compare:[OBOStringTools currentTime]] == NSOrderedAscending) {
                // 将今天未处理并且已过期的事件插入到todayUntreatedDataList数组中
                
                if (event.state.intValue == kEventStatePending){
                    [self.todayUntreatedDataList insertObject:event atIndex:0];
                }
                [self.todayScheDataList removeObject:event];
                i--;
                self.untreatedEventNum++;
                flag = YES;
            }
            else{
                if (!first && flag) {
//                    [self.todayScheDataList m]
                    [self.todayScheDataList insertObject:event atIndex:0];
                    [self.todayScheDataList removeObjectAtIndex:i + 1];
                    first = YES;
                }
            }
        }
//        else{
//            break;
//        }
    }
    
    for (Events *event in self.todayScheDataList) {
        // 暂时只提醒一次
        // 当前未正在提醒并且距上次提醒时间小于30秒
        if (event.classify.intValue == kEventClassifyEvent || event.remind.intValue == kWithOutRemind) {
            continue;
        }
        if (!self.reminding && self.timeAfterRemind >= 30 && !event.remindCount.intValue && ([[NSDate currentTime] compare:[event.startTime dateByAddingTimeInterval:(-kEventRemindTime)]] == NSOrderedDescending)) {
            event.remindCount = @(event.remindCount.intValue + 1);
            [remindArray addObject:event];
        }

    }
    // 重新设置firstcell
    
    if (flag) {
        // 查看是否需要更新未处理事件状态
        Events *event = [self.todayUntreatedDataList firstObject];
        [self untreatedViewStateWithDate:self.currentDate time:event.startTime];
        
        // 如果todayUntreatedDataList修改，就发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTodayUntreatedData" object:self.todayUntreatedDataList];
        [self.todayTableView reloadData];
    }
    if (remindArray.count > 0) {
        
        [[OBODataBase sharedManager] updateEventWithArray:remindArray state:kEventStateNone result:^(BOOL result, kInsertDataResult insertResult) {
            [self.remindPlayer prepareToPlay];
            NSMutableString *alertStr = [[NSMutableString alloc]init];
            for (int i = 0; i < remindArray.count; i++) {
                Events *event = remindArray[i];
                if (i > 0) {
                    [alertStr appendString:@"\n"];
                }
                [alertStr appendString:[NSString stringWithFormat:@"%@ %@",[NSDate stringFromTime:event.startTime],event.title]];
            }
            self.remindAlert.message = alertStr;
            self.reminding = YES;
            [self.remindPlayer play];
            [self.remindAlert show];
        }];
    }
    return flag;
}

- (void)untreatedViewStateWithDate:(NSDate *)date time:(NSDate *)time{
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCheckDate"];
    NSDate *lastTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastCheckTime"];
    if (lastDate == nil || lastTime == nil) {
        [self.untreatedView setImage:[UIImage imageNamed:@"untreatedviewbtn_normal"] forState:UIControlStateNormal];
    }
    else{
        if (([lastDate compare:date] == NSOrderedAscending) || (([lastDate compare:date] == NSOrderedSame) && ([lastTime compare:time] == NSOrderedAscending))) {
        [self.untreatedView setImage:[UIImage imageNamed:@"untreatedviewbtn_normal"] forState:UIControlStateNormal];
        }
        else{
            [self.untreatedView setImage:[UIImage imageNamed:@"untreatedviewbtn_none"] forState:UIControlStateNormal];
        }
    }
}

// 检查当前时间是否是第二天
- (void)checkWhetherTomorrow{
    if ([self.currentDate compare:[OBOStringTools currentDate]] != NSOrderedSame) {
        self.headView.date = [NSDate date];
        [self loadData];
    }
}

- (void)timerCheckOverdueMethod:(NSTimer*)theTimer{
//    NSLog(@"%s,%@",__func__,[NSThread currentThread]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"%s,%@",__func__,@"main_queue");
    // 查看当前是否正在提醒
    if (!self.reminding && self.timeAfterRemind < 30) {
        self.timeAfterRemind++;
    }
    if (self.weatherCount == kWeatherQuerySpan) {
        //        NSString *str=[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
        //        NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //        //    从URL获取json数据
        //        AFJSONRequestOperation *operation1 = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary* JSON) {
        //            NSLog(@"获取到的数据为：%@",JSON);
        //        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id data) {
        //            NSLog(@"发生错误！%@",error);
        //        }];
        //        [operation1 start];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //方法一：
        //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        //注意：默认的Response为json数据
        //    [manager setResponseSerializer:[AFXMLParserResponseSerializer new]];
        //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//使用这个将得到的是NSData
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//使用这个将得到的是JSON
        
        //注意：此行不加也可以
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain; charset=utf-8"];
        //    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        
        
        //SEND YOUR REQUEST
        [manager POST:@"http://www.weather.com.cn/data/cityinfo/101010100.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *dict =
            responseObject[@"weatherinfo"];
            NSString *temp1 = dict[@"temp1"];
            NSString *temp2 = dict[@"temp2"];
            self.headView.tempView.text = [NSString stringWithFormat:@"%@~%@",temp1,temp2];
            NSString *strUrl = [NSString stringWithFormat:@"http://www.weather.com.cn/img/%@",dict[@"img2"]];
            strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:strUrl];
            
            [self.headView.weatherView sd_setImageWithURL:url];
            self.weatherCount = 0;
            
            //...
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.weatherCount = kWeatherQuerySpan - kWeatherQueryErrorSpan;
            NSLog(@"Error: %@", error);
        }];
    }
    else{
        self.weatherCount++;
    }
    //    if (self.headView.date isEqualToDate:[NSDate da]) {
    //        <#statements#>
    //    }
    if (![self.headView.date isEqualToDate:[self currentDate]]) {
        self.headView.date = [NSDate currentDate];
    }
    // 检查当前时间是否是第二天
    [self checkWhetherTomorrow];
    // 定时更新首页的事件
    [self removeOverdueEvents];
    //    });

}

#pragma mark -- 界面显示
- (void)viewDidLoad{
    [super viewDidLoad];
    
    // 获取未处理事件的数量
//    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithOffset:-1] forKey:@"lastCheckDate"];
    
    self.weatherCount = kWeatherQuerySpan;
    
    UIImage *bgImage = [UIImage imageNamed:@"home_bgimage"];
    self.view.layer.contents = (id)bgImage.CGImage;
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.headView = [[[NSBundle mainBundle]loadNibNamed:@"OBOHomeHeadView" owner:self options:nil]lastObject];
    
    self.headView.date = [NSDate date];
    [self.headView weatherViewWithImage:[UIImage imageNamed:@"weather_shade"] temp1:-11 temp2:111];
    
    [self.headView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.headView.delegate = self;
    [self.headView iconWithName:@"tabbar_home_selected"];
    [self.view addSubview:self.headView];
    
    // 添加底部tabbar栏
    self.footTabBar = [[RATTabBar alloc]init];
    [self.footTabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.footTabBar.backgroundColor = [UIColor greenColor];
    
    
    [self.footTabBar addTabBarButtonWithBgName:@"tabbar_addbtnbg_normal" hlBgName:@"tabbar_addbtnbg_highlighted"];
    
    self.footTabBar.delegate = self;
//    self.view.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.footTabBar];
    
    [self todayTableView];
    
    [self tomorrowTableView];
    [self postnatalTableView];
    
    
    [self.untreatedView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.untreatedView.backgroundColor = [UIColor grayColor];
    [self.untreatedView addTarget:self action:@selector(untreatedEventsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:kHasUntreatedEvent];
    NSString *imageName;
    if (num.boolValue) {
        imageName = @"tabbar_discover";
    }
    [self.untreatedView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
//    
//    CoreDataManager *manger = [CoreDataManager sharedManager];
//    [manger insertCoreDataWithContext:manger.managedObjectContext];
//    [manger queryAllEventsByGroup];
    [self loadData];
    
    // 添加autolayout代码
    NSDictionary *dict1 = NSDictionaryOfVariableBindings(_headView, _footTabBar,_untreatedView);
    NSString *vfl1 = @"|-0-[_headView]-0-|";
    NSString *vfl2 = @"V:|-20-[_headView(140)]-4-[_untreatedView(32)]";
    
    NSString *vfl3 = @"V:[_footTabBar(49)]-0-|";
    NSString *vfl4 = @"|-0-[_footTabBar]-0-|";
    NSString *vfl5 = @"|-0-[_untreatedView]-0-|";
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:nil views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4 options:0 metrics:nil views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl5 options:0 metrics:nil views:dict1]];
    
    [self homeHeadView:self.headView dateButtonClick:nil];
    
    //开启定时器，定时检查日程是否过期
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCheckOverdueMethod:) userInfo:nil repeats:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
}

/**
 *  创建tableView
 *
 *  @return 创建成功的tableView
 */
- (OBOTouchTableView *)createTableView{
    OBOTouchTableView *tableView = [[OBOTouchTableView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.touchDelegate = self;
    tableView.backgroundColor = [UIColor clearColor];
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    tableView.rowHeight = 50;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    tableView.allowsSelection = NO;
    tableView.hidden = YES;
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //    self.tableView.sc
    
//    OBOHomeTableHeaderView * header = [[OBOHomeTableHeaderView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
//    [header addTarget:self action:@selector(untreatedEventsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    tableView.tableHeaderView = header;
//    //    [header headerText:@"您有2条待处理行程" image:@""];
//    NSString *title = [NSString stringWithFormat:@"您有%ld条待处理行程",(long)self.untreatedEventNum];
//    [header setTitle:title forState:UIControlStateNormal];
//    [header setImage:[UIImage imageNamed:@"tabbar_discover"] forState:UIControlStateNormal];
//    tableView.backgroundColor = [UIColor redColor];
//    tableView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tableView];
    
    // 添加autolayout代码
    
    NSDictionary *dict1 = NSDictionaryOfVariableBindings(_headView, tableView , _footTabBar);
    NSString *vfl1 = @"V:[_headView]-4-[tableView]-0-[_footTabBar]";
    
    NSString *vfl2 = @"|-0-[tableView]-0-|";
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dict1]];
    
    
    return tableView;
}

#pragma mark 监听事件回调函数
/**
 *  点击未处理事件回调函数
 *
 *  @param btn 被击按钮的指针
 */
- (void)untreatedEventsButtonClick:(UIButton *)btn{
    OBOOverdueScheController *listVc = [[OBOOverdueScheController alloc]init];
//    listVc.type = kListScheControllerTypeUntreated;
    listVc.delegate = self;
    listVc.dismissDelegate = self;
//    listVc.view.backgroundColor = [UIColor yellowColor];
    
    OBOEventDateListModel *list = [[OBOEventDateListModel alloc]init];
//    NSDateFormatter *df = [[NSDateFormatter alloc]init];
//    df.dateFormat = @"yyyy-MM-dd";
//    list.date = [df stringFromDate:self.currentDate];
    list.date = [NSDate stringFromDate:self.currentDate];
    list.eventList = [self.todayUntreatedDataList mutableCopy];
    
    // 添加kvo,观察todayUntreatedDataList变量是否改变
//    [list addObserver:self forKeyPath:@"todayUntreatedDataList" options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置当前未处理事件图标
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate formatDateWithString:list.date] forKey:@"lastCheckDate"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate currentTime] forKey:@"lastCheckTime"];
    [self.untreatedView setImage:[UIImage imageNamed:@"untreatedviewbtn_none"] forState:UIControlStateNormal];
    
    [listVc addData:list date:self.currentDate];
    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:listVc];
    self.overdueControllerPresent = YES;
    
    [self presentViewController:navVc animated:YES completion:^{
//        [MBProgressHUD showMessage:@"正在加载数据"];
    }];
//    [list removeObserver:self forKeyPath:@"todayUntreatedDataList" context:nil];
}

#pragma mark RATTabBar的delegate
/**
 *  点击tabbar按钮时调用此方法
 *
 *  @param tabBar tabbar对象
 *  @param index  点击的按钮编号
 */
- (void)tabBar:(RATTabBar *)tabBar didSelectedIndex:(int)index{
    
    //Events * scheModel = [[Events alloc]init];
    OBONewScheController *newScheController = [[OBONewScheController alloc]initWithModel:nil];
    newScheController.delegete = self;
    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
    navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:navVc animated:YES completion:^{
        //[self loadData];
    }];
}

#pragma mark OBOHomeHeadView的delegate

- (void)homeHeadView:(OBOHomeHeadView *)headView iconClick:(UIButton *)icon{
    OBOSettingController *settingVc = [[OBOSettingController alloc]init];
    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:settingVc];
    navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navVc animated:YES completion:^{
    }];
}

- (void)homeHeadView:(OBOHomeHeadView *)headView calendarClick:(UIView *)calendar{

    OBOCalendarScheduleController * calendarViewController= [[OBOCalendarScheduleController alloc]init];
    calendarViewController.operateDelegate = self;
    
    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:calendarViewController];
    
//    // 设置当前未处理事件图标
//    [[NSUserDefaults standardUserDefaults] setValue:self.currentDate forKey:@"lastCheckDate"];
//    [[NSUserDefaults standardUserDefaults] setValue:[NSDate currentTime] forKey:@"lastCheckTime"];
//    [self.untreatedView setImage:[UIImage imageNamed:@"avatar_vgirl"] forState:UIControlStateNormal];
    
    [self presentViewController:navVc animated:YES completion:^{
    }];
    
}

- (void)homeHeadView:(OBOHomeHeadView *)headView dateButtonClick:(UIButton *)button{
    
    if (button != self.selectedButton && button != nil) {
        self.currentTableView.hidden = YES;
        UITableView *tableView = [self tableViewByButton:button];
        self.currentTableView = tableView;
        tableView.hidden = NO;
    }
    else if (!button){
        self.todayTableView.hidden = NO;
        self.tomorrowTableView.hidden = YES;
        self.postnatalTableView.hidden = YES;
        self.currentTableView = self.todayTableView;
        [headView selectedBtnIndex:0];
    }
//    NSLog(@"%s,%ld",__func__,(long)button.tag);
}


- (UITableView *)tableViewByButton:(UIButton *)btn{
    switch (btn.tag) {
        case 0:
        {
            return self.todayTableView;
        }
            break;
        case 1:
        {
            return self.tomorrowTableView;
        }
            break;
        case 2:
        {
            return self.postnatalTableView;
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}

//- (void)untreatedEventsButtonClick:(UIButton *)btn{
//    
//    OBOOverdueScheController *overDueVc = [[OBOOverdueScheController alloc]init];
//
//    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:overDueVc];
//    
//    [self presentViewController:navVc animated:YES completion:^{
//    }];
//}

#pragma mark -- tableView的delegate和datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (tableView == _todayTableView) {
        if (!self.todayScheDataList.count) {
            self.todayTableView.backgroundView = [self viewForTableNoContentBgView];
        }
        else{
            self.todayTableView.backgroundView = nil;
        }
        return self.todayScheDataList.count;
    }
    else if (tableView == _tomorrowTableView){
        if (!self.tomorrowScheDataList.count) {
            self.tomorrowTableView.backgroundView = [self viewForTableNoContentBgView];
        }
        else{
            self.tomorrowTableView.backgroundView = nil;
        }
        return self.tomorrowScheDataList.count;
    }
    else if (tableView == _postnatalTableView){
        if (!self.postnatalScheDataList.count) {
            self.postnatalTableView.backgroundView = [self viewForTableNoContentBgView];
        }
        else{
            self.postnatalTableView.backgroundView = nil;
        }
        return self.postnatalScheDataList.count;
    }
    return 0;
    
}

- (UIView *)viewForTableNoContentBgView
{
    UIView *view = [[UIView alloc]init];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(0, (self.todayTableView.frame.size.height - 202) / 2 - 30, kScreenWidth, 202);
    imageView.image = [UIImage imageNamed:@"home_none_bgimage"];
    [view addSubview:imageView];
    return view;
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
        
        //        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressedAct:)];
        //        gesture.minimumPressDuration = 1.0;
        //        [cell addGestureRecognizer:gesture];
        
        NSLog(@"未重用%ld",(long)indexPath.row);
    }
    
    OBOCellContentView *contentView = [cell.contentView.subviews lastObject];
    if (tableView == self.todayTableView) {
        contentView.isFirstCell = NO;
        Events *event = self.todayScheDataList[indexPath.row];
        if (indexPath.row == 0) {
            if (event.classify.intValue != kEventClassifyEvent) {
                contentView.isFirstCell = YES;
            }
            
        }
        
        contentView.event = event;
        //        }
        //        else if (indexPath.row >= 1 && indexPath.row < self.todayEventDataList.count + 1) {
        //            contentView.eventFrame = self.todayEventDataList[indexPath.row - 1];
        //        }
        //        else{
        //            contentView.eventFrame = self.todayScheDataList[indexPath.row - self.todayEventDataList.count];
        //        }
        //        Events *event = contentView.eventFrame.event;
        //        NSDate *date = event.startDate;
    }
    else if (tableView == self.tomorrowTableView){
        contentView.event = self.tomorrowScheDataList[indexPath.row];
    }
    else if (tableView == self.postnatalTableView){
        contentView.event = self.postnatalScheDataList[indexPath.row];
    }
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%d",self.eventFrameList.count);
    if (indexPath.row == 0 && tableView == self.todayTableView) {
        Events *event = self.todayScheDataList[indexPath.row];
        if (event.classify.intValue == kEventClassifySche) {
            return 160;
        }
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 设置cell选中时的背景色
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    OBOCellContentView *content = nil;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            content = (OBOCellContentView *)view;
        }
    }
//    if (indexPath.row == 0) {
//        content.bgImageView.image = [UIImage imageWithStretch:@"cell_firstcellbg_selected"];
//    }
//    else{
//       content.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_selected"];
//    }
    
    OBODetailScheController *calendarVc = [[OBODetailScheController alloc]init];
    Events *event = nil;
    if (tableView == self.todayTableView) {
        event = self.todayScheDataList[indexPath.row];
    }
    else if (tableView == self.tomorrowTableView){
        event = self.tomorrowScheDataList[indexPath.row];
    }
    else if (tableView == self.postnatalTableView){
        event = self.postnatalScheDataList[indexPath.row];
    }
    calendarVc.delegate = self;
    [calendarVc contentWithEvent:event row:indexPath.row];
    OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:calendarVc];
    navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navVc animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            if (indexPath.row == 0) {
//                content.bgImageView.image = [UIImage imageWithStretch:@"cell_firstcellbg_normal"];
//            }
//            else{
//                content.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_normal"];
//            }
        }];
    });
    NSLog(@"当前选中行为：%ld",(long)indexPath.row);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    OBOCellContentView *content = nil;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[OBOCellContentView class]]) {
            content = (OBOCellContentView *)view;
        }
    }
//    if (indexPath.row == 0) {
//        content.bgImageView.image = [UIImage imageWithStretch:@"cell_firstcellbg_normal"];
//    }
//    else{
//        content.bgImageView.image = [UIImage imageWithStretch:@"cell_cellbg_normal"];
//    }
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
    if (self.todayScheDataList.count >= indexPath.row) {
        Events *event = self.todayScheDataList[indexPath.row];
        if (selected) {
            if (tableView == self.todayTableView && indexPath.row == 0 && event.classify.intValue == kEventClassifySche) {
                bgImage = [UIImage imageWithStretch:@"cell_firstcellbg_selected"];
            }
            else{
                bgImage = [UIImage imageWithStretch:@"cell_cellbg_selected"];
            }
        }
        else{
            if (tableView == self.todayTableView  && indexPath.row == 0 && event.classify.intValue == kEventClassifySche) {
                bgImage = [UIImage imageWithStretch:@"cell_firstcellbg_normal"];
            }
            else{
                bgImage = [UIImage imageWithStretch:@"cell_cellbg_normal"];
            }
        }
        
        
        contentView.bgImageView.image = bgImage;
    }
}
//- (void)longPressedAct:(UILongPressGestureRecognizer *)gesture  {
//    if(gesture.state == UIGestureRecognizerStateBegan)
//        
//    {
//        
//        CGPoint point = [gesture locationInView:self.currentTableView];
//        
//        NSIndexPath * indexPath = [self.currentTableView indexPathForRowAtPoint:point];
//        if(indexPath == nil) return ;
//        
//        self.currentLongPresswdCellSection = indexPath.section;
//        self.currentLongPresswdCellRow = indexPath.row;
//        
//        RATMenu *menu = [RATMenu menu];
//        [menu addButtonWithText:@"删除" image:@"" highlightedImage:@""];
//        [menu addButtonWithText:@"取消" image:@"" highlightedImage:@""];
//        [menu addButtonWithText:@"完成" image:@"" highlightedImage:@""];
//        menu.buttonSize = CGSizeMake(kScreenWidth * 2 / 3, 40);
//        menu.firstBtnOrigin = CGPointMake((kScreenWidth - menu.buttonSize.width) / 2, (kScreenHeight - menu.buttonSize.height * menu.buttonList.count) / 2);
//        menu.delegate = self;
//        menu.backgroundColor = [UIColor colorWithRed:55.0 / 255 green:55.0 / 255 blue:55.0 / 255 alpha:0.5];
//        [menu show];
//        
//        //add your code here
//        
//    }
//    
//}

#pragma mark RATMenu的delegate

- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button{
//    NSLog(@"%ld,%ld",(long)self.currentLongPresswdCell,(long)button.tag);
    switch (button.tag) {
        case 0:
        {
//            OBOEventDateListModel *data = self.todayDataList[self.currentLongPresswdCellSection];
//            OBOEventFrameModel *eventFrame = self.todayScheDataList[self.currentLongPresswdCellRow];
//            [self removeDataWithEvent:eventFrame.event result:^(BOOL result,kInsertDataResult insertResult) {}];
        }
            break;
        case 1:
        {
//            OBOEventDateListModel *data = self.todayDataList[self.currentLongPresswdCellSection];
//            OBOEventFrameModel *eventFrame = self.todayDataList[self.currentLongPresswdCellRow];
//            [self updateDataWithEvent:eventFrame.event targetEvent:eventFrame.event result:^(BOOL result) {
//                
//            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark MGSwipeTableCell的Delegate

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
//    MGSwipeTransitionBorder
//    MGSwipeTransitionStatic
//    MGSwipeTransitionClipCenter
//    MGSwipeTransitionDrag
//    MGSwipeTransition3D
    swipeSettings.transition = MGSwipeTransitionStatic;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.buttonIndex = -1;
        expansionSettings.fillOnTrigger = YES;
        //return [self createRightButtons:3];
        return  [OBOArrayTools createRightButtons];
    }
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    
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
        newScheController.operationType = kAdjustSchedule;
        newScheController.sheduleModel = event;
        OBONavigationController *navVc = [[OBONavigationController alloc]initWithRootViewController:newScheController];
        navVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:navVc animated:YES completion:^{
            //[self loadData];
        }];
        
        
//        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        //delete button
        // 取消按钮
//        OBOCellContentView *contentView = [cell.contentView.subviews firstObject];
        OBOCellContentView *contentView;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[OBOCellContentView class]]) {
                contentView = (OBOCellContentView *)view;
            }
        }
        Events *event = contentView.event;
        Events *target = [event mutableCopy];
//        Events *target = [[Events alloc]init];
//        [target evaluateWithEvent:event];
        target.state = @(kEventStateCancelled);
        [self updateDataWithEvent:event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
            RATTipsView *tipsView = [RATTipsView sharedManager];
            if (!tipsView.isShowing) {
                tipsView.labelView.text = @"日程已取消";
                [tipsView show];
            }
//            [self loadData];
        }];
        //        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        //delete button
        // 完成按钮
        OBOCellContentView *contentView = nil;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[OBOCellContentView class]]) {
                contentView = (OBOCellContentView *)view;
            }
        }
        Events *event = contentView.event;
        Events *target = [event mutableCopy];
//        Events *target = [[Events alloc]init];
//        [target evaluateWithEvent:event];
        target.state = @(kEventStateComplete);
        [self updateDataWithEvent:event targetEvent:target result:^(BOOL result,kInsertDataResult insertResult) {
            RATTipsView *tipsView = [RATTipsView sharedManager];
            if (!tipsView.isShowing) {
                tipsView.labelView.text = @"日程已完成";
                [tipsView show];
            }
//            [self loadData];
        }];
        //        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    return YES;
}

-(NSArray *) createRightButtons: (int) number
{
    return [OBOArrayTools createRightButtons];
}
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.remindPlayer stop];
        self.remindPlayer = nil;
        self.reminding = NO;
        self.timeAfterRemind = 0;
    }
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.reminding) {
        [self.remindAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

#pragma mark OBOOverdueScheDelegate
- (void)dismissControllerWithOverdueSche:(OBOOverdueScheController *)vc{
    self.overdueControllerPresent = NO;
}

#pragma mark OBOOperateDataDelegate

- (void)removeDataWithEvent:(Events *)event result:(boolResult)resultBlock{
    
    BOOL needLoadData = [event.startDate isEqualToDate:[OBOStringTools currentDate]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
    
    [[OBODataBase sharedManager] removeEventWithEvent:event result:^(BOOL result, kInsertDataResult insertResult) {
        resultBlock(result,0);
        if (result) {
            if (needLoadData) {
                //        [CoreDataManager ]
                [self loadData];
            }
        }
    }];

//    [CoreDataManager removeEventWithEvent:event result:^(BOOL result,kInsertDataResult insertResult) {
//        resultBlock(result,0);
//        if (result) {
//            if (needLoadData) {
//                //        [CoreDataManager ]
//                [self loadData];
//            }
//        }
//    }];
}

- (void)updateDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent result:(boolResult)resultBlock{
    
    // 重新加载数据标志
    BOOL needLoadData = [event.startDate isEqualToDate:[OBOStringTools currentDate]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
    needLoadData = needLoadData || [targetEvent.startDate isEqualToDate:[OBOStringTools currentDate]] || [targetEvent.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [targetEvent.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
    
    // 需要减未处理事件数量标志
    BOOL needSubUntreatedData = NO;
    if ((event.state.intValue == kEventStatePending) && (targetEvent.state.intValue != event.state.intValue) && ([event.startDate compare:self.currentDate] == NSOrderedAscending) && ([targetEvent.startDate compare:self.currentDate] == NSOrderedAscending)) {
        needSubUntreatedData = YES;
    }
    
//    // 调整时不需要
//    if (targetEvent.state.intValue == kEventStateAdjusted && event.state.intValue != kEventStateAdjusted) {
//        needLoadData = NO;
//    }
    // 是否设置事件的状态
    if (event.state.intValue == kEventStatePending && event.state.intValue != targetEvent.state.intValue) {
        targetEvent.updateStateTime = [NSDate date];
    }
    
    [[OBODataBase sharedManager] updateEventWithEvent:targetEvent result:^(BOOL result, kInsertDataResult insertResult) {
        
        if (needSubUntreatedData) {
            self.untreatedEventNum--;
        }
        resultBlock(result,0);
        if (result) {
            if (needLoadData) {
                //        [CoreDataManager ]
                [self loadData];
            }
        }
    }];
    
//    [CoreDataManager updateEventWithEvent:event result:^(BOOL result,kInsertDataResult insertResult) {
//        resultBlock(result,0);
//        if (result) {
//            if (needLoadData) {
//                //        [CoreDataManager ]
//                [self loadData];
//            }
//        }
//    }];
}

- (void)updateDataWithArray:(NSArray *)eventArray state:(kEventState)state result:(boolResult)resultBlock{
    BOOL needLoadData = NO;
    BOOL needSubUntreatedData = NO;
    NSInteger num = 0;
    
    NSDate *date = [NSDate date];
    for (Events *event in eventArray) {
        event.updateStateTime = date;
        needLoadData = needLoadData || [event.startDate isEqualToDate:[OBOStringTools currentDate]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
        if (event.state.intValue == kEventStatePending) {
            num++;
            needSubUntreatedData = YES;
        }
    }
    
    // 需要减未处理事件数量标志
    
    
    
    //    // 调整时不需要
    //    if (targetEvent.state.intValue == kEventStateAdjusted && event.state.intValue != kEventStateAdjusted) {
    //        needLoadData = NO;
    //    }
    
    [[OBODataBase sharedManager] updateEventWithArray:eventArray state:state result:^(BOOL result, kInsertDataResult insertResult) {
        
        if (needSubUntreatedData) {
            self.untreatedEventNum -= num;
        }
        resultBlock(result,0);
        if (result) {
            if (needLoadData) {
                //        [CoreDataManager ]
                [self loadData];
            }
        }
    }];
}

- (void)insertDataWithEvent:(Events *)event result:(boolResult)resultBlock{
    BOOL needLoadData = [event.startDate isEqualToDate:[OBOStringTools currentDate]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
    
    BOOL needAddData = ([event.startDate compare:self.currentDate] == NSOrderedAscending);
    
    [[OBODataBase sharedManager] insertEventWithEvent:event result:^(BOOL result, kInsertDataResult insertResult) {
        resultBlock(result,0);
        if (result) {
            if (needAddData) {
                self.currentOverdueEvent = event;
                self.untreatedEventNum++;
            }
            if (needLoadData) {
                //        [CoreDataManager ]
                [self loadData];
            }
            
        }
    }];
    
//    [CoreDataManager updateEventWithEvent:event result:^(BOOL result,kInsertDataResult insertResult) {
//        resultBlock(result,0);
//        if (result) {
//            if (needLoadData) {
//                //        [CoreDataManager ]
//                [self loadData];
//            }
//        }
//    }];
}

- (void)adjustDataWithEvent:(Events *)event targetEvent:(Events *)targetEvent currentPage:(BOOL)currentPage result:(boolResult)resultBlock{
    // 重新加载数据标志
    BOOL needLoadData = [event.startDate isEqualToDate:[OBOStringTools currentDate]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [event.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
    needLoadData = needLoadData || [targetEvent.startDate isEqualToDate:[OBOStringTools currentDate]] || [targetEvent.startDate isEqualToDate:[OBOStringTools dateWithOffset:1]] || [targetEvent.startDate isEqualToDate:[OBOStringTools dateWithOffset:2]];
    
    // 需要减未处理事件数量标志
    
    BOOL needSubUntreatedData = NO;
    BOOL needAddUntreatedData = NO;
    
    if (([event.startDate compare:self.currentDate] == NSOrderedAscending) && (event.state.intValue == kEventStatePending)) {
        needSubUntreatedData = YES;
    }
    if ( ([targetEvent.startDate compare:self.currentDate] == NSOrderedAscending) && (targetEvent.state.intValue == kEventStatePending)) {
        needAddUntreatedData = YES;
    }
    
    event.updateStateTime = [NSDate date];
    
    [[OBODataBase sharedManager] adjustEventWithEvent:event tartgetEvent:targetEvent result:^(BOOL result, kInsertDataResult insertResult) {
        if (needSubUntreatedData) {
            self.untreatedEventNum--;
        }
        if (needAddUntreatedData) {
            self.currentOverdueEvent = targetEvent;
            self.untreatedEventNum++;
        }
        resultBlock(result,0);
        if (result) {
            if (needLoadData) {
                //        [CoreDataManager ]
                [self loadData];
                if (currentPage) {
                    RATTipsView *tipsView = [RATTipsView sharedManager];
                    if (!tipsView.isShowing) {
                        tipsView.labelView.text = @"日程已调整";
                        [tipsView show];
                    }
                }
            }
        }
        else{
            if (currentPage) {
                RATTipsView *tipsView = [RATTipsView sharedManager];
                if (!tipsView.isShowing) {
                    tipsView.labelView.text = @"调整失败";
                    [tipsView show];
                }
            }
        }
    }];
}

//- (void)queryDataWithDate:(NSDate *)date result:(boolResult)resultBlock{
//}

-(void)addNewSchedule:(BOOL)sucess WithDay:(NSInteger)day AndScheModel:(Events*)model{

    NSLog(@"-------- add new schedule success!");

}

//- (void)dismissControllerWithOverdueSche:(OBOOverdueScheController *)vc{
//    [vc removeObserver:self forKeyPath:@"todayUntreatedDataList" context:nil];
//}

- (void)dealloc{
    [self.updateTimer invalidate];
}
@end
