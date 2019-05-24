//
//  AppDelegate.m
//  PushDemo
//
//  Created by mob on 2019/4/29.
//  Copyright © 2019年 howhyone. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *viewController = [[ViewController alloc] init];
     self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.window makeKeyAndVisible];
    [self registerAPNs:application];
    return YES;
}
-(void)registerAPNs:(UIApplication *)application
{
//    iOS8~iOS10 与 iOS10之后的系统本地推送是不同的
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *unCenter = [UNUserNotificationCenter currentNotificationCenter];
        unCenter.delegate = self;
        [unCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"注册成功");

                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
        [unCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"regist success settting is  =====+%@",settings);
        }];
    } else {
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *setttings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
            [application registerUserNotificationSettings:setttings];
            [application registerForRemoteNotifications];
        }
    }
    
}



#pragma mark -- ios10 推送代理
//不实现通知不会有提示，收到通知的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)){
    
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//点击通知 进入APP的回调对通知响应
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)){
    NSString *categoryIdentifier = response.notification.request.content.categoryIdentifier;
    if ([categoryIdentifier isEqualToString:@"categoryIdentifier"]) {
        [self handleResponse:response];
        
        
    }
    completionHandler();
}

#pragma mark ---------------处理点击通知进入APP后的事件
-(void)handleResponse:(UNNotificationResponse *)response
API_AVAILABLE(ios(10.0)){
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([response.actionIdentifier isEqualToString:@"commitActionTitle"])
    {
        NSLog(@"commit Action =====");
    }else if ([response.actionIdentifier isEqualToString:@"textAction1"]){
        UNTextInputNotificationResponse *textResponse = (UNTextInputNotificationResponse *)response;
        NSString *userText = textResponse.userText;
        NSLog(@"input text is ======%@",userText);
    }else if ([response.actionIdentifier isEqualToString:@"cancelActionTitle"]){
        NSLog(@"cancel Action -------");
    }
        
    NSLog(@"%@",@"处理通知");
}

#pragma mark ------- ios8 ~ ios10 程序运行时收到通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"local noti" message:notification.alertBody delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
//    [alert show];
    application.applicationIconBadgeNumber -= 1;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification=======------=======------");
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer  API_AVAILABLE(ios(10.0)){
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"PushDemo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
