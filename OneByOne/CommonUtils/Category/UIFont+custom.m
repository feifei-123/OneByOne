//
//  UIFont+custom.m
//  OneByOne
//
//  Created by macbook on 15-6-29.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "UIFont+custom.h"
#import <CoreText/CTFontManager.h>

@implementation UIFont (custom)

+ (UIFont*)customFontWithPath:(NSString*)path size:(CGFloat)size
{
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}

@end
