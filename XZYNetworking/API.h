//
//  API.h
//  XZYNetworking
//
//  Created by 徐自由 on 2017/12/25.
//  Copyright © 2017年 徐自由. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZYNetworkingWithCache.h"

@interface API : NSObject

@property (nonatomic,strong)  XZYNetworkingWithCache *httpRequest;

#pragma mark - init方法
//无需token
- (instancetype)init:(id)delegate tag:(NSString *)tag;
//携带token
- (instancetype)init:(id)delegate tag:(NSString *)tag NeedToken:(NSInteger)NeedToken;

//测试api
- (void)getInfo:(NSString *)one two:(NSString *)two;

@end
