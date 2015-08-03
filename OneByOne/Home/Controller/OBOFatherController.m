//
//  OBO_FatherVController.m
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOFatherController.h"
#import "RATMenu.h"
#import "OBONoHLButton.h"
#import "UIBarButtonItem+Extension.h"
#import "Constants.h"
@interface OBOFatherController ()<RATMenuDelegate>
{
    //导航栏右侧按钮的集合
    NSMutableArray* navRightBtnArray;
    //导航栏左侧按钮的集合
    NSMutableArray* navLeftBtnArray;
}
@end
@implementation OBOFatherController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
     //设置统一的背景 或 背景颜色
     [self.view setBackgroundColor:[UIColor whiteColor]];
      
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor yellowColor];
    
    navRightBtnArray = [[NSMutableArray alloc]init];
    navLeftBtnArray = [[NSMutableArray alloc]init];
    
    
    // Do any additional setup after loading the view.
}




/**
 *为导航栏添加右侧按钮,可添加多个右侧按钮
 * 参数:img－按钮图片；action－按钮点击动作
 * 返回值：无
 * added by baixuefei  2015_04_30
 */
-(void)addNavRightBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action
{
    UIBarButtonItem *rightItem =[UIBarButtonItem itemWithTarget:self action:action image: img highImage:hImg];
    [navRightBtnArray addObject:rightItem];
    self.navigationItem.rightBarButtonItem = rightItem;
}


-(void)setNavRightBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action
{
    UIBarButtonItem *rightItem =[UIBarButtonItem itemWithTarget:self action:action image: img highImage:hImg];
    //[navRightBtnArray addObject:rightItem];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if(([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)){
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -20;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
    }else{
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}
/**
 * 删除导航栏添加右侧的所有按钮
 * 参数:img－按钮图片；action－按钮点击动作
 * 返回值：无
 * added by baixuefei  2015_04_30
 */
-(void)clearNavRightBtns{
    [navRightBtnArray removeAllObjects];
     self.navigationItem.rightBarButtonItems = navRightBtnArray;
}


/**
 *为导航栏添加左侧按钮,可添加多个右侧按钮
 * 参数:img－按钮图片；action－按钮点击动作
 * 返回值：无
 * added by baixuefei  2015_04_30
 */
-(void)addNavLeftBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action
{
    UIBarButtonItem *leftItem =[UIBarButtonItem itemWithTarget:self action:action image: img highImage:hImg];
    [navLeftBtnArray addObject:leftItem];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)setNavLeftBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action
{
    UIBarButtonItem *leftItem =[UIBarButtonItem itemWithTarget:self action:action image: img highImage:hImg];
   

    if(([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)){
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -20;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftItem];
    }else{
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
}

/**
 * 删除导航栏添加左侧侧的所有按钮
 * 参数:无
 * 返回值：无
 * added by baixuefei  2015_04_30
 */
-(void)clearNavLeftBtns{
    [navLeftBtnArray removeAllObjects];
    self.navigationItem.leftBarButtonItems = navLeftBtnArray;
}

/**
 *  navigation的更多操作方法
 */
- (void)more
{
    
    RATMenu *menu = [RATMenu menu];
    menu.animateType = kMenuAnimateTypeNone;
    UIImage *bgImage = [UIImage imageNamed:@"menu_dropdown_bgimage"];
    menu.bgImageView.image = bgImage;
    menu.bgImageView.frame = CGRectMake(kScreenWidth - bgImage.size.width, 64, bgImage.size.width, bgImage.size.height);
    menu.buttonSize = CGSizeMake(100, 50);
    
    OBONoHLButton *btn1 = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
    OBONoHLButton *btn2 = [OBONoHLButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"分享" forState:UIControlStateNormal];
    [btn2 setTitle:@"收藏" forState:UIControlStateNormal];
    
    [btn1 setTitleColor:kMenuTextColor forState:UIControlStateNormal];
    btn1.titleLabel.font = kFont(kDropDownMenuFontSize);
    
    [btn2 setTitleColor:kMenuTextColor forState:UIControlStateNormal];
    btn2.titleLabel.font = kFont(kDropDownMenuFontSize);
    
    [menu addButtonWithBtn:btn1 point:CGPointZero];
    [menu addButtonWithBtn:btn2 point:CGPointZero];

    menu.delegate = self;
    [menu show];
}

- (void)menu:(RATMenu *)menu clickedButton:(UIButton *)button{
    NSLog(@"%ld",(long)button.tag);
}

/*
  viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(more) image:@"navigationbar_more" highImage:@"navigationbar_more_highlighted"];
 */

- (void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated{

}

- (void)viewDidAppear:(BOOL)animated{
    
}


-(void)viewDidDisappear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
