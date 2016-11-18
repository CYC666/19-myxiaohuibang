//
//  MyQRCodeViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/11/4.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "MyQRCodeViewController.h"

#import <UIImageView+WebCache.h>
#import <AFNetworking.h>

@interface MyQRCodeViewController ()

@end

@implementation MyQRCodeViewController

- (id)initWithUserOrGroupStatus:(NSString *)status {
    self = [super init];
    
    if (self) {
        self.status = status;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    if ([self.status isEqualToString:@"1"]) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = @"我的二维码";
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = title;
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserQRCodeURL];
        
        NSDictionary *dic = @{
                              @"id":[USER_D objectForKey:@"user_id"],
                              };
        KMLog(@"dic:%@",dic);
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        //    session.requestSerializer.timeoutInterval = 5.0;
        [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success:%@",responseObject);
            
            NSLog(@"%@",[MyTool dictionaryToJson:responseObject]);
            
            NSString *msgStr = [responseObject objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"head_img"]]]];
                
                self.headImg.layer.cornerRadius = 5;
                self.headImg.layer.masksToBounds = YES;
                
                self.nameLab.text =  [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"nickname"]];
                NSString *sexStr = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"sex"]];
                
                if ([sexStr isEqualToString:@"0"]) {
                    
                } else if ([sexStr isEqualToString:@"1"]) {
                    self.sexLab.image = [UIImage imageNamed:@"icon_man"];
                } else {
                    self.sexLab.image = [UIImage imageNamed:@"icon_woman"];
                }
                [self.qrCodeImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"qr_code"]]]];
            } else {
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            KMLog(@"Error:%@",error);
        }];
    } else {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = @"群组二维码";
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = title;
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XGroupQRCodeURL];
        
        NSDictionary *dic = @{
                              @"group_id":self.GroupId,
                              };
        NSLog(@"dic:%@",dic);
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        //    session.requestSerializer.timeoutInterval = 5.0;
        [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success:%@",responseObject);
            
            NSLog(@"%@",[MyTool dictionaryToJson:responseObject]);
            
            NSString *msgStr = [responseObject objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"group_img"]]]];

                self.headImg.layer.cornerRadius = 5;
                self.headImg.layer.masksToBounds = YES;
                
                self.nameLab.text =  [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"name"]];
                
                [self.qrCodeImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"qr_code"]]]];
            } else {
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            KMLog(@"Error:%@",error);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
