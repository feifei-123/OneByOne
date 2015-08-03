//
//  mmDAO.m
//  agent
//
//  Created by LiMing on 14-6-24.
//  Copyright (c) 2014年 bangban. All rights reserved.
//

#import "mmDAO.h"
#import "appDelegate.h"

static mmDAO *onlyInstance;

@interface mmDAO ()
@property (nonatomic, copy)NSString *modelName;
@property (nonatomic, copy)NSString *dbFileName;
@end

@implementation mmDAO
+(mmDAO*)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onlyInstance = [[mmDAO alloc] init];
    });
    return onlyInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void) setupEnvModel:(NSString *)model DbFile:(NSString*)filename{
    _modelName = model;
    _dbFileName = filename;
    [self initCoreDataStack];
}

- (void)initCoreDataStack
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _bgObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_bgObjectContext setPersistentStoreCoordinator:coordinator];

        _mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainObjectContext setParentContext:_bgObjectContext];
    }

}


- (NSManagedObjectContext *)createPrivateObjectContext
{
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [ctx setParentContext:_mainObjectContext];

    return ctx;
}


- (NSManagedObjectModel *)managedObjectModel
{
    NSManagedObjectModel *managedObjectModel;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_modelName withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_dbFileName];

    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(NSError*)save:(OperationResult)handler{
    NSError *error;
    if ([_mainObjectContext hasChanges]) {
        [_mainObjectContext save:&error];
        [_bgObjectContext performBlock:^{
            __block NSError *inner_error = nil;
            [_bgObjectContext save:&inner_error];
            if (handler){
                [_mainObjectContext performBlock:^{
                    handler(error);
                }];
            }
        }];
    }
    return error;
}
////这是appDelegate中的backgroundContext
//-(NSManagedObjectContext *)rootObjectContext {
//    if (nil != _rootObjectContext) {
//        return _rootObjectContext;
//    }
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _rootObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        [_rootObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return _rootObjectContext;
//}
////这是mainContext
//- (NSManagedObjectContext *)managedObjectContext {
//    if (nil != _managedObjectContext) {
//        return _managedObjectContext;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    _managedObjectContext.parentContext = [self rootObjectContext];
//    return _managedObjectContext;
//    // _managedObjectContext = [[NSManagedObjectContext alloc] init];
//    // _managedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
//    // return _managedObjectContext;
//}
////AppDelegate中saveContext方法，每次privateContext调用save方法成功之后都要call这个方法
//- (void)saveContextWithWait:(BOOL)needWait {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSManagedObjectContext *rootObjectContext = [self rootObjectContext];
//    if (nil == managedObjectContext) {
//        return;
//    }
//    if ([managedObjectContext hasChanges]) {
//        NSLog(@"Main context need to save");
//        [managedObjectContext performBlockAndWait:^{
//            NSError *error = nil;
//            if (![managedObjectContext save:&error]) {
//                NSLog(@"Save main context failed and error is %@", error);
//            }}];
//    }
//    if (nil == rootObjectContext) {
//        return;
//    }
//    RootContextSave rootContextSave = ^ {
//        NSError *error = nil;
//        
//        if (![_rootObjectContext save:&error]) {
//            NSLog(@"Save root context failed and error is %@", error);
//        } };
//    if ([rootObjectContext hasChanges]) {
//        NSLog(@"Root context need to save");
//        if (needWait) {
//            [rootObjectContext performBlockAndWait:rootContextSave];
//        }
//        else {
//            [rootObjectContext performBlock:rootContextSave];
//        }
//    }
//}
////这是伪API方法，仅供Demo使用
//+(void)getEmployeesWithMainContext:(NSManagedObjectContext *)mainContext completionBlock:(CompletionBlock)block {
//    NSManagedObjectContext *workContext = [NSManagedObjectContext generatePrivateContextWithParent:mainContext];
//    [workContext performBlock:^{
//        Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:workContext];
//        [employee setRandomData];
//        NSError *error = nil;
//        if([workContext save:&error]) {
//            block(YES, nil, nil);
//        }
//        else {
//            NSLog(@"Save employee failed and error is %@", error);
//            block(NO, nil, @"Get emploree failed");
//        } }];
//}
////这是NSManagedObjectContext的Category
//@implementation NSManagedObjectContext (GenerateContext)
//+(NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext
//{
//    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    privateContext.parentContext = parentContext;
//    return privateContext;
//}
//+(NSManagedObjectContext *)generateStraightPrivateContextWithParent:(NSManagedObjectContext *)mainContext {
//    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] init];
//    privateContext.persistentStoreCoordinator = mainContext.persistentStoreCoordinator;
//    
//    return privateContext;
//}
//@end
////这是ViewController里API操作和UI刷新的相关代码，从refreshData方法
//-(void)refreshData {
//    [EmployeeTool getEmployeesWithMainContext:[self mainContext] completionBlock:^(BOOL operationSuccess, id responseObject, NSString *errorMessage) {
//        if ([NSThread isMainThread]) {
//            NSLog(@"Handle result is main thread");
//            [self handleResult:operationSuccess];
//        }
//        else {
//            NSLog(@"Handle result is other thread");
//            [self performSelectorOnMainThread:@selector(handleResult:) withObject:[NSNumber numberWithBool:operationSuccess] waitUntilDone:YES];
//        }
//    }];
//}
//-(void)handleResult:(BOOL)operationSuccess {
//    if (operationSuccess) {
//        NSLog(@"Operation success");
//        [self saveContext];
//    }
//    [self.refreshControl endRefreshing];
//}
//-(void)saveContext {
//    WMAppDelegate *appDelegate = (WMAppDelegate*)[UIApplication sharedApplication].delegate;
//    [appDelegate saveContextWithWait:NO];
//}


@end
