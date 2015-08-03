//
//  OBO_FatherVController.h
//  OneByOne
//
//  Created by 白雪飞 on 15-4-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBOFatherController : UIViewController

-(void)addNavRightBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action;
-(void)clearNavRightBtns;
-(void)addNavLeftBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action;
-(void)clearNavLeftBtns;

-(void)setNavRightBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action;
-(void)setNavLeftBtn:(NSString*)img HightLightImage:(NSString*)hImg action:(SEL)action;
//增加右侧 下拉式菜单
- (void)more;
@end
