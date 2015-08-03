//
//  OBOTableController.m
//  OneByOne
//
//  Created by 白雪飞 on 15-5-14.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOTableController.h"
#import "OBOSearchBar.h"
#import "MJRefresh.h"
#import "Constants.h"
#import "Utils.h"


@interface OBOTableController ()


@end

@implementation OBOTableController

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self addTableView];
    
    
    // Do any additional setup after loading the view.
}

//- (void)viewWillAppear:(BOOL)animated{
//    [self addTableView];
//}


/*
- (NSMutableArray *)scheList{
    if (_scheList == nil) {
        _scheList = [[NSMutableArray alloc]init];
        // 加载数据
        
        for (int i = 0; i<10; i++) {
            [_scheList addObject:[NSString stringWithFormat:@"行程%d",i]];
        }
        
        
    }
    return _scheList;
}
*/

-(void)addSearchBar{

    self.oboSearchBar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"searchBar_wholeBg"]];
    //self.oboSearchBar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self.view addSubview:self.oboSearchBar];
    self.oboSearchBar.userInteractionEnabled = YES;
    
    OBOCustumItem * searchBarItem =  [[OBOCustumItem alloc]init];
    searchBarItem.leftViewWidth = @(220);
    //searchBarItem.leftViewWidth = @(175+10);
    [self.oboSearchBar addSubview:searchBarItem];
    
    
    
    
    UIImageView*bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"searchBar_Bg"]];
    [searchBarItem addWholeItem:bgImage atIndex:0];
    
    //searchBar
    OBOSearchBar *mySearchBar = [[OBOSearchBar alloc]init];
    mySearchBar.tag = kSearchBarTag;
    mySearchBar.placeholder = @"输入搜索内容...";
    mySearchBar.keyboardType =UIKeyboardTypeDefault;
    mySearchBar.delegate = self;
    //mySearchBar.backgroundColor = [UIColor redColor];
    [searchBarItem addLeftItem:mySearchBar withCGRect:CGRectMake(0, 0, 220,27)];
    
    
    UIButton*searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor: kWeightTextColor forState:UIControlStateNormal];

    [searchBtn setBackgroundImage:[UIImage imageNamed:@"searchBar_searchBtn"] forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"searchBar_searchBtn"] forState:UIControlStateHighlighted];
    searchBtn.titleLabel.font = kDefaultSearchBarFont;
    [searchBtn addTarget:self action:@selector(begin2Search:) forControlEvents:UIControlEventTouchUpInside];
    //[searchBarItem addRightItem:searchBtn withRect:CGRectMake(0, 0, 58,27)];
    [searchBarItem addRightItem:searchBtn withRect:CGRectMake(0, 0, 75,27)];
    
//    if([[Utils getDeviceType] isEqualToString:@"iPhone Simulator"]){
//        searchBarItem.leftViewWidth = @(220);
//        [searchBarItem addRightItem:searchBtn withRect:CGRectMake(0, 0, 75,27)];
//        
//    }else{
//        searchBarItem.leftViewWidth = @(175+10);
//        [searchBarItem addRightItem:searchBtn withRect:CGRectMake(0, 0, 58,27)];
//    }
    
    
    
    
    [searchBarItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary* dicts = NSDictionaryOfVariableBindings(_oboSearchBar,searchBarItem);
    NSString*vfl = @"H:|-(40)-[searchBarItem]-(40)-|";
    [self.oboSearchBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dicts]];
    vfl = @"V:|-(8)-[searchBarItem(27)]";//23-6
     [self.oboSearchBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dicts]];
    
    
}

-(void)addTableView{

    //tableView
    self.scheTableView = [[OBOTouchTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.scheTableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    self.scheTableView.delegate = self;
    self.scheTableView.dataSource = self;
    self.scheTableView.backgroundColor = [UIColor clearColor];
//    self.view.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.scheTableView];
    //self.scheTableView.backgroundColor = [UIColor greenColor];
   
}

-(void)begin2Search:(id)sender{

    NSLog(@"begin to search!");
    
}



#pragma  UITableViewDataSource and delegate
//--------------------tableView----------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_scheList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_scheList objectAtIndex:indexPath.row];
    return cell;
}
    

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}


#pragma mark - 添加下拉刷新

- (void)addRefreshAnimationWithHeadAction:(SEL)headAction footAction:(SEL)footAction{
    
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
        [idleImages addObject:image];
    }
    
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    
    if (headAction != nil) {
        [self.scheTableView addGifHeaderWithRefreshingTarget:self refreshingAction:headAction];
        
        // 设置普通状态的动画图片
        
        [self.scheTableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
        
        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        
        [self.scheTableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
        
        // 设置正在刷新状态的动画图片
        [self.scheTableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
        // 在这个例子中，即将刷新 和 正在刷新 用的是一样的动画图片
        
        // 马上进入刷新状态
        //    [self.scheTableView.gifHeader beginRefreshing];
    }
    
    if (footAction) {
        [self.scheTableView addGifFooterWithRefreshingTarget:self refreshingAction:footAction];
        
        // 设置动画图片
        
        self.scheTableView.gifFooter.refreshingImages = refreshingImages;

        
        // 马上进入刷新状态
        //    [self.scheTableView.gifHeader beginRefreshing];
    }
    

}
-(void)addHeadRefreshController{
    
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    [self.scheTableView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
        [idleImages addObject:image];
    }
    [self.scheTableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    [self.scheTableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self.scheTableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
    // 在这个例子中，即将刷新 和 正在刷新 用的是一样的动画图片
    
    // 马上进入刷新状态
    [self.scheTableView.gifHeader beginRefreshing];
    
    
}


#pragma mark 下拉刷新数据
- (void)loadNewData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        NSString * newSch = [NSString stringWithFormat:@"过去的行程%d",i];
        [self.scheList insertObject:newSch atIndex:0];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.scheTableView reloadData];
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.scheTableView.header endRefreshing];
    });
}





#pragma mark - 添加上拉刷新
-(void)addFooterRefreshController{
    
    
    [self.scheTableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    self.scheTableView.gifFooter.refreshingImages = refreshingImages;
    
    
}


#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        NSString * futureSch = [NSString stringWithFormat:@"未来行程%d",i];
        [self.scheList addObject:futureSch];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.scheTableView reloadData];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.scheTableView.footer endRefreshing];
    });
}




#pragma searchBarDelegate
/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
    
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


/*
 *对数组按照日期和时间 进行对结果集进行排序。
 
-(void)sortArrayByDateTime:(NSMutableArray*)arr{
    
    NSDictionary* dic1 = @{@"property":@"startDate",@"order":@"asc"};
    NSDictionary* dic2 = @{@"property":@"startTime",@"order":@"asc"};
    NSDictionary* dic3 = @{@"property":@"timeStamp",@"order":@"asc"};
    
    NSArray * keyWordsArray = [NSArray arrayWithObjects:dic1,dic2,dic3,nil];
    [self sortArray:arr withKeywordsArray:keyWordsArray];
   
}
*/


 /*
  *对数组按照日期和时间 进行对结果集进行排序。
  * 参数 :ascend -YES  升序   NO－降序
 
-(void)sortArrayByDateTime:(NSMutableArray*)arr ascending:(BOOL)ascend{
    
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:ascend];
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:ascend];
    [arr sortUsingDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
  
    
}
 */

/*对数组 按照 特定的描述符，进行生序或降序排序。
 *参数: array－被排序的数组.
 *     sortKeyWords:描述排序条件的数组。数组中每个元素 为一个字典。
 *     字典中保存“property”和“order” 两个键，
 *     property对应排序依赖的“属性”。
 *     order==asc 表示升序；order==desc表示降序。

-(void)sortArray:(NSMutableArray*)array withKeywordsArray:(NSArray*)sortKeyWords{

    NSMutableArray* descriptorsArr = [[NSMutableArray alloc]init];
    
    for ( NSDictionary*dic in  sortKeyWords) {
        
        NSString *key = dic[@"property"];
        NSString *order = dic[@"order"];
        BOOL order_b = [order isEqual:@"asc"]?YES:NO;
        
        NSSortDescriptor * sorter = [[NSSortDescriptor alloc]initWithKey:key ascending:order_b];
        [descriptorsArr addObject:sorter];
    }
    
    [array sortUsingDescriptors:descriptorsArr];
    
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
