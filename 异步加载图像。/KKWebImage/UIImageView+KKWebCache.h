//
//  UIImageView+KKWebCache.h
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/30.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (KKWebCache)

- (void)cz_setImageWithURLString:(NSString *)urlString;

@property (nonatomic, copy) NSString *cz_urlString;

@end
