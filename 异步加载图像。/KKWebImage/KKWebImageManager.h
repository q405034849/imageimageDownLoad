//
//  KKWebImageManager.h
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKWebImageManager : NSObject

+ (instancetype) sharedManager;

- (void)downloadImageWithURLString:(NSString *)urlString completion:(void (^)(UIImage *))completion;

- (void)cancelDownloadWithURLString:(NSString *)urlString;

@end
