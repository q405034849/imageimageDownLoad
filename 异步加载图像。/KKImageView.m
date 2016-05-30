//
//  KKImageView.m
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "KKImageView.h"
#import "KKWebImageManager.h"
#import <objc/runtime.h>

const char *cz_URLStringKey = "cz_URLStringKey";
@implementation KKImageView
- (void)cz_setImageWithURLString:(NSString *)urlString {
    
    // 判读地址是否变化
    if (![urlString isEqualToString:self.cz_urlString] && self.cz_urlString != nil) {
        NSLog(@"取消之前的下载操作 %@", self.cz_urlString);
        // 取消之前的下载操作
        [[KKWebImageManager sharedManager] cancelDownloadWithURLString:self.cz_urlString];
    }
    
    // 记录新的地址
    self.cz_urlString = urlString;
    // 在下载之前，将图像设置为 nil
    self.image = nil;
    
    [[KKWebImageManager sharedManager] downloadImageWithURLString:urlString completion:^(UIImage *image) {
        // 下载完成之后，清空之前保存的 urlString
        // 避免再一次进入之后，提示取消之前的下载操作
        self.cz_urlString = nil;
        
        // 下载完成之后，设置图像
        self.image = image;
    }];
}

#pragma mark - 属性的 getter & setter 方法

- (NSString *)cz_urlString {

    return objc_getAssociatedObject(self, cz_URLStringKey);
}

- (void)setCz_urlString:(NSString *)cz_urlString {

    objc_setAssociatedObject(self, cz_URLStringKey, cz_urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
