//
//  OBOTouchTableView.h
//  OneByOne
//
//  Created by macbook on 15-7-23.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OBOTouchTableViewDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface OBOTouchTableView : UITableView

@property (nonatomic,assign) id<OBOTouchTableViewDelegate> touchDelegate;

@end
