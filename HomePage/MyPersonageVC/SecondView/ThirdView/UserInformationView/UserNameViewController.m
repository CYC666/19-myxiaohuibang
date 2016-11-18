//
//  UserNameViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "UserNameViewController.h"

#import "RCDataBaseManager.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface UserNameViewController ()
{
    UITextField *_modifyNameTF;
}
@end

@implementation UserNameViewController

- (id)initWithUserName:(NSString *)userName {
    self = [super init];
    
    if (self) {
        self.userNameStr = userName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"昵称";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    UIImageView *boxImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, My_Screen_Width, 50)];
    boxImage.image = [UIImage imageNamed:@"矩形 2"];
    boxImage.userInteractionEnabled = YES;
    [self.view addSubview:boxImage];
    
    _modifyNameTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, My_Screen_Width-84, 30)];
    _modifyNameTF.placeholder = @"请输入昵称";
    _modifyNameTF.text = self.userNameStr;
    [boxImage addSubview:_modifyNameTF];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(My_Screen_Width-44, 13, 24, 24);
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"icon_closed"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelModifyNameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [boxImage addSubview:cancelBtn];
    
    UIButton *finishButton = [UIButton new];
    finishButton.frame = CGRectMake(0, 0, 80, 30);
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(modifyTheNicknameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *finishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
    self.navigationItem.rightBarButtonItem = finishButtonItem;
}

- (void)cancelModifyNameButtonClick:(UIButton *)button {
    _modifyNameTF.text = @"";
}

- (void)modifyTheNicknameButtonClick:(UIButton *)button {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserInformationModifyURL];
    
    NSDictionary *dic = @{
                          @"id":[USER_D objectForKey:@"user_id"],
                          @"nickname":_modifyNameTF.text,
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
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            [SVProgressHUD showWithStatus:@"正在加载"];
        } else {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KMLog(@"Error:%@",error);
    }];
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
