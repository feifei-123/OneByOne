//
//  AppDelegate.m
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "AppDelegate.h"
#import "OBOHomeController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    /**创建主页*************************/
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    OBOHomeController * homeController = [[OBOHomeController alloc]init];
   
    /**导航栏***************************/
//    self.nav = [[UINavigationController alloc]initWithRootViewController:homeController];
//    self.nav.navigationBarHidden = YES;
//    //定制导航栏的颜色:
//    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"nav_background"] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
    //加载导航栏
    self.window.rootViewController = homeController;

    /**window背景为白色*****************/
    //将window的背景色改成白色，这样可以避免 页面切换  导航栏突然隐藏时，导航栏后出现黑色长条
//    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
