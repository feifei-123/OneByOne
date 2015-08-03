//
//  OBOSearchBar.m
//  TestJTCalender
//
//  Created by 白雪飞 on 15-5-11.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOSearchBar.h"
#import "Constants.h"
#import "OBOCustumItem.h"

@implementation OBOSearchBar

-(instancetype)init{
    self = [super init];
    
    if (self) {
        
        //        self.searchBarStyle = UISearchBarStyleProminent;
        //        self.searchBarStyle = UISearchBarStyleMinimal;
        //        self.searchBarStyle = UISearchBarStyleDefault;
        
        //        self.barStyle = UIBarStyleBlack;
        //        self.barStyle = UIBarStyleBlackOpaque;
        //        self.barStyle = UIBarStyleBlackTranslucent;
        
        
        //self.showsCancelButton = YES;
        //self.backgroundColor=[UIColor clearColor];
        //设置背景框图片
        //[self setBackgroundImage:[UIImage imageNamed:@"searchBar_InputBg"]];
        //[self setBarStyle:UIBarStyleBlack];
        //[self setBarStyle:UIBarStyleBlackOpaque];
        //[self setBarStyle:UIBarStyleDefault];
        //设置TextField框图片
        //[self setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBar_InputBg"] forState:UIControlStateNormal];
        //设置搜索图标位置偏移
        [self setPositionAdjustment: UIOffsetMake(-25, 0) forSearchBarIcon:UISearchBarIconSearch];
        //自定义搜索图标
        [self setImage:[UIImage imageNamed:@"day_selected"] forSearchBarIcon:(UISearchBarIconSearch) state:UIControlStateNormal];
        
        //[self setUISearchBarTextFieldBgColor:[UIColor clearColor] textColor:kWeightTextColor textFont:[UIFont systemFontOfSize:11] placeHolderTextColor:kLightTextColor placeHolderFont:kDefaultSearchBarFont];
        [self setUISearchBarTextFieldBgColor:[UIColor clearColor] textColor:kWeightTextColor textFont:[UIFont systemFontOfSize:11] placeHolderTextColor:[UIColor redColor] placeHolderFont:kDefaultSearchBarFont];
        
        
        for (UIView *view in self.subviews) {
            // for before iOS7.0
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [view removeFromSuperview];
                break;
            }
            // for later iOS7.0(include)
            if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
                [[view.subviews objectAtIndex:0] removeFromSuperview];
                break;
            }
        }
    }
    return self;
}





/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setUISearchBarTextFieldBgColor:(UIColor *)backgroundColor textColor:(UIColor*)textColor textFont:(UIFont*)font
{
    [self setUISearchBarTextFieldBgColor:backgroundColor textColor:textColor textFont:font placeHolderTextColor:nil placeHolderFont:nil];
}
-(void)setUISearchBarTextFieldBgColor:(UIColor *)backgroundColor textColor:(UIColor*)textColor textFont:(UIFont*)font placeHolderTextColor:(UIColor*)phColor placeHolderFont:(UIFont*)phFont {
    
    UITextField *searchTextField = nil;
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float >= 7.0)
    {
        
        searchTextField = [[[self.subviews firstObject] subviews] lastObject];
    }
    else{
        //iOS <7
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                searchTextField = (UITextField*)subView;
            }
        }
    }
    
    self.tintColor = [UIColor blackColor];
    if (searchTextField!=nil) {
        if (backgroundColor!=nil) {
            searchTextField.backgroundColor = backgroundColor;
        }
        
        if (textColor!=nil) {
            searchTextField.textColor = textColor;
        }
        
        if (font!=nil) {
            searchTextField.font = font;
        }
        
        if (phColor!=nil) {
            [searchTextField setValue:phColor forKeyPath:@"_placeholderLabel.textColor"];
           // [searchTextField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
        
        if (phFont!=nil) {
            [searchTextField setValue:phFont forKeyPath:@"_placeholderLabel.font"];
        }
        
        //隐藏收入框 左侧的 “搜索小图标”
        searchTextField.leftViewMode = UITextFieldViewModeNever;
        //searchTextField.rightViewMode = UITextFieldViewModeNever;
    }
    
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
