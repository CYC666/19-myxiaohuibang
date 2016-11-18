//
//  LoginViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


#import "LoginViewController.h"

#import "ForgetViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <RongIMKit/RongIMKit.h>

@interface LoginViewController () <UITextFieldDelegate>
{
    NSString                    *_goodsCollectionStr;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(10, 25, 40, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    //    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(goBackToLoginViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    self.loginBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;
    
    [self.cancelPswBtn setBackgroundImage:[UIImage imageNamed:@"icon_password_show.png"] forState:UIControlStateNormal];
}

- (IBAction)clearUserPhoneNumberClick:(UIButton *)sender {
    self.accountNumTF.text = @"";
}

- (IBAction)pswVisibleChooseClick:(UIButton *)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if ([_goodsCollectionStr isEqualToString:@"0"]) {
        [self.cancelPswBtn setBackgroundImage:[UIImage imageNamed:@"icon_password_show.png"] forState:UIControlStateNormal];
        self.pswTF.secureTextEntry = YES;
        _goodsCollectionStr = @"1";
    } else {
        [self.cancelPswBtn setBackgroundImage:[UIImage imageNamed:@"icon_password_hide.png"] forState:UIControlStateSelected];
        self.pswTF.secureTextEntry = NO;
        _goodsCollectionStr = @"0";
    }
}

- (IBAction)userLoginButtonClick:(UIButton *)sender {
    [_pswTF resignFirstResponder];
    [_accountNumTF resignFirstResponder];
    
    RCNetworkStatus stauts =
    [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    
    if (RC_NotReachable == stauts) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"当前网络不可用，请检查！"];
        
        return;
    } else {
        
    }
    if (self.accountNumTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空"];
        
        return;
    } else if (![NSString validateMobile:self.accountNumTF.text]) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"手机号格式不对"];
        
        return;
    } else if (self.pswTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
        
        return;
    } else {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showWithStatus:@"正在加载"];
        
        [AFHttpTool loginWithPhone:self.accountNumTF.text password:self.pswTF.text success:^(id response) {
            NSLog(@"success:%@",response);
            
            //            NSLog(@"success:%@",responseObject);
            
            KMLog(@"%@",[MyTool dictionaryToJson:response]);
            
            NSString *msgStr = [response objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                //  存储登录用户信息到本地
                NSDictionary *loginDataDic = [response objectForKey:@"data"];
                
                NSString *idStr = [loginDataDic objectForKey:@"id"];
                NSString *nameStr = [loginDataDic objectForKey:@"name"];
                NSString *nicknameStr = [loginDataDic objectForKey:@"nickname"];
                NSString *headImgStr = [loginDataDic objectForKey:@"head_img"];
//                NSString *pswStr = [loginDataDic objectForKey:<#(nonnull id)#>];
                
                [USER_D setObject:idStr forKey:@"user_id"];
                [USER_D setObject:nameStr forKey:@"name"];
                [USER_D setObject:nicknameStr forKey:@"nickname"];
                [USER_D setObject:headImgStr forKey:@"head_img"];
                
                [USER_D setObject:[loginDataDic objectForKey:@"token"] forKey:@"key_token"];
                
                //  同步存储到磁盘中，
                [USER_D synchronize];
                
                //登录融云服务器
                [[RCIM sharedRCIM] connectWithToken:[loginDataDic objectForKey:@"token"]
                                            success:^(NSString *userId) {
                                                NSLog(@"%@",userId);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [MyTool toMainVCRequest];
                                                    
                                                    [SVProgressHUD dismiss];
                                                });
                                            }
                                              error:^(RCConnectErrorCode status) {
                                                  NSLog(@"RCConnectErrorCode is %ld", (long)status);
                                              }
                                     tokenIncorrect:^{
                                         NSLog(@"IncorrectToken");
                                     }];
            } else {
                [SVProgressHUD showErrorWithStatus:[response objectForKey:@"data"]];
            }
        } failure:^(NSError *error) {
            NSLog(@"error:%@",error);
        }];
    }
}

- (IBAction)forgetPswButtonClick:(UIButton *)sender {
    ForgetViewController *forgetVC = [[ForgetViewController alloc] init];
    [self presentViewController:forgetVC animated:YES completion:nil];
}

- (void)goBackToLoginViewController:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [_pswTF resignFirstResponder];
    [_accountNumTF resignFirstResponder];
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
