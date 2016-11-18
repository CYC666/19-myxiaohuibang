//
//  ChangePswViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/10/5.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "ChangePswViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface ChangePswViewController ()
{
    UITextField *_freshTF;
    UITextField *_affirmTF;
}
@end

@implementation ChangePswViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"更改密码";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    UIImageView *boxImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, My_Screen_Width, 50)];
    boxImage1.image = [UIImage imageNamed:@"矩形 2"];
    boxImage1.userInteractionEnabled = YES;
    [self.view addSubview:boxImage1];
    
    UILabel *freshLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
    freshLab.text = @"新密码";
    [boxImage1 addSubview:freshLab];
    
    _freshTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, My_Screen_Width-150, 30)];
    _freshTF.placeholder = @"请设置新密码";
    [boxImage1 addSubview:_freshTF];
    
    UIImageView *boxImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 133, My_Screen_Width, 50)];
    boxImage2.image = [UIImage imageNamed:@"矩形 2"];
    boxImage2.userInteractionEnabled = YES;
    [self.view addSubview:boxImage2];
    
    UILabel *affirmLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
    affirmLab.text = @"确认新密码";
    [boxImage2 addSubview:affirmLab];
    
    _affirmTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, My_Screen_Width-150, 30)];
    _affirmTF.placeholder = @"请确认新密码";
    [boxImage2 addSubview:_affirmTF];
    
    UIButton *finishButton = [UIButton new];
    finishButton.frame = CGRectMake(0, 0, 80, 30);
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(ToCompleteThePasswordChangeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *finishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
    self.navigationItem.rightBarButtonItem = finishButtonItem;
}

- (void)ToCompleteThePasswordChangeButtonClick:(UIButton *)button {
    NSString *str1 = [NSString stringWithFormat:@"%@",_freshTF.text];
    NSString *str2 = [NSString stringWithFormat:@"%@",_affirmTF.text];
    
    BOOL isResult = [str1 compare:str2];
    
    if (isResult == 1) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:@"密码与确认密码不符"];
        return;
    } else {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showWithStatus:@"正在加载"];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserInformationModifyURL];
        
        NSDictionary *dic = @{
                              @"id":[USER_D objectForKey:@"user_id"],
                              @"password":_freshTF.text,
                              };
        KMLog(@"dic:%@",dic);
        
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
                [self.navigationController popViewControllerAnimated:YES];
               
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
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
