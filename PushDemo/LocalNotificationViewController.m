//
//  LocalNotificationViewController.m
//  PushDemo
//
//  Created by mob on 2019/4/30.
//  Copyright © 2019年 howhyone. All rights reserved.
//

#import "LocalNotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
@interface LocalNotificationViewController ()


@end

@implementation LocalNotificationViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.title = @"本地推送";
    [self setLocalNotification];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消推送" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelLocalNotifications) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setFrame:CGRectMake(100, 200, 80, 80)];
    [self.view addSubview:cancelBtn];
}

#pragma mark ----------- 配置本地推送
-(void)setLocalNotification
{
//   只创建一个通知，重复一次创建一次太恐怖了
    NSArray *notificatinArr = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (notificatinArr.count) {
        return;
    }
    NSString *title = @"通知-title";
    NSString *subTitle = @"通知-subTitle";
    NSString *body = @"通知-body";
    NSInteger badge = 1;
    NSInteger timeIntevel = 60;
    NSDictionary *userInfo = @{@"id":@"LOCAL_NOTIFY_SCHEDULE_ID"};
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *NotifCenter = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
        notificationContent.sound = [UNNotificationSound defaultSound];
        notificationContent.title = title;
        notificationContent.subtitle = subTitle;
        notificationContent.body = body;
        notificationContent.badge = @(badge);
        notificationContent.userInfo = userInfo;
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"jjy2" ofType:@"jpg"];
        
//        设置通知附件内容
        UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
        notificationContent.attachments = @[att];
        notificationContent.launchImageName = @"jjy1.png";
//        设置声音
        UNNotificationSound *sound = [UNNotificationSound soundNamed:@"sound02.wav"]; //要有后缀
        notificationContent.sound = sound;
        
//        标识符   推送用户的交互 左拉，点击管理按钮 会出现category 按钮
        notificationContent.categoryIdentifier = @"categoryIdentifier";
        
        UNTextInputNotificationAction *textAction = [UNTextInputNotificationAction actionWithIdentifier:@"textAction1" title:@"textActionTitle1" options:UNNotificationActionOptionForeground textInputButtonTitle:@"textInpuButtonTitle1" textInputPlaceholder:@"textInputPlaceholder1"];
        UNNotificationAction *commitAction = [UNNotificationAction actionWithIdentifier:@"commitAction" title:@"commitActionTitle" options:UNNotificationActionOptionForeground];
        UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"cancelAction" title:@"cancelActionTitle" options:UNNotificationActionOptionForeground];
        UNNotificationCategory *notifCategory = [UNNotificationCategory categoryWithIdentifier:@"categoryIdentifier" actions:@[textAction,commitAction,cancelAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        NSSet *categorySet = [[NSSet alloc] initWithObjects:notifCategory, nil];
        [NotifCenter setNotificationCategories:categorySet];


//        设置触发模式
        UNTimeIntervalNotificationTrigger *timeIntervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeIntevel repeats:YES];
//        设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request1" content:notificationContent trigger:timeIntervalTrigger];
//        把通知加到UNUserNotificationCenter 到指定触发点会被触发
        [NotifCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"addNotificationRequest success :error is  %@",error);
            }
            else{
                NSLog(@"addNotificationRequest failed");
            }
        }];
        if (error) {
            NSLog(@"attachment error %@",error);
        }
    } else {
//        iOS10之前的系统 APP处于后台才会有提示，但是会收到推送
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = [self setLowVersionLocalNotification:title];
        localNotification.alertBody = [self setLowVersionLocalNotification:body];
        localNotification.alertLaunchImage = [[NSBundle mainBundle] pathForResource:@"jjy2" ofType:@"jpg"];
//        锁屏状态下显示的文字
         localNotification.alertAction = @"锁屏状态下";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.repeatInterval = NSCalendarUnitMinute;
        
        localNotification.soundName = @"sound01.wav";//UILocalNotificationDefaultSoundName;
        localNotification.userInfo = @{@"keyInfo":@"valueInfo",
                                       @"id"     :@"LOCAL_NOTIFY_SCHEDULE_ID"};
        localNotification.applicationIconBadgeNumber = 1;

        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

-(NSString *)setLowVersionLocalNotification:(NSString *)param
{
    NSString *paramStr = [param stringByAppendingString:@"低于10.0"];
    return paramStr;
}
//不重复推送：推送一次后就会自动取消推送，重复推送的话需要手动取消，不然即使卸载应用也会残留，下次重装也会继续推送
-(void)cancelLocalNotifications
{
    
    NSArray *notificationArr = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (!notificationArr || notificationArr.count <= 0) {
        return;
    }
    for (UILocalNotification *localNotify in notificationArr) {
        if ([[localNotify.userInfo valueForKey:@"id"] isEqualToString:@"LOCAL_NOTIFY_SCHEDULE_ID"]) {
            if (@available(iOS 10.0, *)) {
//                 移除已展示过的通知
                [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[@"request1"]];
//                 取消还未发送的通知
                [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[@"request1"]];
            } else {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotify];
            }
        }
    }
}

@end
