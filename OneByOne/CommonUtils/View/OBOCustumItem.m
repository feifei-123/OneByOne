//
//  OBOCustumItem.m
//  OneByOne
//
//  Created by 白雪飞 on 15-6-8.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "OBOCustumItem.h"
#import "Constants.h"


@interface OBOCustumItem()
@property(nonatomic,strong)NSMutableArray*constraintsArray;
@end

@implementation OBOCustumItem


-(NSMutableArray*)constraintsArray{
    if (_constraintsArray==nil) {
        _constraintsArray = [[NSMutableArray alloc]init];
    }
    return _constraintsArray;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        
        self.wholeView = [[UIView alloc]init];
        self.wholeView.userInteractionEnabled = YES;
        [self addSubview:self.wholeView];
        
        self.leftView = [[UIView alloc]init];
        self.leftView.userInteractionEnabled = YES;
        [self.wholeView insertSubview:self.leftView atIndex:5];
        
        self.rightView = [[UIView alloc]init];
        self.rightView.userInteractionEnabled = YES;
        [self.wholeView insertSubview:self.rightView atIndex:6];
        
        [self refreshViewConstraints];
        
       
    }
    return self;
}

-(void)refreshViewConstraints{

    //首先去除旧的constraints
    for (NSMutableArray*constraints in self.constraintsArray ) {
        [self removeConstraints:constraints];
    }
    
    [self.constraintsArray removeAllObjects];
    
    //加载新的constraints
    
    if (_leftViewWidth==nil) {
        _leftViewWidth = @(kLeftViewWidth);
    }
    
    [self.leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rightView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.wholeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|[_leftView(%f@750)][_rightView]|",self.leftViewWidth.floatValue];
   [self.constraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftView,_rightView,_wholeView)]];
    
    vfl_C1 = @"V:|[_leftView]|";
    [self.constraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftView,_rightView,_wholeView)]];
    
    vfl_C1 = @"V:|[_rightView]|";
     [self.constraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftView,_rightView,_wholeView)]];
    
    vfl_C1 = @"H:|[_wholeView]|";
    [self.constraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftView,_rightView,_wholeView)]];
    
    vfl_C1 = @"V:|[_wholeView]|";
    [self.constraintsArray addObject:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftView,_rightView,_wholeView)]];
    

    
    for (NSMutableArray*constraints in self.constraintsArray ) {
        [self addConstraints:constraints];
    }
    
    //刷新constraints
    [self layoutIfNeeded];

}



-(void)addWholeItem:(UIView*)item{
    
    //[self.wholeView insertSubview:item atIndex:1];
    [self.wholeView addSubview:item];
    
    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_C1 = @"H:|[item]|";
    NSString *vfl_C2 = @"V:|[item]|";
    [self.wholeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    [self.wholeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
}

-(void)addWholeItem:(UIView*)item atIndex:(int)index{
    
    [self.wholeView insertSubview:item atIndex:index];
    //[self.wholeView addSubview:item];
    
    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_C1 = @"H:|[item]|";
    NSString *vfl_C2 = @"V:|[item]|";
    [self.wholeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    [self.wholeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
}


-(void)addLeftItem:(UIView*)item{
    
    [self addLeftItem:item withCGRect:kDefaultRect];
}

-(void)addLeftItem:(UIView *)item withCGRect:(CGRect)rect{

    
    [self.leftView addSubview:item];
    
    if (rect.size.width==0) {
        rect.size.width = kImageWidth;
    }
    
    if (rect.size.height==0) {
        rect.size.height = kImageHeight;
    }
    
    
    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|-(%f@750)-[item(%f@750)]",rect.origin.x,rect.size.width];
    NSString *vfl_C2 = [NSString stringWithFormat:@"V:|-(%f@750)-[item(%f@750)]",rect.origin.y,rect.size.height];
    NSLog(@"addLeftItem---%@",vfl_C1);
    [self.leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    [self.leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    
}



//-(void)addLeftItem:(UIView*)item withLeftPadding:(NSNumber*)leftPadding TopPadding:(NSNumber*)topPadding{
//    [self.leftView addSubview:item];
//    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
//    
//    if(leftPadding==nil){
//        leftPadding =@(kLeftPadding);
//    }
//    if (topPadding==nil) {
//        topPadding =@(kTopPadding);
//    }
//    
//    
//    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|-(%f)-[item]",leftPadding.floatValue];
//    NSString *vfl_C2 = [NSString stringWithFormat:@"V:|-(%f)-[item]",topPadding.floatValue];
//    NSLog(@"---%@",vfl_C1);
//    [self.leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
//    [self.leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
//}


//-(void)addRightItem:(UIView*)item{
//    
//    
//    //[self addRightItem:item withLeftPadding:nil TopPadding:nil];
//}

-(void)addRightItem:(UIView*)item{
    
    [self.rightView addSubview:item];
    
    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|-(3)-[item]-(3)-|"];
    NSString *vfl_C2 = [NSString stringWithFormat:@"V:|-(3)-[item]-(3)-|"];

    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    
}

-(void)addRightItem:(UIView *)item withRect:(CGRect)rect{
  
    [self.rightView addSubview:item];
    
    
    if (rect.size.width==0) {
        rect.size.width = kImageWidth;
    }
    
    if (rect.size.height==0) {
        rect.size.height = kImageHeight;
    }
    
    
    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|-(%f@750)-[item(%f@750)]",rect.origin.x,rect.size.width];
    NSString *vfl_C2 = [NSString stringWithFormat:@"V:|-(%f@750)-[item(%f@750)]",rect.origin.y,rect.size.height];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
}
//-(void)addRightItem:(UIView*)item withLeftPadding:(NSNumber*)leftPadding TopPadding:(NSNumber*)topPadding{
//    
//    [self.rightView addSubview:item];
//    
//    if(leftPadding==nil){
//        leftPadding =@(kLeftPadding);
//    }
//    if (topPadding==nil) {
//        topPadding =@(kTopPadding);
//    }
//    
//    [item setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSString *vfl_C1 = [NSString stringWithFormat:@"H:|-(%f)-[item]|",leftPadding.floatValue];
//    NSString *vfl_C2 = [NSString stringWithFormat:@"V:|-(%f)-[item]|",topPadding.floatValue];
//    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C1 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
//    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl_C2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(item)]];
//}
//


-(void)setLeftViewWidth:(NSNumber*)width{
    
    _leftViewWidth = width;
    [self refreshViewConstraints];
}

@end
