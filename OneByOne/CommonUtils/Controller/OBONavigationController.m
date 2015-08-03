//
//  OBONavigationControllerViewController.m
//  OneByOne
//
//  Created by macbook on 15-5-3.
//  Copyright (c) 2015年 RAT. All rights reserved.
//

#import "OBONavigationController.h"
#import "UIBarButtonItem+Extension.h"
#import "RATMenu.h"
#import "Constants.h"
#import "UINavigationBar+height.h"
#import "UIImage+stretch.h"
#import "UINavigationItem+margin.h"

@interface OBONavigationController () <RATMenuDelegate>

@end

@implementation OBONavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationBar.clipsToBounds = YES;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    
    UIImage *image = [UIImage imageWithStretch:@"navbar_bgImage"];
    UIImage *shadow = [UIImage imageWithStretch:@"navbar_shadow"];
    NSDictionary *dict = @{
                           NSForegroundColorAttributeName:kColor(95, 81, 63),
                           NSFontAttributeName : kFont(21)
                           };
    self.navigationBar.titleTextAttributes = dict;
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:shadow];
    [super viewWillAppear:animated];
}


/*
 *定制 导航页的后退效果
 *(1)如果该页面 位于导航栈的顶层，则dismissViewController,模态页面 消失.
 *(2)如果该页面 未位于导航栈顶层，则popViewControllerAnimated,出栈.
 * 参数:controller 执行后退操作的Controller.
 */
+(void)backFromController:(UIViewController*)controller{
    
    NSUInteger count = [controller.navigationController.childViewControllers count];
    
    if (count>1) {
        [controller.navigationController popViewControllerAnimated:YES];
    }else{
        [controller dismissViewControllerAnimated:YES completion:^(){}];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.childViewControllers.count >= 1) {
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"navbar_back_normal" highImage:@"navbar_back_hightlighted"];
    }
    else{
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"navbar_back_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"navbar_back_hightlighted"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(0, 0,44, 44)];
        
        UIBarButtonItem *backNavigationItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        viewController.navigationItem.leftBarButtonItem
        negativeSpacer.width = -17;
        viewController.navigationItem.leftBarButtonItem = backNavigationItem;//@[negativeSpacer, backNavigationItem];
        viewController.navigationItem.leftBarButtonItems = @[negativeSpacer, backNavigationItem];
        
    }
    
    // modified by feifei ,2015_05_12  此处先注释掉，并不是所有的都需要加右侧，更多。
    // 我将增加导航栏右侧按钮的 功能加到了OBOFatherController中。只需调用
    //[self addNavRightBtn:@"navigationbar_more" HightLightImage:@"navigationbar_more_highlighted" action:@selector(more)];
    /*
    // 设置右边的更多按钮
    viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(more) image:@"navigationbar_more" highImage:@"navigationbar_more_highlighted"];
     */
    [super pushViewController:viewController animated:animated];
}

/**
 *  navigation的返回方法
 */
- (void)back
{
    [self popViewControllerAnimated:YES];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 *  navigation的更多操作方法
 */
- (void)more
{
//    [self popToRootViewControllerAnimated:YES];
    RATMenu *menu = [RATMenu menu];
    [menu addButtonWithText:@"删除" image:@"" highlightedImage:@""];
    [menu addButtonWithText:@"修改" image:@"" highlightedImage:@""];
    [menu addButtonWithText:@"增加" image:@"" highlightedImage:@""];
    menu.delegate = self;
    [menu show];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}
@end
