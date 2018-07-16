//
//  LRZRequestManager.m
//  LRZNetWorkingDemo
//
//  Created by 刘强 on 2018/7/12.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import "LRZRequestManager.h"
#import "LRZCacheManager.h"
#import "LRZURLRequest.h"
#import "NSString+LRZUTF8Encoding.h"

@implementation LRZRequestManager
#pragma mark - 配置请求
+ (void)requestWithConfig:(requestConfig)config success:(requestSuccess)success failure:(requestFailure)failure{
    [self requestWithConfig:config progress:nil success:success failure:failure];
}

+ (void)requestWithConfig:(requestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure {
    LRZURLRequest *request=[[LRZURLRequest alloc]init];
    //执行block参数得到外层设置过的LRZURLRequest实例
    config ? config(request) : nil;
    [self sendRequest:request progress:progress success:success failure:failure];
}

+ (LRZBatchRequest *)sendBatchRequest:(batchRequestConfig)config success:(requestSuccess)success failure:(requestFailure)failure{
    return [self sendBatchRequest:config progress:nil success:success failure:failure];
}

+ (LRZBatchRequest *)sendBatchRequest:(batchRequestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure{
    LRZBatchRequest *batchRequest=[[LRZBatchRequest alloc]init];
    config ? config(batchRequest) : nil;
    
    if (batchRequest.urlArray.count==0)return nil;
    [batchRequest.urlArray enumerateObjectsUsingBlock:^(LRZURLRequest *request , NSUInteger idx, BOOL *stop) {
        [self sendRequest:request progress:progress success:success failure:failure];
    }];
    return batchRequest;
}

#pragma mark - 发起请求
+ (void)sendRequest:(LRZURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure {
    if([request.URLString isEqualToString:@""]||request.URLString==nil)return;
    
    if (request.methodType==LRZMethodTypeUpload) {
        [self sendUploadRequest:request progress:progress success:success failure:failure];
    }else if (request.methodType==LRZMethodTypeDownLoad){
        [self sendDownLoadRequest:request progress:progress success:success failure:failure];
    }else{
        [self sendHTTPRequest:request progress:progress success:success failure:failure];
    }
}

+ (void)sendUploadRequest:(LRZURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure{
    [[LRZRequestEngine defaultEngine] uploadWithRequest:request zb_progress:progress success:^(NSURLSessionDataTask *task, id responseObject) {
        success ? success(responseObject,LRZRequestTypeRefresh,NO) : nil;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure ? failure(error) : nil;
    }];
}

+ (void)sendDownLoadRequest:(LRZURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure{
    [[LRZRequestEngine defaultEngine] downloadWithRequest:request progress:progress completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        failure ? failure(error) : nil;
        success ? success([filePath path],request.apiType,NO) : nil;
    }];
}

+ (void)sendHTTPRequest:(LRZURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure {
    NSString *key = [self keyWithParameters:request];
    if ([[LRZCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType!=LRZRequestTypeRefresh&&request.apiType!=LRZRequestTypeRefreshMore){
        [[LRZCacheManager sharedInstance]getCacheDataForKey:key value:^(NSData *data,NSString *filePath) {
            success ? success(data ,request.apiType,YES) : nil;
        }];
    }else{
        [self dataTaskWithHTTPRequest:request progress:progress success:success failure:failure];
    }
}

+ (void)dataTaskWithHTTPRequest:(LRZURLRequest *)request progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure {
    [[LRZRequestEngine defaultEngine]dataTaskWithMethod:request zb_progress:^(NSProgress * _Nonnull zb_progress) {
        progress ? progress(zb_progress) : nil;
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self storeObject:responseObject request:request];
        success ? success(responseObject,request.apiType,NO) : nil;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure ? failure(error) : nil;
    }];
}

#pragma mark - 其他配置
+ (NSString *)keyWithParameters:(LRZURLRequest *)request {
    if (request.parametersfiltrationCacheKey.count>0) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:request.parameters];
        [mutableParameters removeObjectsForKeys:request.parametersfiltrationCacheKey];
        request.parameters =  [mutableParameters copy];
    }
    NSString *URLStringCacheKey;
    if (request.customCacheKey) {
        URLStringCacheKey=request.customCacheKey;
    }else{
        URLStringCacheKey=request.URLString;
    }
    return [NSString lrz_stringUTF8Encoding:[NSString lrz_urlString:URLStringCacheKey appendingParameters:request.parameters]];
}

+ (void)storeObject:(NSObject *)object request:(LRZURLRequest *)request {
    NSString * key= [self keyWithParameters:request];
    [[LRZCacheManager sharedInstance] storeContent:object forKey:key isSuccess:^(BOOL isSuccess) {
        if (isSuccess) {
            LRZLog(@"store successful");
        }else{
            LRZLog(@"store failure");
        }
    }];
}

+ (void)cancelRequest:(NSString *)URLString completion:(cancelCompletedBlock)completion{
    if([URLString isEqualToString:@""]||URLString==nil)return;
    [[LRZRequestEngine defaultEngine]cancelRequest:URLString completion:completion];
}

@end
