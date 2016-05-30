//
//  ViewController.m
//  异步加载图像。
//
//  Created by 张玺科 on 16/5/28.
//  Copyright © 2016年 张玺科. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "KKAppInfo.h"
#import "KKAppCell.h"


static NSString *cellId = @"cellId";
@interface ViewController ()<UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSArray <KKAppInfo *> *appList;

@property(nonatomic,strong)NSOperationQueue *downloadQueue;

@property(nonatomic,strong)NSMutableDictionary *imageCache;

@property(nonatomic,strong)NSMutableDictionary *operationCache;

@end

@implementation ViewController

-(void)loadView{

    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    _tableView.rowHeight = 100;
    
    [_tableView registerNib:[UINib nibWithNibName:@"KKAppCell" bundle:nil] forCellReuseIdentifier:cellId];
    
    _tableView.dataSource = self;
    
    self.view = _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _downloadQueue = [[NSOperationQueue alloc]init];
    
    _imageCache = [NSMutableDictionary dictionary];
    
    _operationCache = [NSMutableDictionary dictionary];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_imageCache removeAllObjects];
    
    [_downloadQueue cancelAllOperations];
}

-(void)loadData{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://raw.githubusercontent.com/q405034849/jons/master/apps.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *responseObject) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (NSDictionary * dict in responseObject) {
            KKAppInfo *model = [[KKAppInfo alloc]init];
            
            [model setValuesForKeysWithDictionary:dict];
            
            [arrayM addObject:model];
        }
        self.appList = arrayM;
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败 %@",error);
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _appList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    KKAppCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    KKAppInfo *model = _appList[indexPath.row];
    
    cell.nameLabel.text = model.name;
    cell.DownloadLabel.text = model.download;
    
    UIImage *cacheImage = _imageCache[model.icon];
    if (cacheImage != nil) {
        NSLog(@"返回内存缓存的图像");
        cell.iconView.image = cacheImage;
        
        return cell;
    }
    UIImage *placeholder = [UIImage imageNamed:@"user_default"];
    cell.iconView.image = placeholder;
    
    NSURL *url = [NSURL URLWithString:model.icon];
    
    if (_operationCache[model.icon] != nil) {
        NSLog(@"正在玩命下载 %@ ...",model.name);
        
        return cell;
    }
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片 %@ %zd",model.name,self.downloadQueue.operationCount);
        
        
        if (indexPath.row == 0) {
            
            [NSThread sleepForTimeInterval:1.0];
            
        }
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        UIImage *image = [UIImage imageWithData:data];
        
//        model.image = image;
        //将图像保存到缓冲池
        [self.imageCache setObject:image forKey:model.icon];
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            NSLog(@"队列中的下载操作数：%zd", self.downloadQueue.operationCount);
            
            cell.iconView.image = image;
        }];
    }];
    [_downloadQueue addOperation:op];
    
    [_operationCache setObject:op forKey:model.icon];
    
    return cell;
}
@end
