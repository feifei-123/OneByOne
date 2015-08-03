//
//  NSObject+PerformBlockAfterDelay.m
//  OneByOne
//
//  Created by 白雪飞 on 15-7-21.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "NSObject+PerformBlockAfterDelay.h"

@implementation NSObject (PerformBlockAfterDelay)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay

{

    block = [block copy] ;
    [self performSelector:@selector(fireBlockAfterDelay:)withObject:block afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {

    block();
}

@end
