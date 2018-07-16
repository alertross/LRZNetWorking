//
//  HomeViewController.m
//  LRZNetWorkingDemo
//
//  Created by 刘强 on 2018/7/12.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import "HomeViewController.h"
#import "LRZNetworking.h"


@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [LRZRequestManager requestWithConfig:^(LRZURLRequest *request){
        request.URLString=list_URL;
        request.methodType=LRZMethodTypeGET;//默认为GET
        request.apiType=LRZRequestTypeCache;//默认为ZBRequestTypeRefresh
        // request.timeoutInterval=10;//默认30
    }  success:^(id responseObject,apiType type,BOOL isCache){
        //如果是刷新的数据
        if (type==LRZRequestTypeRefresh) {
            
        }
        //上拉加载 要添加 apiType 类型 ZBRequestTypeCacheMore(读缓存)或ZBRequestTypeRefreshMore(重新请求)， 也可以不遵守此枚举
        if (type==LRZRequestTypeRefreshMore) {
            //上拉加载
        }
        
        if (isCache==YES) {
            NSLog(@"使用了缓存");
        }else{
            NSLog(@"重新请求");
        }
        
    } failure:^(NSError *error){
        if (error.code==NSURLErrorCancelled)return;
        if (error.code==NSURLErrorTimedOut){
            [self alertTitle:@"请求超时" andMessage:@""];
        }else{
            [self alertTitle:@"请求失败" andMessage:@""];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
