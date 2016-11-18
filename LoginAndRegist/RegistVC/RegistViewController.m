//
//  RegistViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "RegistViewController.h"

#import "SecurityCodeViewController.h"
#import "RegistAgreementViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface RegistViewController () <UITextFieldDelegate>

@end

@implementation RegistViewController

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
    
    self.registBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.registBtn.layer.cornerRadius = 5;
    self.registBtn.layer.masksToBounds = YES;
}

- (IBAction)clearUserPhoneNumClick:(UIButton *)sender {
    self.registPhoneNumTF.text = @"";
}

- (IBAction)registButtonClick:(UIButton *)sender {
    if (self.registPhoneNumTF.text.length <= 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空"];
        
        return;
    } else if (![NSString validateMobile:self.registPhoneNumTF.text]) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"手机号格式不对"];
        
        return;
    } else {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XSendCodeURL];
        
        NSDictionary *dic = @{
                              @"mobile":self.registPhoneNumTF.text,
                              };
        NSLog(@"dic:%@",dic);
        //15079126215
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
                SecurityCodeViewController *securityVC = [[SecurityCodeViewController alloc] initWithPhoneNumberStr:self.registPhoneNumTF.text withCodeStr:[[responseObject objectForKey:@"data"] objectForKey:@"code"]];
                [self presentViewController:securityVC animated:YES completion:nil];
            } else {
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
                
                return;
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            KMLog(@"Error:%@",error);
        }];
    }
}

- (IBAction)registrationAgreementClick:(UIButton *)sender {
    RegistAgreementViewController *registAgreementVC = [[RegistAgreementViewController alloc] init];
    [self presentViewController:registAgreementVC animated:YES completion:nil];
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
    [self.registPhoneNumTF resignFirstResponder];
}

- (void)goBackToRegistViewController:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
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
