//
//  XZYNetworkingWithCache.h
//  XZYNetworking
//
//  Created by 徐自由 on 2017/12/22.
//  Copyright © 2017年 徐自由. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <YYCache/YYCache.h>

//废弃掉
@protocol XZYNetworkingWithCacheDelegate <NSObject>

@optional

- (void)httpSuccess:(id)response bindTag:(NSString *)bindTag;

- (void)httpError:(NSString *)error bindTag:(NSString *)bindTag;

@end

@interface XZYNetworkingWithCache : NSObject

@property (nonatomic,strong) id requestDelegate;
@property (nonatomic,copy) NSString *bindTag;
@property (nonatomic,assign) NSInteger needToken;
@property (nonatomic,assign) NSInteger isLoginFlag;//1时如果token可传为空就不跳出登陆界面

/**
 初始化

 @param requestDelegate 代理
 @param bindTag 接口tag
 @param NeedToken 是否判断登录
 @return return value description
 */
- (instancetype)initWithDelegate:(id)requestDelegate bindTag:(NSString *)bindTag NeedToken:(NSInteger)NeedToken;

#pragma mark - Get方法(默认方法)
/**
 Get不带缓存请求

 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpGetRequest:(NSString *)api params:(NSMutableDictionary *)params;

/**
 Get带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpGetCacheRequest:(NSString *)api params:(NSMutableDictionary *)params;

#pragma mark - Post方法
/**
 Post不带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpPostRequest:(NSString *)api params:(NSMutableDictionary *)params;
/**
 Post带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpPostCacheRequest:(NSString *)api params:(NSMutableDictionary *)params;

#pragma mark - 上传文件方法
/**
 上传单张图片

 @param api 接口名
 @param params 接口参数字典
 @param name 图片名
 @param data 二进制图片
 */
- (void)upLoadDataWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params imageKey:(NSString *)name withData:(NSData *)data;

/**
 上传多张图片

 @param api 接口名
 @param params 接口参数字典
 @param dataArray 数组存放二进制图片
 */
- (void)upLoadDataWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params  withDataArray:(NSArray *)dataArray;

@end
