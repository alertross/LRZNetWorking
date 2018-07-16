//
//  LRZReqyestEngine.m
//  LRZNetWorkingDemo
//
//  Created by 刘强 on 2018/7/12.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#import "LRZRequestEngine.h"
#import "LRZURLRequest.h"
#import "NSString+LRZUTF8Encoding.h"
@implementation LRZRequestEngine

+ (instancetype)defaultEngine {
    static LRZRequestEngine *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[LRZRequestEngine alloc]init];
    });
    return shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        //无条件地信任服务器端返回的证书。
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        /*因为与缓存互通 服务器返回的数据 必须是二进制*/
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",nil];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

- (void)dealloc {
    [self invalidateSessionCancelingTasks:YES];
}

#pragma mark - GET/POST/PUT/PATCH/DELETE
- (NSURLSessionDataTask *)dataTaskWithMethod:(LRZURLRequest *)request
                                 zb_progress:(void (^)(NSProgress * _Nonnull))zb_progress
                                     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    [self requestSerializerConfig:request];
    [self headersAndTimeConfig:request];
    
    NSString *URLString=[NSString lrz_stringUTF8Encoding:request.URLString];
    if (request.methodType==LRZMethodTypePOST) {
        return [self POST:URLString parameters:request.parameters progress:zb_progress success:success failure:failure];
    }else if (request.methodType==LRZMethodTypePUT){
        return [self PUT:URLString parameters:request.parameters success:success failure:failure];
    }else if (request.methodType==LRZMethodTypePATCH){
        return [self PATCH:URLString parameters:request.parameters success:success failure:failure];
    }else if (request.methodType==LRZMethodTypeDELETE){
        return [self DELETE:URLString parameters:request.parameters success:success failure:failure];
    }else{
        return [self GET:URLString parameters:request.parameters progress:zb_progress success:success failure:failure];
    }
}

#pragma mark - upload
- (NSURLSessionDataTask *)uploadWithRequest:(LRZURLRequest *)request
                                zb_progress:(void (^)(NSProgress * _Nonnull))zb_progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSURLSessionDataTask *uploadTask = [self POST:[NSString lrz_stringUTF8Encoding:request.URLString] parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [request.uploadDatas enumerateObjectsUsingBlock:^(LRZUploadData *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fileData) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }
            } else if (obj.fileURL) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:nil];
                } else {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name error:nil];
                }
            }
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            zb_progress ? zb_progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(task,responseObject) :nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(task,error) :nil;
    }];
    return uploadTask;
}

#pragma mark - DownLoad
- (NSURLSessionDownloadTask *)downloadWithRequest:(LRZURLRequest *)request
                                         progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString lrz_stringUTF8Encoding:request.URLString]]];
    [self headersAndTimeConfig:request];
    
    NSURL *downloadFileSavePath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:request.downloadSavePath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[request.downloadSavePath, fileName]] isDirectory:NO];
    } else {
        downloadFileSavePath = [NSURL fileURLWithPath:request.downloadSavePath isDirectory:NO];
    }
    NSURLSessionDownloadTask *dataTask = [self downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            downloadProgressBlock ? downloadProgressBlock(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return downloadFileSavePath;
    } completionHandler:completionHandler];
    
    [dataTask resume];
    return dataTask;
}

#pragma mark - 其他配置
- (void)requestSerializerConfig:(LRZURLRequest *)request{
    self.requestSerializer =request.requestSerializerType==LRZJSONRequestSerializer ? [AFJSONRequestSerializer serializer]:[AFHTTPRequestSerializer serializer];
}

- (void)headersAndTimeConfig:(LRZURLRequest *)request{
    self.requestSerializer.timeoutInterval=request.timeoutInterval?request.timeoutInterval:30;
    if ([[request mutableHTTPRequestHeaders] allKeys].count>0) {
        [[request mutableHTTPRequestHeaders] enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}

#pragma mark - 取消请求
- (void)cancelRequest:(NSString *)URLString completion:(cancelCompletedBlock)completion{
    
    __block NSString *currentUrlString=nil;
    BOOL results;
    @synchronized (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[[task.currentRequest URL] absoluteString] isEqualToString:[NSString lrz_stringUTF8Encoding:URLString]]) {
                currentUrlString =[[task.currentRequest URL] absoluteString];
                [task cancel];
                *stop = YES;
            }
        }];
    }
    if (currentUrlString==nil) {
        results=NO;
    }else{
        results=YES;
    }
    completion ? completion(results,currentUrlString) : nil;
}
@end
