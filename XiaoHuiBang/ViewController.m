//
//  ViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "ViewController.h"

#import "LoginViewController.h"
#import "LoginTwoViewController.h"
#import "RegistViewController.h"

#import "PasswordViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    NSString *usrId = [USER_D objectForKey:@"user_id"];
    
    if (usrId != nil) {
        
    } else {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height)];
        //    bgImage.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:144.0/255.0 blue:241.0/255.0 alpha:1.0];
        bgImage.image = [UIImage imageNamed:@"pic_bg"];
        bgImage.userInteractionEnabled = YES;
        [self.view addSubview:bgImage];
        
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        loginBtn.frame = CGRectMake(60, 300, My_Screen_Width-120, 45);
        [loginBtn setBackgroundColor:[UIColor whiteColor]];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        [loginBtn addTarget:self action:@selector(toLoginViewControllerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        loginBtn.layer.cornerRadius = 5;
        loginBtn.layer.masksToBounds = YES;
        [bgImage addSubview:loginBtn];
        
        UIButton *registBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        registBtn.frame = CGRectMake(60, 365, My_Screen_Width-120, 45);
        [registBtn setBackgroundColor:[UIColor colorWithRed:253.0/255.0 green:152.0/255.0 blue:9.0/255.0 alpha:1.0]];
        [registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registBtn setTitle:@"注册" forState:UIControlStateNormal];
        registBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        [registBtn addTarget:self action:@selector(toRegidtViewControllerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        registBtn.layer.cornerRadius = 5;
        registBtn.layer.masksToBounds = YES;
        [bgImage addSubview:registBtn];
    }
}

- (void)toLoginViewControllerButtonClick:(UIButton *)button {
//    [MyTool toMainVCRequest];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)toRegidtViewControllerButtonClick:(UIButton *)button {
    RegistViewController *registVC = [[RegistViewController alloc] init];
    [self presentViewController:registVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
