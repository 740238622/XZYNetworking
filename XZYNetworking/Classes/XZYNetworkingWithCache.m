//
//  XZYNetworkingWithCache.m
//  XZYNetworking
//
//  Created by 徐自由 on 2017/12/22.
//  Copyright © 2017年 徐自由. All rights reserved.
//

#define URLStr @"www.baidu.com/" //接口前缀

#import "XZYNetworkingWithCache.h"

NSString * const HttpCache = @"HttpRequestCache";
#define DYLog(...) NSLog(__VA_ARGS__)  //如果不需要打印数据, 注释掉NSLog

//请求方式
typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeGet,//Get请求
    RequestTypePost,//Post请求
    RequestTypeUpLoad,//单张图片上传
    RequestTypeMultiUpload,//多张图片上传
    RequestTypeDownload//下载
};

@implementation XZYNetworkingWithCache
{
    __weak XZYNetworkingWithCache *weakSelf;
}

/**
 初始化
 
 @param requestDelegate 代理
 @param bindTag 接口tag
 @param NeedToken 是否判断登录
 @return return value description
 */
- (instancetype)initWithDelegate:(id)requestDelegate bindTag:(NSString *)bindTag NeedToken:(NSInteger)NeedToken
{
    if (self = [super init]) {
        self.requestDelegate = requestDelegate;
        self.bindTag = bindTag;
        self.needToken = NeedToken;
        weakSelf = self;
    }
    return self;
}

#pragma mark - Get方法(默认方法)
/**
 Get不带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpGetRequest:(NSString *)api params:(NSMutableDictionary *)params
{
    [self httpRequestWithUrlStr:api params:params requestType:RequestTypeGet isCache:NO cacheKey:nil imageKey:nil withData:nil withDataArray:nil];
}

/**
 Get带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpGetCacheRequest:(NSString *)api params:(NSMutableDictionary *)params
{
    [self httpRequestWithUrlStr:api params:params requestType:RequestTypeGet isCache:YES cacheKey:api imageKey:nil withData:nil withDataArray:nil];

}

#pragma mark - Post方法
/**
 Post不带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpPostRequest:(NSString *)api params:(NSMutableDictionary *)params
{
    [self httpRequestWithUrlStr:api params:params requestType:RequestTypePost isCache:NO cacheKey:nil imageKey:nil withData:nil withDataArray:nil];
}

/**
 Post带缓存请求
 
 @param api 接口名
 @param params 接口参数字典
 */
- (void)httpPostCacheRequest:(NSString *)api params:(NSMutableDictionary *)params
{
    [self httpRequestWithUrlStr:api params:params requestType:RequestTypePost isCache:YES cacheKey:api imageKey:nil withData:nil withDataArray:nil];
}

#pragma mark - 上传文件方法
/**
 上传单张图片
 
 @param api 接口名
 @param params 接口参数字典
 @param name 图片名
 @param data 二进制图片
 */
- (void)upLoadDataWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params imageKey:(NSString *)name withData:(NSData *)data
{
    [self httpRequestWithUrlStr:api params:params requestType:RequestTypeUpLoad isCache:NO cacheKey:api imageKey:name withData:data withDataArray:nil];

}

/**
 上传多张图片
 
 @param api 接口名
 @param params 接口参数字典
 @param dataArray 数组存放二进制图片
 */
- (void)upLoadDataWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params  withDataArray:(NSArray *)dataArray
{
    [self httpRequestWithUrlStr:api params:params requestType:RequestTypeMultiUpload isCache:NO cacheKey:api imageKey:nil withData:nil withDataArray:dataArray];
}


#pragma mark - 网络请求统一处理
/**

 @param api 后台的接口名
 @param params 参数dict
 @param requestType 请求类型
 @param isCache 是否缓存标志
 @param cacheKey 缓存的对应key值
 @param name 图片上传的名字(upload)
 @param data 图片的二进制数据(upload)
 @param dataArray 多图片上传时的imageDataArray
 */
- (void)httpRequestWithUrlStr:(NSString *)api params:(NSMutableDictionary *)params requestType:(RequestType)requestType isCache:(BOOL)isCache cacheKey:(NSString *)cacheKey imageKey:(NSString *)name withData:(NSData *)data withDataArray:(NSArray *)dataArray
{
    NSString *url = [NSString stringWithFormat:@"%@%@", URLStr, api];
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (params == nil) {
        params = [NSMutableDictionary dictionary];
    }
    
    NSString *allUrl = [self urlDictToStringWithUrlStr:url WithDict:params];
    DYLog(@"\n\n 网址 \n\n      %@    \n\n 网址 \n\n",allUrl);
    
    //设置YYCache属性
    YYCache *cache = [[YYCache alloc] initWithName:HttpCache];
    cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;//当接收到来自系统的内存警告时，是否要清除所有缓存，默认是 YES。建议使用默认。
    cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;//当进入后台的时候是否要清除所有缓存，默认是 YES。建议使用默认。
    
    id cacheData;
    //此处要修改为,服务端不要求重新拉取数据时执行;注意当缓存没取到时,重新访问接口
    if (isCache) {//根据网址从Cache中取数据
        cacheData = [cache objectForKey:cacheKey];
        if(cacheData != nil)
        {//将数据统一处理
            [self returnDataWithRequestData:cacheData];
        }
    }
    
    //进行网络检查
    if (![self requestBeforeJudgeConnect]) {//断网
        [self showError:@"请检查网络设置"];
        DYLog(@"\n\n----%@------\n\n",@"没有网络");
        //断网后,根据网址从Cache中取数据进行显示
        id cacheData = [cache objectForKey:cacheKey];
        if(cacheData != nil)
        {//将数据统一处理
            [self returnDataWithRequestData:cacheData];
        }
        return;
    }
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    //超时时间 30s
    session.requestSerializer.timeoutInterval = 30;
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    if (requestType == RequestTypeGet) {//Get请求
        [session GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [weakSelf dealWithResponseObject:responseObject cacheUrl:allUrl cacheData:cacheData isCache:isCache cache:cache cacheKey:cacheKey];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf showError:@"请检查网络设置"];
        }];
    } else if (requestType == RequestTypePost) {//post请求
        [session POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            [weakSelf dealWithResponseObject:responseObject cacheUrl:allUrl cacheData:cacheData isCache:isCache cache:cache cacheKey:cacheKey];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf showError:@"请检查网络设置"];
        }];
    } else if (requestType == RequestTypeUpLoad) {//上传单张图片
        [session POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSTimeInterval timeInterVal = [[NSDate date] timeIntervalSince1970];
            NSString * fileName = [NSString stringWithFormat:@"%@.png",@(timeInterVal)];
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/png"];
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            //(float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount
//            打印进度
//            NSLog(@"%lf", 1.0 * (float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [weakSelf dealWithResponseObject:responseObject cacheUrl:allUrl cacheData:cacheData isCache:isCache cache:nil cacheKey:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf showError:@"上传文件出错"];
        }];
    } else if (requestType == RequestTypeMultiUpload) {//上传多张图片
        [session POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            for (NSInteger i = 0; i < dataArray.count; i++) {
                NSData *imageData = [dataArray objectAtIndex:i];
                //name和服务端约定好
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"pic%zi", i] fileName:[NSString stringWithFormat:@"%zi.jpg", i] mimeType:@"image/jpeg"];
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            //(float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [weakSelf dealWithResponseObject:responseObject cacheUrl:allUrl cacheData:cacheData isCache:isCache cache:nil cacheKey:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf showError:@"上传文件出错"];
        }];
    }
    
}

#pragma mark 统一处理请求到的数据
/**
 数据处理

 @param responseData 接口返回Data
 @param cacheUrl 拼接完的URL
 @param cacheData 缓存data
 @param isCache 是否缓存
 @param cache cache
 @param cacheKey cacheKey
 */
- (void)dealWithResponseObject:(NSData *)responseData cacheUrl:(NSString *)cacheUrl cacheData:(id)cacheData isCache:(BOOL)isCache cache:(YYCache *)cache cacheKey:(NSString *)cacheKey  //cacheData暂不理会
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;//关闭网络指示器（信号那菊花圈）
    });
    
    NSString * dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //dataString = [self deleteSpecialCodeWithStr:dataString];
    DYLog(@"response\n%@\n",dataString);
    NSData *requestData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (isCache) {//需要缓存,就进行缓存
        [cache setObject:requestData forKey:cacheKey];
    }
    
    if (!isCache || ![cacheData isEqual:requestData]) {//如果不缓存 或 数据不相同,就把网络返回的数据显示
        
        [self returnDataWithRequestData:requestData];
    }
    
    //不管缓不缓存都要显示数据
    //    [self returnDataWithRequestData:requestData];
}

#pragma mark - 根据返回的数据进行统一的格式处理-requestData
- (void)returnDataWithRequestData:(NSData *)requestData
{
    id myResult = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableContainers error:nil];

    //判断是否为字典
    if ([myResult isKindOfClass:[NSDictionary  class]]) {
//        NSDictionary *response = (NSDictionary *)myResult;
        
        //根据返回的接口内容来变
//        NSInteger flag = [[response objectForKey:@"flag"] integerValue];
//
//        if (flag == 0) {
//            NSLog(@"返回Json\n%@\n",response);
//            //        把data层剥掉
//            NSDictionary *dict = [response objectForKey:@"result"];
//
//            [self showSuccess:dict];
//        }
//        if (flag == 1) {
//            [self showError:[response objectForKey:@"result"]];
//            return;
//        }
    }
}


#pragma mark - 拼接请求的网络地址
- (NSString *)urlDictToStringWithUrlStr:(NSString *)urlString WithDict:(NSDictionary *)parameters
{
    if (!parameters) {
        return urlString;
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    //enumerateKeysAndObjectsUsingBlock会遍历dictionary并把里面所有的key和value一组一组的展示给你，每组都会执行这个block 这其实就是传递一个block到另一个方法，在这个例子里它会带着特定参数被反复调用，直到找到一个ENOUGH的key，然后就会通过重新赋值那个BOOL *stop来停止运行，停止遍历同时停止调用block
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //字符串处理
        key = [NSString stringWithFormat:@"%@",key];
        obj = [NSString stringWithFormat:@"%@",obj];
        
        //接收key
        NSString *finalKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //接收值
        NSString *finalValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *part = [NSString stringWithFormat:@"%@=%@",finalKey,finalValue];
        
        [parts addObject:part];
        
    }];
    
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    
    queryString = queryString.length != 0 ? [NSString stringWithFormat:@"?%@",queryString] : @"";
    
    NSString *pathStr = [NSString stringWithFormat:@"%@%@",urlString,queryString];
    
    return pathStr;
}
#pragma mark -- 处理json格式的字符串中的换行符、回车符
- (NSString *)deleteSpecialCodeWithStr:(NSString *)str {
    NSString *string = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    //string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    return string;
}

#pragma mark  网络判断
- (BOOL)requestBeforeJudgeConnect
{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable  = (isReachable && !needsConnection) ? YES : NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    });
    return isNetworkEnable;
}

#pragma mark - 返回数据的调度显示
- (void)showSuccess:(id)response
{
    if (!self.requestDelegate) {
        return;
    }
//selector中使用了不存在的方法名（在使用反射机制通过类名创建类对象的时候会需要的）
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    
    if ([self.requestDelegate respondsToSelector:@selector(Sucess:tag:)]) {
        [self.requestDelegate performSelector:@selector(Sucess:tag:) withObject:response withObject:self.bindTag];
        return;
    }
    
#pragma clang diagnostic pop
}

- (void)showError:(NSString *)error
{
    if (!self.requestDelegate) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    
    if ([self.requestDelegate respondsToSelector:@selector(Failed:tag:)]) {
        [self.requestDelegate performSelector:@selector(Failed:tag:) withObject:error withObject:self.bindTag];
        return;
    }
    
#pragma clang diagnostic pop
}

- (void)dealloc
{
    self.requestDelegate = nil;
}


@end
