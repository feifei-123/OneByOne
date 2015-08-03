//
//  OBOPickerViewCell.m
//  OneByOne
//
//  Created by 白雪飞 on 15-7-2.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOPickerViewCell.h"
#import "Constants.h"

@interface OBOPickerViewCell()
@property(nonatomic,strong)UILabel* titleLabel;
@property(nonatomic,strong)UIImageView* iconImageView;
@property(nonatomic,strong)NSMutableArray* layoutConstraintArray;
@end
@implementation OBOPickerViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(UILabel*)titleLabel{
    if (_titleLabel==nil) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        //_titleLabel.backgroundColor = [UIColor greenColor];
    }
    return _titleLabel;
}

-(UIImageView*)iconImageView{
    if (_iconImageView==nil) {
        _iconImageView = [[UIImageView alloc]init];
    }
    return _iconImageView;
}
-(NSMutableArray*)layoutConstraintArray{
    if (_layoutConstraintArray==nil) {
        _layoutConstraintArray = [[NSMutableArray alloc]init];
    }
    return _layoutConstraintArray;
}


-(instancetype)init{
    
    self = [super init];
    
    if(self) {
        
        if (_iconLeftMargin==0.0) {
          _iconLeftMargin = kPickerViewIconLeftMargin;
        }
        if (_iconTopMaring==0.0f) {
           
            _iconTopMaring = kPickerViewIconTopMargin;
        }
        
        if (_iconWidth==0.0f) {
            _iconWidth = kPickerViewIconWidth;
        }
        
        if (_iconHeight==0.0f) {
            _iconHeight = kPickerViewIconHeight;
        }
        
        [self addSubviews];
        
        [self refreshIconConstraints];
        
    }
    
    return self;
}

-(void)setTitleLeftMargin:(CGFloat)titleLeftMargin{
    _titleLeftMargin = titleLeftMargin;
    [self refreshIconConstraints];
}
-(void)addSubviews{
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.iconImageView];
   
}

-(void)refreshIconConstraints{

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    for (int i = 0; i<self.layoutConstraintArray.count; i++) {
        [self removeConstraints:[self.layoutConstraintArray objectAtIndexedSubscript:i]];
    }
    
    [self.layoutConstraintArray removeAllObjects];
    
    NSDictionary*dicts = NSDictionaryOfVariableBindings(_titleLabel,_iconImageView);
    NSString*vfl = @"V:|[_titleLabel]|";
    [ self.layoutConstraintArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dicts]];
    //vfl = @"V:|-(%f)-[_titleLabel]|";
    vfl = [NSString stringWithFormat:@"H:|-(%f)-[_titleLabel]|",self.titleLeftMargin];
    [ self.layoutConstraintArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dicts]];
    vfl = [NSString stringWithFormat:@"H:|-(%f)-[_iconImageView(%f)]",self.iconLeftMargin,self.iconWidth];
     [ self.layoutConstraintArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dicts]];
    
    vfl = [NSString stringWithFormat:@"V:|-(%f)-[_iconImageView(%f)]",self.iconTopMaring,self.iconHeight];
     [ self.layoutConstraintArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dicts]];
    
    for (int i = 0; i<self.layoutConstraintArray.count; i++) {
        [self addConstraints:[self.layoutConstraintArray objectAtIndexedSubscript:i]];
    }
}



-(void)setTItle:(NSString *)title{
    self.titleLabel.text = title;
}

-(void)setIconImage:(UIImage*)image{
    self.iconImageView.image = image;
}

-(void)setIconLeftMargin:(CGFloat)iconLeftMargin{
    _iconLeftMargin= iconLeftMargin;
    [self refreshIconConstraints];
}

-(void)setIconTopMaring:(CGFloat)iconTopMaring{
    _iconTopMaring = iconTopMaring;
    [self refreshIconConstraints];
}

-(void)setIconWidth:(CGFloat)iconWidth{
    _iconWidth = iconWidth;
    [self refreshIconConstraints];
}

-(void)setIconHeight:(CGFloat)iconHeight{
    _iconHeight = iconHeight;
    [self refreshIconConstraints];
}

-(void)setTitleFont:(UIFont*)font{
    self.titleLabel.font =font;
}

-(void)setTitleColor:(UIColor*)color{
    self.titleLabel.textColor = color;
}

@end
