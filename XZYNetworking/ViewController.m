//
//  ViewController.m
//  XZYNetworking
//
//  Created by 徐自由 on 2017/12/22.
//  Copyright © 2017年 徐自由. All rights reserved.
//

#import "ViewController.h"
#import "API.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    API *api = [[API alloc] init:self tag:@"baidu"];
    [api getInfo:@"one" two:@"two"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Failed:(NSString*)message tag:(NSString*)tag
{
//    [self closeLoadingView];
    NSLog(@"apiError=%@",message);
    //    [self showMessage:message];
    
}
- (void)Sucess:(id)response tag:(NSString*)tag
{
    if ([tag isEqualToString:@"baidu"]) {
        //解析数据
        
    }
}


@end
