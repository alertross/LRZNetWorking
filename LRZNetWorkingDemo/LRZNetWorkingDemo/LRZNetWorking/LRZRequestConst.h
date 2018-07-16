//
//  LRZRequestConst.h
//  LRZNetWorkingDemo
//
//  Created by 刘强 on 2018/7/12.
//  Copyright © 2018年 LightReason. All rights reserved.
//

#ifndef LRZRequestConst_h
#define LRZRequestConst_h

@class LRZURLRequest,LRZBatchRequest;

#define LRZBUG_LOG 0

#if(LRZBUG_LOG == 1)
# define LRZLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
# define LRZLog(...);
#endif

/**
 用于标识不同类型的请求
 */
typedef NS_ENUM(NSInteger,apiType) {
    /** 重新请求:   不读取缓存，重新请求*/
    LRZRequestTypeRefresh,
    /** 读取缓存:   有缓存,读取缓存--无缓存，重新请求*/
    LRZRequestTypeCache,
    /** 加载更多:   不读取缓存，重新请求*/
    LRZRequestTypeRefreshMore,
    /** 加载更多:   有缓存,读取缓存--无缓存，重新请求*/
    LRZRequestTypeCacheMore,
    /** 详情页面:   有缓存,读取缓存--无缓存，重新请求*/
    LRZRequestTypeDetailCache,
    /** 自定义项:   有缓存,读取缓存--无缓存，重新请求*/
    LRZRequestTypeCustomCache
};
/**
 HTTP 请求类型.
 */
typedef NS_ENUM(NSInteger,MethodType) {
    /**GET请求*/
    LRZMethodTypeGET,
    /**POST请求*/
    LRZMethodTypePOST,
    /**Upload请求*/
    LRZMethodTypeUpload,
    /**DownLoad请求*/
    LRZMethodTypeDownLoad,
    /**PUT请求*/
    LRZMethodTypePUT,
    /**PATCH请求*/
    LRZMethodTypePATCH,
    /**DELETE请求*/
    LRZMethodTypeDELETE
};
/**
 请求参数的格式.
 */
typedef NS_ENUM(NSUInteger, requestSerializerType) {
    /** 设置请求参数为二进制格式*/
    LRZHTTPRequestSerializer,
    /** 设置请求参数为JSON格式*/
    LRZJSONRequestSerializer
};

/** 批量请求配置的Block */
typedef void (^batchRequestConfig)(LRZBatchRequest * batchRequest);
/** 请求配置的Block */
typedef void (^requestConfig)(LRZURLRequest * request);
/** 请求成功的Block */
typedef void (^requestSuccess)(id responseObject,apiType type,BOOL isCache);
/** 请求失败的Block */
typedef void (^requestFailure)(NSError * error);
/** 请求进度的Block */
typedef void (^progressBlock)(NSProgress * progress);
/** 请求取消的Block */
typedef void (^cancelCompletedBlock)(BOOL results,NSString * urlString);


#endif /* LRZRequestConst_h */
