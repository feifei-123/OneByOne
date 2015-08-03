//
//  OBOTableController.h
//  OneByOne
//
//  Created by 白雪飞 on 15-5-14.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBOFatherController.h"
#import "OBOSearchBar.h"
#import "OBOTouchTableView.h"
#import "OBOCustumItem.h"



@interface OBOTableController : OBOFatherController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *scheList;//存放行程到数组
//@property (nonatomic,strong) OBOSearchBar * oboSearchBar;
@property (nonatomic,strong) UIImageView * oboSearchBar;
@property (nonatomic,strong) OBOTouchTableView * scheTableView;
-(void)addSearchBar;
-(void)addTableView;
-(void)addHeadRefreshController;
-(void)addFooterRefreshController;
- (void)addRefreshAnimationWithHeadAction:(SEL)headAction footAction:(SEL)footAction;
//-(void)sortArrayByDateTime:(NSMutableArray*)arr;
//-(void)sortArrayByDateTime:(NSMutableArray*)arr ascending:(BOOL)ascend;
@end
