//
//  KKAppInfo.h
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/28.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKAppInfo : NSObject

@property(nonatomic,copy)NSString *name;

@property(nonatomic,copy)NSString *download;

@property(nonatomic,copy)NSString *icon;

@property(nonatomic,strong)UIImage *image;

@end
