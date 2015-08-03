//
//  OBOPickerViewCell.h
//  OneByOne
//
//  Created by 白雪飞 on 15-7-2.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBOPickerViewCell : UIView
@property(assign,nonatomic)CGFloat leftMargin;
@property(assign,nonatomic)CGFloat rightMargin;
@property(assign,nonatomic)CGFloat iconTopMaring;
@property(assign,nonatomic)CGFloat iconWidth;
@property(assign,nonatomic)CGFloat iconHeight;
@property(assign,nonatomic)CGFloat titleWidth;

-(void)setTItle:(NSString *)title;
-(void)setIconImage:(UIImage*)image;

-(void)setTitleFont:(UIFont*)font;
-(void)setTitleColor:(UIColor*)color;
@end
