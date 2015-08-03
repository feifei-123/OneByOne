//
//  Constants.h
//  OneByOne
//
//  Created by RAT on 15-4-29.
//  Copyright (c) 2015年 rat. All rights reserved.
//
#import "OBOStringTools.h"
#import "UIColor+Hex.h"

#ifndef OneByOne_Constants_h
#define OneByOne_Constants_h

// ----------------首页的常量---------------------
// tabbar的高度
#define kTabBarHeight   44
// 头像宽度
#define kHomeIconWidth  64
// 头像高度
#define kHomeIconHeight 64

// OBOCellContentView
/** 控件之间的间距 */
#define kPadding    20
/** 较大字体 */
#define kBigFont   [UIFont systemFontOfSize:16]
/** 较小字体 */
#define kSmallFont   [UIFont systemFontOfSize:14]
/** 较大字颜色 */
#define kBigColor   [UIColor blackColor]
/** 较小字颜色 */
#define kSmallColor   [UIColor grayColor]
/** 事件状态宽度 */
#define kEventStateWidth    100
/** 事件图标的宽度 */
#define kEventIconWidth     50
/** 事件图标的高度 */
#define kEventIconHeight    50

#define kFirstCellHeight    160
#define kCellHeight         60

// ----------------首页headview常量---------------------
#define kColor(r,g,b)       [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define kColorA(r,g,b,a)       [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:a]

#define kFont(font)         [UIFont systemFontOfSize:(font)]


// ---------------新建页面常量---------------------
#define kCustomGrayColor [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.8]
#define kCustomGrayLightColor [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.4]
#define kNewSchFont   [UIFont systemFontOfSize:16]

#define kInputWidgetHeight 30.0 //输入框 默认的高度. 35
#define kLeftViewWidth 25.0  //组件左侧试图的宽度. 35.0


#define kImageLeftPadding 2.0     //输入组件  左 侧图标的默认左边距
#define kImageTopPadding 2.0      //输入组件  左 侧图标的默认上边距.
#define kImageWidth 35.0         //输入组件  左 侧图标的默认宽度. 30
#define kImageHeight 35.0         //输入组件  左 侧图标的默认高度. 30

#define kDefaultRect  CGRectMake(0, 0, kImageWidth, kImageHeight)  //默认左侧图标的Rect
#define kMoreTag  10  //显示更多 图标tag
#define kPickTag  11  //收起更多 图标tag

#define kTextViewDefaultHeight 72.0 //文本域 的默认高度.
#define kLightTextColor [UIColor colorWithHexString:@"#867b6a" alpha:1.0] //0.4    //浅色默认的字体颜色
#define kWeightTextColor  [UIColor colorWithHexString:@"#867b6a" alpha:1.0]   //深色默认的字体颜色
#define kCancelTextColor  [UIColor colorWithHexString:@"#afafaf" alpha:1.0]   //取消按钮 的字体
#define kFinishTextColor  [UIColor colorWithHexString:@"#ffffff" alpha:1.0]   //取消按钮 的字体
#define kDefaultFontSize  [UIFont systemFontOfSize:12]   //默认的字体大小
#define kDefaultBigFontSize  [UIFont systemFontOfSize:14]   //默认的大号字体大小
#define kDefaultTextViewString @"输入日程详情..."
#define kTextView_NoInfo_Tag  100                           //文本域 没有录入信息时的tag。
#define kTextView_WithInfo_Tag  101                         //文本域 录入信息后的tag


#define kFooterHideLayout  @"V:[_oboFootTabBar(50)]-(-50)-|"  //隐藏底部“➕”添加日程栏约束
#define kFooterShowLayout  @"V:[_oboFootTabBar(50)]|"   //显示底部“➕”添加日程栏的约束

#define kPickerViewIconLeftMargin 130.0f   //pickerView icon的左边距
#define kPickerViewIconTopMargin  4.0f     //pickerView icon图标的上边距
#define kPickerViewIconWidth      15.0f    //pickerView icon图标的宽度
#define kPickerViewIconHeight     15.0f    //pickerView icon图标的高度
#define kPickerViewTitleLeftMargin 20.0f   //pickerView title的左边距
#define kPickerViewTitleWidth     100.0f   //pickerView title的高度

typedef  enum{
    kInsertNewSchedule=0,  //执行插入操作的新建页面
    kAdjustSchedule ,      //执行调整操作的新建页面
    kModifiedSchedule      //执行修改操作的新建页面
} kNewScheduleViewType;

// ---------------通用常量---------------------
// ----------------通用常量---------------------
// 屏幕宽度
#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
// 一次查询数据的限制条数
#define kQueryLimit     20

#define kHasUntreatedEvent  @"RAT_HASUNTREATEDEVENT_CONSTANT"

#define kNavBarPadding      12

// 菜单常量
#define kMenuTextColor  [UIColor colorWithRed:(95 / 255.0) green:(81 / 255.0) blue:(63 / 255.0) alpha:1.0]
// 下拉菜单常量
#define kDropDownMenuFontSize   20
// 弹出菜单常量
#define kPopUpMenuFontSize   11

// 颜色常量
#define kColor_5f513f kColor(95, 81, 63)
#define KColor_998e7f kColor(153, 142, 127)
#define KColor_867b6a kColor(134, 123, 106)
#define kColor_837963 kColor(131, 121, 99)


/** 标记 今天、明天、后天 **/
typedef enum {
    kOtherDays = -1,                   //不是 今天 明天  后天
    kToay = 0,                         // 今天
    kTomorrow,                         // 明天
    kTDayAfterTomorrow                 // 后天
}kDayType;


//---------------日历页面常量----------------------

typedef enum{
    Before = 0, //查询日期之前的日程
    After       //查询日期之后的日程
}Direction;

typedef enum {
    kFooterShow = 0,                    //底部的footerView 显示
    kFooterHide = 1,                    //底部的footerView 隐藏
}kFooterState;

typedef enum {
    kTabviewScrollUp = 1,              //向上滑动
    kTabviewScrollDown = -1,           //向下滑动
    kTabviewNotScroll = 0,             //未滑动
}kScrollDirection;

/**加载数据时,“加载数据类型”*/
typedef enum{
    kLoadDataSomeDate=0,                //加载某一天 的日程数据
    kLoadDataSearch,                    //加载搜索得出的数据
    kLoadDataAll,                       //加载所有数据
    kLoadDataInit,                       //加载页面的初始数据
    kLoadPullDownRefresh,               //下拉刷新时 加载数据
    kLoadPushUpRefresh,                 //上拉刷新时 加载数据
    kReloadCurrentPageData              //重新加载当前页面的常规数据，包括当前页面的原始数据＋当前页面已上拉刷新的数据＋当前页面已下拉刷新的数据.
    
}kLoadDataType;

#define kNavHeight 44  //导航栏的高度
#define kNavBtnWidth 110
#define kNavBtnHeight 35
#define kSearchBarHideConstraint @"V:|-(22)-[_oboSearchBar(42)]-(12)-[_oboCalenderView]"//14 22
#define kSearchBarShowConstraint @"V:|-64-[_oboSearchBar(42)]-(8)-[_oboCalenderView]" //64
#define kNavCalBtnTag 100               //导航栏目 日历tabButton 的tag
#define kNavaListBtnTag 101             //导航栏  列表tabButton  的tag.
//#define kNavCenterBgImageTag 102        //导航栏  中间背景图片 的tag.

#define kTableHeaderHeight 30           //表头的默认高度
#define kCurrentTableHeaderColor [UIColor colorWithHexString:@"#ffffff" alpha:1.0] //当天日程 的headerView字体颜色
#define kOthersTableHeaderColor [UIColor colorWithHexString:@"#8b5c1f" alpha:1.0]   //非当天日程 的headerView字体颜色
#define kTableHeaderFont        [UIFont systemFontOfSize:12]                       //HeaderView的字体大小
#define kDefaultSearchBarFont  [UIFont systemFontOfSize:11] //搜索栏 的默认字体大小

#define kSearchBarTag    20           //搜索栏视图的tag
#define kCandelBtnTag    21
/**显示的页面的类型**/

typedef enum{
    kCalenderNormal = 100, //日历_正常模式.
    kCalenderSearch,     //日历_搜索模式.
    kListNormal,         //列表_正常模式.
    kListSearch          //列表_搜索模式.
}kShowPageType;
//---------------列表页面常量----------------------
#define kPageSize 3    //每次下拉刷新 加载3天的日程数据
#define kOddHeaderColor [UIColor colorWithRed:0.5 green:0.6 blue:0.7 alpha:0.7] //奇数行 tableHeaderView的背景色
#define kEvenHeaderColor [UIColor colorWithRed:0.7 green:0.6 blue:0.5 alpha:0.7] //偶数行 tableHeaderView的背景色
#endif

