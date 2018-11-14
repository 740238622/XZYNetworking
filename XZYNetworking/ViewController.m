//
//  ViewController.m
//  XZYNetworking
//
//  Created by 徐自由 on 2017/12/22.
//  Copyright © 2017年 徐自由. All rights reserved.
//

#import "ViewController.h"
#import "API.h"
#import <MJRefresh/MJRefresh.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tab;
    NSMutableArray *dataArray;
    NSInteger page;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dataArray = [NSMutableArray array];
    page = 0;
    
    [self setTabView];
    
    [self refresh];
    
}


- (void)setTabView
{
    tab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    tab.delegate = self;
    tab.dataSource = self;
    tab.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    tab.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    
    [self.view addSubview:tab];
}

- (void)refresh
{
    page = 0;
    API *api = [[API alloc] init:self tag:@"fresh"];
    api.cache = YES;
    [api textApi:@"api/CMS/PostInfo" params:@{@"PageCount":@"2",
                                              @"PageIndex":[NSNumber numberWithInteger:page],
                                              @"UserID":@"User20170330000001"}];
}

- (void)loadMore
{
    page ++;
    API *api = [[API alloc] init:self tag:@"fresh"];
    api.cache = YES;
    [api textApi:@"api/CMS/PostInfo" params:@{@"PageCount":@"2",
                                              @"PageIndex":[NSNumber numberWithInteger:page],
                                              @"UserID":@"User20170330000001"}];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *cellData = dataArray[indexPath.row];
    
    cell.textLabel.text = cellData[@"InfoTitle"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = dataArray[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:cellData[@"InfoTitle"] message:cellData[@"Remark"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma mark - Api回调
- (void)Failed:(NSString*)message tag:(NSString*)tag
{
//    [self closeLoadingView];
    NSLog(@"apiError=%@",message);
    //    [self showMessage:message];
    [tab.mj_header endRefreshing];
    [tab.mj_footer endRefreshing];
    
}
- (void)Sucess:(id)response tag:(NSString*)tag
{
    if ([tag isEqualToString:@"fresh"]) {
        //解析数据
        [tab.mj_header endRefreshing];
        [tab.mj_footer endRefreshing];
        if (page == 0) {
            dataArray = response;
            [tab reloadData];
        }else {
            [dataArray addObjectsFromArray:response];
            [tab reloadData];
        }
    }
}


@end
