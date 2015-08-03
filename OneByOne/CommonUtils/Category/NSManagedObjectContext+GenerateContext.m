//
//  NSManagedObjectContext+GenerateContext.m
//  OneByOne
//
//  Created by macbook on 15-5-13.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import "NSManagedObjectContext+GenerateContext.h"

@implementation NSManagedObjectContext (GenerateContext)
+(NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.parentContext = parentContext;
    return privateContext;
}
+(NSManagedObjectContext *)generateStraightPrivateContextWithParent:(NSManagedObjectContext *)mainContext {
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] init];
    privateContext.persistentStoreCoordinator = mainContext.persistentStoreCoordinator;
    
    return privateContext;
}
@end

