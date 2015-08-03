//
//  OBOCustumItem.h
//  OneByOne
//
//  Created by 白雪飞 on 15-6-8.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBOCustumItem : UIImageView;
@property(strong,nonatomic)UIView *leftView;
@property(strong,nonatomic)UIView *rightView;
@property(strong,nonatomic)UIView *wholeView;
@property(strong,nonatomic)NSNumber* leftViewWidth;

-(void)addLeftItem:(UIView *)item withCGRect:(CGRect)rect;
-(void)addRightItem:(UIView *)item withRect:(CGRect)rect;
-(void)addLeftItem:(UIView*)item;
-(void)addRightItem:(UIView*)item;
-(void)addWholeItem:(UIView*)item;
-(void)addWholeItem:(UIView*)item atIndex:(int)index;

@end
