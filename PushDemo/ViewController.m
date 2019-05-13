//
//  ViewController.m
//  PushDemo
//
//  Created by mob on 2019/4/29.
//  Copyright © 2019年 howhyone. All rights reserved.
//

#import "ViewController.h"
#import "LocalNotificationViewController.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property(nonatomic, strong)LocalNotificationViewController *localNotificationVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setViewInfo];
     LocalNotificationViewController *localNotificationVC = [LocalNotificationViewController new];
    self.localNotificationVC = localNotificationVC;
}

-(void)setViewInfo
{
    NSArray *btnTitleArr = @[@"clickLocalNotification"];
    for (int i = 0;i < [btnTitleArr count] ; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(screenWidth / 2 -100, screenHeight / 4 * (i+1), 200, 40)];
        button.tag = i;
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:[UIColor greenColor]];
        [button setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
    }
}


-(void)clickButton:(UIButton *)buttonN
{
    switch (buttonN.tag) {
        case 0:
           
            [self.navigationController pushViewController:_localNotificationVC animated:YES];
            break;
            
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSURL *url = [NSURL URLWithString:@"moblink123://"];
    if ([[UIApplication sharedApplication] canOpenURL:url] ) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"haaaaaaaaaa");
        }];
    }
}

@end
