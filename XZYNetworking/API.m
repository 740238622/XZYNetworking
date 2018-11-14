//
//  API.m
//  XZYNetworking
//
//  Created by 徐自由 on 2017/12/25.
//  Copyright © 2017年 徐自由. All rights reserved.
//

#import "API.h"

#define needToken httpRequest.needToken
#define isLoginFlag httpRequest.isLoginFlag
#define isCache httpRequest.isCache

@implementation API

#pragma mark - init方法
@synthesize httpRequest;

//无需token
- (instancetype)init:(id)delegate tag:(NSString *)tag
{
    return [self init:delegate tag:tag NeedToken:0];
}

//携带token
- (instancetype)init:(id)delegate tag:(NSString *)tag NeedToken:(NSInteger)NeedToken
{
    if (self=[super init]) {
        httpRequest = [[XZYNetworkingWithCache alloc] initWithDelegate:delegate bindTag:tag NeedToken:NeedToken];
        _cache = NO;
    }
    return self;
}

- (void)setCache:(BOOL)cache
{
    isCache = cache;
}


- (void)textApi:(NSString *)urlStr params:(id)params{
    
    [httpRequest httpPostRequest:urlStr params:params];
}


@end
