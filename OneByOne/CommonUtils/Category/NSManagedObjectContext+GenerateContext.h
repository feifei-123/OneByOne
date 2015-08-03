//
//  NSManagedObjectContext+GenerateContext.h
//  OneByOne
//
//  Created by macbook on 15-5-13.
//  Copyright (c) 2015年 白雪飞. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (GenerateContext)

+(NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext;

+(NSManagedObjectContext *)generateStraightPrivateContextWithParent:(NSManagedObjectContext *)mainContext;

@end
