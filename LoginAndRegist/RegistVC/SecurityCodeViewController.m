//
//  SecurityCodeViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SecurityCodeViewController.h"

#import "PasswordViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface SecurityCodeViewController () <UITextFieldDelegate>
{
    NSString *_againCodeStr;
}
@end

@implementation SecurityCodeViewController

- (id)initWithPhoneNumberStr:(NSString *)phoneStr withCodeStr:(NSString *)codeStr {
    self = [super init];
    
    if (self) {
        self.phoneStr = phoneStr;
        self.codeStr = codeStr;
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
    
    self.verifyCodeBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.verifyCodeBtn.layer.cornerRadius = 5;
    self.verifyCodeBtn.layer.masksToBounds = YES;
    
    self.registPhoneNumLab.text = [NSString stringWithFormat:@"+86 %@",self.phoneStr];
}

- (IBAction)clearUserCodeClick:(UIButton *)sender {
    self.codeTF.text = @"";
}

- (IBAction)verifyCodeButtonClick:(UIButton *)sender {
    NSString *str1 = [NSString stringWithFormat:@"%@",self.codeTF.text];
    
    NSString *str2;
    if (_againCodeStr == nil) {
        str2 = [NSString stringWithFormat:@"%@",self.codeStr];
    } else {
        str2 = _againCodeStr;
    }
//    KMLog(@"str2:%@",str2);
    
    BOOL isResult = [str1 compare:str2];
    if (isResult == 1) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"验证码输入有误"];
        return;
    } else {
        PasswordViewController *passwordVC = [[PasswordViewController alloc] initWithPhoneNumberStr:self.phoneStr];
        [self presentViewController:passwordVC animated:YES completion:nil];
    }
}

- (IBAction)toObtainTheVerificationCodeClick:(UIButton *)sender {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XSendCodeURL];
    
    NSDictionary *dic = @{
                          @"mobile":self.phoneStr,
                          };
    //        NSLog(@"dic:%@",dic);
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    //    session.requestSerializer.timeoutInterval = 5.0;
    [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        KMLog(@"success:%@",responseObject);
        
        KMLog(@"%@",[MyTool dictionaryToJson:responseObject]);
        
        NSString *msgStr = [responseObject objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            KMLog(@"获取验证码成功");
            
            _againCodeStr = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"code"]];
        } else {
//            KMLog(@"123");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KMLog(@"Error:%@",error);
    }];
    
    __block int timeout = 3; //倒计时时间
    __block UIButton *blockBtn = sender;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSString *text = [NSString stringWithFormat:@"重新发送验证码"];
//                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
//                [attributeString setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor],   NSFontAttributeName : [UIFont systemFontOfSize:13]} range:NSMakeRange(8, 4)];
//                [blockBtn setAttributedTitle:attributeString forState:UIControlStateNormal];
                
                [blockBtn setTitle:text forState:UIControlStateNormal];
                blockBtn.userInteractionEnabled = YES;
                
//                KMLog(@"123");
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 120;
            seconds = (seconds == 0 ? 120 : seconds);
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //                NSLog(@"____%@",strTime);
                
                NSString *text = [NSString stringWithFormat:@"还有%@秒",strTime];
//                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
//                [attributeString setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor],   NSFontAttributeName : [UIFont systemFontOfSize:13]} range:NSMakeRange(5, 2)];
//                [blockBtn setAttributedTitle:attributeString forState:UIControlStateNormal];
                [blockBtn setTitle:text forState:UIControlStateNormal];
                blockBtn.userInteractionEnabled = NO;
                
//                KMLog(@"456");
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
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
    [self.codeTF resignFirstResponder];
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
