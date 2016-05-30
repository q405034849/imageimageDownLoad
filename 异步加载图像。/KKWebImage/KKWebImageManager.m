//
//  KKWebImageManager.m
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "KKWebImageManager.h"
#import "CZAdditions.h"
#import "KKWebImageDownLoadOperation.h"

@interface KKWebImageManager()

/**
 * 操作缓存
 */
@property (nonatomic, strong) NSMutableDictionary *operationCache;

/**
 * 图像缓存
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;

/**
 * 下载队列
 */
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end


@implementation KKWebImageManager

#pragma mark - 构造函数
+ (instancetype)sharedManager {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化队列和缓存
        _operationCache = [NSMutableDictionary dictionary];
        _imageCache = [NSMutableDictionary dictionary];
        
        _downloadQueue = [[NSOperationQueue alloc] init];
        
        // 注册内存警告通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

/**
 * 永远没有机会执行到！注销通知是一个好习惯！
 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 内存警告方法
- (void)memoryWarning {
    
    // 1. 清理图像缓存
    [_imageCache removeAllObjects];
    
    // 2. 取消没有完成的下载操作
    [_downloadQueue cancelAllOperations];
    
    // 3. 清空操作缓冲池
    [_operationCache removeAllObjects];
}

#pragma mark - 取消操作
- (void)cancelDownloadWithURLString:(NSString *)urlString {
    
    // 1. 从操作缓冲池去处操作
    KKWebImageDownLoadOperation *op = _operationCache[urlString];
    
    // 2. 给操作发送 cancel 消息，如果没有拿到 op 会怎样？什么也不会发生
    [op cancel];
}

#pragma mark - 下载方法
/**
 * 异步方法的执行，不能通过方法的返回值返回结果，最常用的方式就是通过 block 的参数执行回调！
 */
- (void)downloadImageWithURLString:(NSString *)urlString completion:(void (^)(UIImage *))completion {
    
    // 0. 断言
    NSAssert(completion != nil, @"必须传入完成回调！");
    
    // 1. 内存缓存（KEY urlString / value image）
    UIImage *cacheImage = _imageCache[urlString];
    
    if (cacheImage != nil) {
        NSLog(@"返回内存缓存");
        
        completion(cacheImage);
        
        return;
    }
    
    // 2. 沙盒缓存 - 从沙盒的缓存路径中读取图像
    NSString *cachePath = [self cachePathWithURLString:urlString];
    cacheImage = [UIImage imageWithContentsOfFile:cachePath];
    
    if (cacheImage != nil) {
        NSLog(@"返回沙盒缓存");
        
        // 1> 设置内存缓存
        [_imageCache setObject:cacheImage forKey:urlString];
        
        // 2> 完成回调
        completion(cacheImage);
        
        return;
    }
    
    // 3. 下载操作过长，需要通过操作缓存避免重复下载
    if (_operationCache[urlString] != nil) {
        NSLog(@"%@ 正在下载中，稍安勿躁...", urlString);
        
        return;
    }
    
    // NSLog(@"准备下载图像");
    // 4. 创建下载单张图像的操作
    KKWebImageDownLoadOperation *op = [KKWebImageDownLoadOperation downloadOperationWithURLString:urlString cachePath:cachePath];
    
    // 设置操作的完成回调
    __weak KKWebImageDownLoadOperation *weakOperation = op;
    [op setCompletionBlock:^{
        NSLog(@"下载操作完成 - %@ %@", [NSThread currentThread], weakOperation.downloadImage);
        
        // 1> 通过属性获取下载的图像
        UIImage *image = weakOperation.downloadImage;
        
        // 2> 将图像添加到缓冲池
        if (image != nil) {
            [_imageCache setObject:image forKey:urlString];
        }
        
        // 3> 将操作从缓冲池中删除
        [_operationCache removeObjectForKey:urlString];
        
        // 4> 主线程更新 UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 执行完成回调
            completion(image);
        }];
    }];
    
    // 5. 添加到下载队列
    [_downloadQueue addOperation:op];
    
    // 6. 添加到下载操作缓冲池！
    [_operationCache setObject:op forKey:urlString];
}

- (NSString *)cachePathWithURLString:(NSString *)urlString {
    
    // 1. 取缓存目录
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    // 2. 图像 url 的 md5
    NSString *imageName = [urlString cz_md5String];
    
    // 3. 返回拼接的路径
    return [cacheDir stringByAppendingPathComponent:imageName];
}


@end
