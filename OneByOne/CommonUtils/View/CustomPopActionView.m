//
//  CustomPopActionView.m
//  MyPopSheet
//
//  Created by 白雪飞 on 15-5-4.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "CustomPopActionView.h"
#import "UIImage+stretch.h"
#import "UIColor+Hex.h"

@interface CustomPopActionView()
@property(nonatomic,strong)UIView *referView;      //父视图
@property(nonatomic,strong)UIView * containerView;   //内容视图
@property(nonatomic,strong)UIView * contentView; //组件视图－用于容纳 自定的子视图
@property(nonatomic,strong)UILabel * titleLbl;     //标题标签
@property(nonatomic,strong)UIButton * cancelBtn;   //取消按钮
@property(nonatomic,strong)UIButton * okBtn;   //取消按钮
@property (nonatomic, strong) UIButton *closeButton;// 透明的隐藏按钮！
@property(nonatomic,strong) NSString * title;//标题
//消失的时候移除
@property (nonatomic, strong) NSLayoutConstraint *containerViewAndViewConstraint;//约束containerView的底部 与self(view)对齐
//contentView高度的constraint
@property (nonatomic, strong) NSLayoutConstraint *contentViewHeightConstraint;//约束，约定contentView的高度。

@property (nonatomic,strong) NSArray*contentViewHeightConstraints;
@property (nonatomic, getter = isShowing) BOOL show;//标志位：是否正在显示
@property (nonatomic, assign) BOOL useGesturer;//标志位:是否可以通过下滑手势关闭视图，默认YES;
@property (nonatomic,strong)UIView * component;

@end



@implementation CustomPopActionView


-(id)initWithTitle:(NSString *)title referView:(UIView *)referView
{
    
    self = [super init];
    if(self){
        
        //接收参数
        self.title = title;
        if(referView){
            self.referView = referView;
        }
        
        //初始化页面元素
        [self initSubViews];
      
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLbl.text = _title;
}

-(void)initSubViews{
    
    //总视图(wholeView)的背景颜色：半透明 灰色
    self.backgroundColor = [UIColor colorWithRed:80 green:80 blue:80 alpha:0.4f];
    
    //关闭按钮
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
    //内容视图(contentView)
    self.containerView = [[UIView alloc]init];
    //self.containerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.95f];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];
    
    
    UIImageView *bgImageVIew = [[UIImageView alloc]initWithImage:[UIImage imageWithStretch:@"actionSheet_bg"]];
    [self.containerView addSubview:bgImageVIew];
    
    bgImageVIew.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dict = NSDictionaryOfVariableBindings(bgImageVIew);
    NSString*vfl = @"H:|[bgImageVIew]|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dict]];
    vfl = @"V:|-(-20)-[bgImageVIew]|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:dict]];
    
    
    //标题Label,无背景颜色
    self.titleLbl = [[UILabel alloc]init];
    self.titleLbl.backgroundColor = [UIColor clearColor];
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    self.titleLbl.font = [UIFont systemFontOfSize:18.0f];
    self.titleLbl.textColor = [UIColor colorWithHexString:@"#5f513f" alpha:1.0];
    self.titleLbl.text = self.title;
    [self.containerView addSubview:self.titleLbl];
    
    //内容视图
    self.contentView = [[UIView alloc]init];
    [self.containerView addSubview:self.contentView];
    
    //取消按钮
    self.cancelBtn = [[UIButton alloc]init];
    [self.cancelBtn setTitle:@"取  消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelBtn];
    
   
    //确定按钮
    self.okBtn = [[UIButton alloc]init];
    [self.okBtn setTitle:@"确  定" forState:UIControlStateNormal];
    [self.okBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.okBtn addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.okBtn];
    

  
    //禁止AutoresizingMask
    //self.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.okBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
  
    
    //添加下滑关闭手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandler:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipe];
}



-(void)initConstraints
{
    
    NSDictionary *dicts = NSDictionaryOfVariableBindings(_closeButton,_containerView,_titleLbl,_contentView,_okBtn,_cancelBtn);
    
    //(1)容器的配置
    NSString* vfl1 = @"H:|[_closeButton]|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    vfl1 = @"H:|[_containerView]|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    
    vfl1 = @"V:|[_closeButton][_containerView]|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    
    //(2)标题栏、内容栏、底部确认、取消按钮 的水平布局
    vfl1 = @"H:|[_titleLbl]|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    vfl1 = @"H:|[_contentView]|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    vfl1 = @"H:|[_cancelBtn][_okBtn(_cancelBtn)]|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    // 标题栏、内容栏、底部确认、取消按钮 的垂直布局
    vfl1 = @"V:|[_titleLbl(50)][_contentView][_okBtn(50)]|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    vfl1 = @"V:[_cancelBtn(50)]|";
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts]];
    
    vfl1 = [NSString stringWithFormat:@"V:[_contentView(%f)]",self.contentViewHeight];
    self.contentViewHeightConstraints =[NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dicts];
    [self.containerView addConstraints:self.contentViewHeightConstraints];
    
}

-(void)show
{
    if (self.isShowing) {
        return;
    }
    
    [self.referView addSubview:self];
    
    self.frame=self.referView.frame;
    
    [self initConstraints];
    self.alpha = 0;
    
    [self prepareForShow];
    
    [UIView animateWithDuration:0.25f animations:^{//动画  将self(view) 慢慢显现出来。
        self.alpha = 1;
        self.show = YES;
        
    }];

}


/**
 *为contentView视图 添加子控件component，并对component进行autoLayout布局
 */
-(void)prepareForShow
{
    if (self.contentViewHeight==0) {
        self.contentViewHeight = 200;//当忘记设置contentViewHeight时，为其设置默认值200;
    }
    if (self.component) {
        
        [self.contentView addSubview:self.component];
        //重要，要向使autoLayout生效，必须禁止AutoresizingMask
        
        self.component.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_containerView,_component);
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_component]|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_component]|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:constraints];
       
    }

    [self layoutIfNeeded];
}

-(void)hide
{
    if (!self.isShowing) {
        return;
        
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;//透明度设为0，隐藏self(view)
        [self removeConstraint:self.containerViewAndViewConstraint];//去除self(view)的约束
        self.containerViewAndViewConstraint = nil;
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        self.show = NO;//设置标志位 为未显示
        [self removeFromSuperview];//移除图层.
        
    }];

}



-(void)closeButtonClicked:(id)sender{
    
    [self hide];
    
}

-(void)okButtonClicked:(id)sender{
    
    [self hide];
    if (self.delegate) {
        [self.delegate bottomPopViewOkBtnClicked:self.tag];
    }
}

-(void)swipeHandler:(id)sender{
    if(self.useGesturer){
      [self hide];
    }
}


-(void)addComponentView:(UIView *)component{
    self.component = component;
    self.component.tag = self.tag;
    self.component.backgroundColor = [UIColor clearColor];

}



@end




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

*/



