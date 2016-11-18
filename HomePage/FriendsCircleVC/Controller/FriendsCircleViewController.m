//
//  FriendsCircleViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/11/4.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "FriendsCircleViewController.h"
#import "SendMomentsController.h"
#import "FromCameraController.h"
#import "SeeModel.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import "SeeLayout.h"
#import "CRefresh.h"
#import <UIImageView+WebCache.h>
#import "CNetTool.h"




#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define reloadTableViewDataNotification @"reloadTableViewDataNotification"  // 刷新表视图通知



@interface FriendsCircleViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *seeModelList;      // 储存动态的数组
@property (assign, nonatomic) NSInteger dataTag;                 // 标志上拉加载下拉刷新
@property (assign, nonatomic) NSInteger dataPage;                // 记录加载页数

@end

@implementation FriendsCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 默认加载页数为1
    _dataTag = 1;
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"邦友圈";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    // 发布动态按钮
    UIBarButtonItem *sendMomentsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_camera"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(sendMomentsAction:)];
    [self.navigationItem setRightBarButtonItem:sendMomentsButton];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // 加载动态数据
    [self reloadData];
    
    
    


    
}

#pragma mark - 懒加载
- (SeeTableView *)seeTableView {

    if (_seeTableView == nil) {
        _seeTableView = [[SeeTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        [self.view addSubview:_seeTableView];
    }
    return _seeTableView;

}
- (NSMutableArray *)seeModelList {

    if (_seeModelList == nil) {
        _seeModelList = [NSMutableArray array];
    }
    return _seeModelList;

}




#pragma mark - 发布动态
- (void)sendMomentsAction:(UIBarButtonItem *)button {
    
    UIView *virtualView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    virtualView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    [self.view.window addSubview:virtualView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [virtualView addGestureRecognizer:tap];
    

    // 创建选项view，提供功能选着
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight , kScreenWidth, kScreenHeight*.3)];
    alertView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
    alertView.tag = 1001;
    [virtualView addSubview:alertView];
    
    [UIView animateWithDuration:.35
                     animations:^{
                         alertView.transform = CGAffineTransformMakeTranslation(0, -kScreenHeight*.3);
                     }];
    
    float buttonHeight = (kScreenHeight*.3 - 10)/4.0;
    NSArray *titleArr = @[@"记录生活", @"视频/拍照", @"从手机相册选择", @"取消"];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.tag = 1500 + i;
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
                     forState:UIControlStateNormal];
        if (i == 0) {
            button.frame = CGRectMake(0, 0, kScreenWidth, buttonHeight);
        } else if (i == 1) {
            button.frame = CGRectMake(0, buttonHeight + 1, kScreenWidth, buttonHeight);
        } else if (i == 2) {
            button.frame = CGRectMake(0, buttonHeight*2 + 2, kScreenWidth, buttonHeight);
        } else {
            button.frame = CGRectMake(0, kScreenHeight*.3 - buttonHeight, kScreenWidth, buttonHeight);
        }
        [alertView addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }

}

// alert背景点击手势，移除alert
- (void)tapAction:(UITapGestureRecognizer *)tap {

    [UIView animateWithDuration:.35
                     animations:^{
                         [tap.view viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.3);
                     } completion:^(BOOL finished) {
                         [tap.view removeFromSuperview];
                     }];
}

// alert按钮响应
- (void)buttonAction:(UIButton *)button {

    NSInteger buttonTag = button.tag - 1500;
    if (buttonTag == 0) {
        // push到编辑界面
        SendMomentsController *momentsController = [[SendMomentsController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:momentsController];
        nav.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
        [self presentViewController:nav animated:YES completion:nil];
        
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.3);
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];
        
    } else if (buttonTag == 1) {
        // 通过摄像头
        [self presentViewController:[[FromCameraController alloc] init]
                           animated:YES
                         completion:nil];
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.3);
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];

    } else if (buttonTag == 2) {
        // 从手机相册获取
        [self sendFromSystemPicture];
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.3);
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];
    } else {
        // 移除alert
        [UIView animateWithDuration:.35
                         animations:^{
                             [button.superview.superview viewWithTag:1001].transform = CGAffineTransformMakeTranslation(0, kScreenHeight*.3);
                         } completion:^(BOOL finished) {
                             [button.superview.superview removeFromSuperview];
                         }];
    }

}

// 颜色转换成image
-(UIImage *)createImageWithColor:(UIColor*) color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 创建内容视图
- (void)_createContent {
    
    _dataPage = 1;
    _dataTag = 0;

    // 获取动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadAboutWithParameters:params
                              success:^(id response) {
                                  // 查看是否有动态
                                  NSDictionary *dic = response;
                                  if ([dic[@"msg"]  isEqual: @1]) {
                                      // 在支线程处理数据,加载数据
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          [self loadData:response];
                                      });
                                  } else {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"没有动态"];
                                  }
                              } failure:^(NSError *err) {
                                  [SVProgressHUD dismiss];
                                  [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                              }];
    
   

}


#pragma mark - 首次加载或下拉刷新
- (void)reloadData {
    
    _dataPage = 1;
    _dataTag = 0;
    
    // 获取动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadAboutWithParameters:params
                              success:^(id response) {
                                  // 查看是否有动态
                                  NSDictionary *dic = response;
                                  if ([dic[@"msg"]  isEqual: @1]) {
                                      // 在支线程处理数据,加载数据
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          [self loadData:response];
                                      });
                                  } else {
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"没有动态"];
                                  }
                              } failure:^(NSError *err) {
                                  [SVProgressHUD dismiss];
                                  [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                              }];
    
    
}

#pragma mark - 上拉加载
- (void)downloadData {
    
    _dataPage += 1;
    _dataTag = 1;
    
    // 获取动态
    NSDictionary *params = @{@"user_id" : [USER_D objectForKey:@"user_id"],
                             @"page" : [NSString stringWithFormat:@"%ld", _dataPage]
                             };
    
    [CNetTool loadAboutWithParameters:params
                              success:^(id response) {
                                  // 查看是否有动态
                                  NSDictionary *dic = response;
                                  if ([dic[@"msg"]  isEqual: @1]) {
                                      // 在支线程处理数据,加载数据
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          [self loadData:response];
                                      });
                                  } else {
                                      
                                      // 如果没有动态就结束加载，不然会一直加载，导致刷新过后不能加载
                                      [self.seeTableView.infiniteScrollingView stopAnimating];
                                      
                                      [SVProgressHUD dismiss];
                                      [SVProgressHUD showSuccessWithStatus:@"没有动态"];
                                  }
                              } failure:^(NSError *err) {
                                  [SVProgressHUD dismiss];
                                  [SVProgressHUD showSuccessWithStatus:@"请求失败"];
                              }];
    
    
    
}

#pragma mark - 从手机相册选择
- (void)sendFromSystemPicture {

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma mark - imagePicker代理方法
//已经选好照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    //判断资源的来源 相册||摄像头
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        //取出照片
        // UIImage *image = info[UIImagePickerControllerOriginalImage];
        // 返回照片
        
    }
    //关闭,返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 处理动态数据
- (void)loadData:(id)data {
    
    // 如果是第一次加载数据，或者刷新数据
    if (_dataTag == 0) {
        [self.seeModelList removeAllObjects];
    }
    
    NSArray *dataArr = data[@"data"];
    NSMutableArray *seeTempArr = [NSMutableArray array];
    for (NSDictionary *dic in dataArr) {
        SeeModel *seeModel = [[SeeModel alloc] init];
        seeModel.about_id = dic[@"id"];
        seeModel.user_id = dic[@"user_id"];
        seeModel.nickname = dic[@"nickname"];
        seeModel.head_img = dic[@"head_img"];
        seeModel.content = dic[@"content"];
        seeModel.about_img = dic[@"about_img"];
        seeModel.create_time = dic[@"create_time"];
        
        NSMutableArray *praiseTempArr = [NSMutableArray array];
        for (NSDictionary *praiseDic in dic[@"praise"]) {
            PraiseModel *praiseModel = [[PraiseModel alloc] init];
            praiseModel.nickname = praiseDic[@"nickname"];
            praiseModel.user_id = praiseDic[@"user_id"];
            [praiseTempArr addObject:praiseModel];
        }
        seeModel.praise = praiseTempArr;
        
        NSMutableArray *aveluateTempArr = [NSMutableArray array];
        for (NSDictionary *aveluateDic in dic[@"aveluate"]) {
            AveluateModel *aveluateModel = [[AveluateModel alloc] init];
            aveluateModel.nickname = aveluateDic[@"nickname"];
            aveluateModel.user_id = aveluateDic[@"user_id"];
            aveluateModel.about_content = aveluateDic[@"about_content"];
            aveluateModel.eva_id = aveluateDic[@"eva_id"];
            [aveluateTempArr addObject:aveluateModel];
        }
        seeModel.aveluate = aveluateTempArr;
        
        // 将包含了动态数据和布局对象的模型存到数组中
        SeeLayout *seeLayout = [[SeeLayout alloc] init];
        seeLayout.seeModel = seeModel;
        [seeTempArr addObject:seeLayout];
        
      
    }
    
    
    // 返回主线程，刷新表视图
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // 以下内容涉及到UI，多疑要放到主线程，不然界面的UI很难刷新出来
        
        // 将接受到的数据储存到全局变量
        if (_dataTag == 0) {    // 第一次加载或刷新
            self.seeModelList = seeTempArr;
            self.seeTableView.seeLayoutList = self.seeModelList;
            // self.seeTableView.seeLayoutList = seeTempArr;
            // 结束刷新
            [self.seeTableView.pullToRefreshView stopAnimating];
        } else if (_dataTag == 1) {     // 加载
            [self.seeModelList addObjectsFromArray:seeTempArr];
            self.seeTableView.seeLayoutList = self.seeModelList;
            // [self.seeTableView.seeLayoutList addObjectsFromArray:seeTempArr];
            // 结束加载
            [self.seeTableView.infiniteScrollingView stopAnimating];
        }
        
        [self.seeTableView reloadData];
        
        // 创建一个若引用的self在block中调用方法，防止循环引用
        __weak FriendsCircleViewController *weakSelf = self;
        [self.seeTableView addPullDownRefreshBlock:^{
            @synchronized (weakSelf) {
                // 下拉刷新
                [weakSelf reloadData];
            }
            
        }];
        
        [self.seeTableView addInfiniteScrollingWithActionHandler:^{
            @synchronized (weakSelf) {
                // 上拉加载
                [weakSelf downloadData];
            }
        }];
        
    });
  

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





























/*
 
被丢弃的代码
 
 // 加载头像
 //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"head_img"]]]];
 //[self.imageArr addObject:image];
 
 // 此方法不能调起get方法，imageArr没有初始化，不能使用，添加不了image
 // [_imageArr addObject:image];
 
 // 当加载到图片，则添加到数组中，如果加载不到图片，给个0
 //if (![dic[@"about_img"] isEqualToString:@"0"]) {
 //    UIImage *aboutImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"about_img"]]]];
 //    [self.AboutImageArr addObject:aboutImage];
 //} else {
 //    [self.AboutImageArr addObject:@"0"];
 //}
 
 // 加载自己的头像
 //self.seeTableView.selfHeadImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];

 //            [self.seeTableView.headImgArr addObjectsFromArray:_imageArr];
 //            [self.seeTableView.aboutImgArr addObjectsFromArray:_AboutImageArr];

 
 // 获取URL对应的头像,自己的头像
 //NSURL *imageUrl = [NSURL URLWithString:[USER_D objectForKey:@"head_img"]];
 //            self.seeTableView.headImgArr = _imageArr;
 //            self.seeTableView.aboutImgArr = _AboutImageArr;

 @property (strong, nonatomic) NSMutableArray *imageArr;          // 缓存头像的数组
 
 - (NSMutableArray *)imageArr {
 
 if (_imageArr == nil) {
 _imageArr = [NSMutableArray array];
 }
 return _imageArr;
 
 }
 
 self.imageArr = nil;
 
 @property (strong, nonatomic) NSMutableArray *AboutImageArr;     // 缓存动态图像的数组
 
 - (NSMutableArray *)AboutImageArr {
 
 if (_AboutImageArr == nil) {
 _AboutImageArr = [NSMutableArray array];
 }
 return _AboutImageArr;
 
 }
 
 self.AboutImageArr = nil;
 
 //    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
 //    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 //    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 //    [session POST:urlStr
 //       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 //
 //       } progress:^(NSProgress * _Nonnull uploadProgress) {
 //
 //       } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 //           // 查看是否有动态
 //           NSDictionary *dic = responseObject;
 //           if ([dic[@"msg"]  isEqual: @1]) {
 //               // 在支线程处理数据,加载数据
 //               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 //                   [self loadData:responseObject];
 //               });
 //           } else {
 //               [SVProgressHUD dismiss];
 //               [SVProgressHUD showSuccessWithStatus:@"没有动态"];
 //           }
 //
 //       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 //           // 请求数据失败
 //
 //       }];
 
 NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
 
 
 AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 [session POST:urlStr
 parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 
 } progress:^(NSProgress * _Nonnull uploadProgress) {
 
 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 // 查看是否有动态
 NSDictionary *dic = responseObject;
 if ([dic[@"msg"]  isEqual: @1]) {
 // 在支线程处理数据,加载数据
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self loadData:responseObject];
 });
 } else {
 
 // 如果没有动态就结束加载，不然会一直加载，导致刷新过后不能加载
 [self.seeTableView.infiniteScrollingView stopAnimating];
 
 [SVProgressHUD dismiss];
 [SVProgressHUD showSuccessWithStatus:@"没有动态"];
 }
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 // 请求数据失败
 
 }];
 
 NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
 AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
 session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
 [session POST:urlStr
 parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 
 } progress:^(NSProgress * _Nonnull uploadProgress) {
 
 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 
 // 查看是否有动态
 NSDictionary *dic = responseObject;
 if ([dic[@"msg"]  isEqual: @1]) {
 // 在支线程处理数据,加载数据
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self loadData:responseObject];
 });
 } else {
 [SVProgressHUD dismiss];
 [SVProgressHUD showSuccessWithStatus:@"没有动态"];
 }
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 // 请求数据失败
 
 }];
 
 
 
*/








@end
