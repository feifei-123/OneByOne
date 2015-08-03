//
//  UIImage+stretch.m
//  OneByOne
//
//  Created by macbook on 15-6-2.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "UIImage+stretch.h"

@implementation UIImage (stretch)

+ (UIImage *)imageWithStretch:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
}


@end
