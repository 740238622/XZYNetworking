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
@property (nonatomic,copy) NSString *urlString;

- (instancetype)initWithDelegate:(id)requestDelegate bindTag:(NSString *)bindTag NeedToken:(NSInteger)NeedToken;

#pragma mark - Get方法(默认方法)
//不带缓存
- (void)httpGetRequest:(NSString *)api params:(NSMutableDictionary *)params;
- (void)httpGetCacheRequest:(NSString *)api params:(NSMutableDictionary *)params;

#pragma mark - Post方法
//不带缓存
- (void)httpPostRequest:(NSString *)api params:(NSMutableDictionary *)params;
- (void)httpPostCacheRequest:(NSString *)api params:(NSMutableDictionary *)params;

#pragma mark - 上传文件方法
//上传单张图片
- (void)upLoadDataWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params imageKey:(NSString *)name withData:(NSData *)data;
//上传多张图片
- (void)upLoadDataWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params  withDataArray:(NSArray *)dataArray;

@end
