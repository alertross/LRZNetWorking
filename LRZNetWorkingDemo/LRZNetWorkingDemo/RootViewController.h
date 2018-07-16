//
//  RootViewController.h
//  LRZNetWorkingDemo
//
//  Created by 刘强 on 2018/7/12.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import <UIKit/UIKit.h>
#define list_URL @"http://api.dotaly.com/lol/api/v1/authors?iap=0"

#define details_URL @"http://api.dotaly.com/lol/api/v1/shipin/latest?author=%@&iap=0jb=0&limit=50&offset=0"

//屏幕宽
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
//屏幕高
#define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)
@interface RootViewController : UIViewController
//title 设置btn的标题; selector点击btn实现的方法; isLeft 标记btn的位置
- (void)addItemWithTitle:(NSString *)title selector:(SEL)selector location:(BOOL)isLeft;
//title提示框的标题; andMessage提示框的描述
- (void)alertTitle:(NSString *)title andMessage:(NSString *)message;

@end
