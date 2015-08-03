//
//  OBOSettingController.m
//  OneByOne
//
//  Created by macbook on 15-7-1.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOSettingController.h"
#import "UIImage+stretch.h"

@interface OBOSettingController()

@end

@implementation OBOSettingController

- (void)viewDidLoad{
    [super viewDidLoad];
    UIImage *bgImage = [UIImage imageNamed:@"setting_bgimage"];
    self.view.layer.contents = (id)bgImage.CGImage;
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
}

@end
