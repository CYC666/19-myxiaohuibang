//
//  ChangePhoneCodeViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/10/5.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "ChangePhoneCodeViewController.h"

@interface ChangePhoneCodeViewController ()

@end

@implementation ChangePhoneCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"更换手机号";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    UIButton *finishButton = [UIButton new];
    finishButton.frame = CGRectMake(0, 0, 80, 30);
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *finishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
    self.navigationItem.rightBarButtonItem = finishButtonItem;
    
    UIImageView *boxImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, My_Screen_Width, 50)];
    boxImage1.image = [UIImage imageNamed:@"矩形 2"];
    boxImage1.userInteractionEnabled = YES;
    [self.view addSubview:boxImage1];
    
    UILabel *phoNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
    phoNameLab.text = @"手机号码";
    phoNameLab.textColor = [UIColor grayColor];
    [boxImage1 addSubview:phoNameLab];
    
    UILabel *phoneLab = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, My_Screen_Width-130, 30)];
    phoneLab.text = @"13456677832";
    phoneLab.textColor = [UIColor grayColor];
    [boxImage1 addSubview:phoneLab];
    
    UIImageView *boxImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 133, My_Screen_Width, 50)];
    boxImage2.image = [UIImage imageNamed:@"矩形 2"];
    boxImage2.userInteractionEnabled = YES;
    [self.view addSubview:boxImage2];
    
    UILabel *affirmLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
    affirmLab.text = @"验证码";
    [boxImage2 addSubview:affirmLab];
    
    UITextField *affirmTF = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, My_Screen_Width-130, 30)];
    affirmTF.placeholder = @"请填写短信验证码";
    [boxImage2 addSubview:affirmTF];
}

- (void)finishButtonClick:(UIButton *)button {
    
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
