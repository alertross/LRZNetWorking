//
//  NSString+LRZYTF8Encoding.h
//  LRZNetWorkingDemo
//
//  Created by 刘强 on 2018/7/12.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LRZUTF8Encoding)
/**
 UTF8
 
 @param urlString 编码前的url字符串
 @return 返回 编码后的url字符串
 */
+ (NSString *)lrz_stringUTF8Encoding:(NSString *)urlString;

/**
 url字符串与parameters参数的的拼接
 
 @param urlString url字符串
 @param parameters parameters参数
 @return 返回拼接后的url字符串
 */
+ (NSString *)lrz_urlString:(NSString *)urlString appendingParameters:(id)parameters;
@end
