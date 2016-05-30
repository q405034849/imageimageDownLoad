//
//  KKWebImageDownLoadOperation.h
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKWebImageDownLoadOperation : NSOperation

/**
 * 创建一个下载操作，下载 URLString 指定的图片，下载成功后，写入 cachePath 目录
 */
+ (instancetype)downloadOperationWithURLString:(NSString *)urlString cachePath:(NSString *)cachePath;

/**
 * 下载完成的图像
 */
@property (nonatomic, strong, readonly) UIImage *downloadImage;
@end
