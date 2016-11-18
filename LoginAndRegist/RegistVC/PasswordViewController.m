//
//  PasswordViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "PasswordViewController.h"

#import "SetHeadNameViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface PasswordViewController ()

@end

@implementation PasswordViewController

- (id)initWithPhoneNumberStr:(NSString *)phoneStr {
    self = [super init];
    
    if (self) {
        self.phoneStr = phoneStr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(10, 25, 40, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    //    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(goBackToRegistViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    self.commitBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
}

- (IBAction)commitPswClick:(UIButton *)sender {
    NSString *str1 = [NSString stringWithFormat:@"%@",self.pswTF.text];
    NSString *str2 = [NSString stringWithFormat:@"%@",self.freshPswTF.text];
    
    BOOL isResult = [str1 compare:str2];
    
    if (self.pswTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
        return;
    } else if (self.freshPswTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"确认密码不能为空"];
        return;
    } else if (isResult == 1) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"密码与确认密码不符"];
        return;
    } else {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XRegistURL];
        
        NSDictionary *dic = @{
                              @"password":self.pswTF.text,
                              @"repassword":self.freshPswTF.text,
                              @"mobile":self.phoneStr,
                              };
        NSLog(@"dic:%@",dic);
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        //    session.requestSerializer.timeoutInterval = 5.0;
        [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            KMLog(@"success:%@",responseObject);
            
            NSLog(@"%@",[MyTool dictionaryToJson:responseObject]);
            
            NSString *msgStr = [responseObject objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                KMLog(@"注册成功");
                
                NSDictionary *loginDataDic = [responseObject objectForKey:@"data"];
                NSString *keyStr = [loginDataDic objectForKey:@"id"];
                
                [USER_D setObject:keyStr forKey:@"user_id"];
                [USER_D setObject:[loginDataDic objectForKey:@"token"] forKey:@"key_token"];
                
                //  同步存储到磁盘中，
                [USER_D synchronize];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您已成功注册为消汇邦的会员\n补充个人信息能获得奖励呦！" preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"现在就去" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                    SetHeadNameViewController *setheadVC = [[SetHeadNameViewController alloc] init];
                    [self presentViewController:setheadVC animated:YES completion:nil];
                }];
                // 注意取消按钮只能添加一个
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"以后再说" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
                    NSLog(@"直接登录，并进入主界面");
                    
                    //登录融云服务器
                    [[RCIM sharedRCIM] connectWithToken:[loginDataDic objectForKey:@"token"]
                                                success:^(NSString *userId) {
                                                    NSLog(@"%@",userId);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [MyTool toMainVCRequest];
                                                    });
                                                }
                                                  error:^(RCConnectErrorCode status) {
                                                      NSLog(@"RCConnectErrorCode is %ld", (long)status);
                                                  }
                                         tokenIncorrect:^{
                                             NSLog(@"IncorrectToken");
                                         }];
                }];
                // 添加按钮 将按钮添加到UIAlertController对象上
                [alertController addAction:okAction];
                [alertController addAction:cancelAction];
                
                // 将UIAlertController模态出来 相当于UIAlertView show 的方法
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSLog(@"123");
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            
            KMLog(@"Error:%@",error);
        }];
        
    }
}

- (void)goBackToRegistViewController:(UIButton *)button {
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self respondsToSelector:@selector(presentingViewController)]){
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.parentViewController.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.pswTF resignFirstResponder];
    [self.freshPswTF resignFirstResponder];
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
