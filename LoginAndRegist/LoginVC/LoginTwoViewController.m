//
//  LoginTwoViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/27.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "LoginTwoViewController.h"

#import "LoginViewController.h"
#import "RegistViewController.h"

@interface LoginTwoViewController ()

@end

@implementation LoginTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(10, 25, 40, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    //    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(goBackToLoginTwoViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    self.headImg.image = [UIImage imageNamed:@"tx1"];
    self.headImg.layer.cornerRadius = 45;
    self.headImg.layer.masksToBounds = YES;
    
    self.loginBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;
}

- (IBAction)pswVisibleChooseButtonClick:(UIButton *)sender {
    
}

- (IBAction)userLoginToHomepageVCClick:(UIButton *)sender {
    
}

- (IBAction)forgetPswButtonClick:(UIButton *)sender {
    RegistViewController *registVC = [[RegistViewController alloc] init];
    [self presentViewController:registVC animated:YES completion:nil];
}

- (IBAction)moreButtonClick:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *Sure = [UIAlertAction actionWithTitle:@"切换账号"style:(UIAlertActionStyleDefault)handler:^(UIAlertAction *action) {
        //添加确定的点击事件  点击事件写在这里
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
    }];
    UIAlertAction *alert = [UIAlertAction actionWithTitle:@"注册"style:(UIAlertActionStyleDefault)handler:^(UIAlertAction *action) {
        //添加确定的点击事件  点击事件写在这里
        RegistViewController *registVC = [[RegistViewController alloc] init];
        [self presentViewController:registVC animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"style:(UIAlertActionStyleCancel)handler:^(UIAlertAction *action) {
        //添加取消的点击事件
    }];
    [alertController addAction:Sure];
    [alertController addAction:alert];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)goBackToLoginTwoViewController:(UIButton *)button {
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
