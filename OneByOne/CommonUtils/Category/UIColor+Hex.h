//
//  UIColor+Hex.h
//  OneByOne
//
//  Created by 白雪飞 on 15-6-18.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义带参数的额宏

#define RGBA_COLOR(R,G,B,A) [UIColor colorWithRed:((R)/255.0f) green:((G)/255.0f) blue:((B)/255.0f) alpha:(A)]
#define RGB_COLOR(R,G,B,A) [UIColor colorWithRed:((R)/255.0f) green:((G)/255.0f) blue:((B)/255.0f)]

@interface UIColor(Hex)

+ (UIColor *)colorWithHexString:(NSString *)color;
//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
