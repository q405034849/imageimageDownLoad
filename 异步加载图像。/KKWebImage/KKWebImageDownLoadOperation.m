//
//  KKWebImageDownLoadOperation.m
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "KKWebImageDownLoadOperation.h"

@interface KKWebImageDownLoadOperation()
/**
 * 图像下载 URL 字符串
 */
@property (nonatomic, strong) NSString *urlString;
/**
 * 图像保存的缓存路径
 */
@property (nonatomic, strong) NSString *cachePath;
@end

@implementation KKWebImageDownLoadOperation

+ (instancetype)downloadOperationWithURLString:(NSString *)urlString cachePath:(NSString *)cachePath {
    
    KKWebImageDownLoadOperation *op = [[self alloc] init];
    
    // 保存属性
    op.urlString = urlString;
    op.cachePath = cachePath;
    
    return op;
}

/**
 * 自定义操作的入口方法，如果自定义操作，直接重写这个方法
 *
 * 方法中的代码，在操作被添加到队列后，会自动执行！
 */
- (void)main {
    @autoreleasepool {
        NSLog(@"准备下载图像 %@ %@", [NSThread currentThread], _urlString);
        
        // 0. 模拟休眠
        [NSThread sleepForTimeInterval:1.0];
        
        // 1. 创建 NSURL
        NSURL *url = [NSURL URLWithString:_urlString];
        
        // 在下载之前判断操作是否被取消
        if (self.isCancelled) {
            NSLog(@"下载前被取消");
            return;
        }
        
        // 2. 从 NSURL 获取二进制数据
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 在下载之后判断操作是否被取消
        if (self.isCancelled) {
            NSLog(@"下载后被取消，直接返回，不回调！");
            return;
        }
        
        // 3. 判断二进制数据是否获取成功
        if (data != nil) {
            
            // 4. 将二进制数据转换成图像 - 将 image 回传给调用方！
            // 使用成员变量记录下载完成的图像
            _downloadImage = [UIImage imageWithData:data];
            
            // 5. 保存到 cachePath
            [data writeToFile:_cachePath atomically:YES];
            
            // NSLog(@"保存成功 %@", _cachePath);
        }
    }
}

@end
