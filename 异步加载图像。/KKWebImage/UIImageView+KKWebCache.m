//
//  UIImageView+KKWebCache.m
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "UIImageView+KKWebCache.h"
#import "KKWebImageManager.h"

@implementation UIImageView (KKWebCache)

- (void)cz_setImageWithURLString:(NSString *)urlString {
    
    [[KKWebImageManager sharedManager] downloadImageWithURLString:urlString completion:^(UIImage *image) {
        // 下载完成之后，设置图像
        self.image = image;
    }];
}

#pragma mark - 属性的 getter & setter 方法
- (NSString *)cz_urlString {
    return @"呵呵";
}

- (void)setCz_urlString:(NSString *)cz_urlString {
    
}

@end
