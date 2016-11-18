//
//  ToResetPswViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/28.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "ToResetPswViewController.h"

@interface ToResetPswViewController ()

@end

@implementation ToResetPswViewController

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
    
    self.submitBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.submitBtn.layer.cornerRadius = 5;
    self.submitBtn.layer.masksToBounds = YES;
}

- (IBAction)submitToResetThePasswordClick:(UIButton *)sender {
    
}

- (void)goBackToLoginViewController:(UIButton *)button {
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
