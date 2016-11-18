//
//  ChangePhoneViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/10/5.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "ChangePhoneViewController.h"

#import "ChangePhoneCodeViewController.h"

@interface ChangePhoneViewController ()

@end

@implementation ChangePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"更换手机号";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    UIButton *nextStepButton = [UIButton new];
    nextStepButton.frame = CGRectMake(0, 0, 80, 30);
    [nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStepButton addTarget:self action:@selector(nextStepButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextStepButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextStepButton];
    self.navigationItem.rightBarButtonItem = nextStepButtonItem;
    
    UIImageView *boxImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, My_Screen_Width, 50)];
    boxImage.image = [UIImage imageNamed:@"矩形 2"];
    boxImage.userInteractionEnabled = YES;
    [self.view addSubview:boxImage];
    
    UILabel *areaCodeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 60, 30)];
    areaCodeLab.text = @"+86";
    areaCodeLab.font = [UIFont systemFontOfSize:19];
    [boxImage addSubview:areaCodeLab];
    
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 1, 60)];
    lineLab.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0];
    [boxImage addSubview:lineLab];
    
    UITextField *modifyNameTF = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, My_Screen_Width-120, 30)];
    modifyNameTF.placeholder = @"请输入新的手机号";
    [boxImage addSubview:modifyNameTF];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(My_Screen_Width-44, 13, 24, 24);
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"icon_closed"] forState:UIControlStateNormal];
    [boxImage addSubview:cancelBtn];
}

- (void)nextStepButtonClick:(UIButton *)button {
    ChangePhoneCodeViewController *changePhoneCodeVC = [[ChangePhoneCodeViewController alloc] init];
    [self.navigationController pushViewController:changePhoneCodeVC animated:YES];
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
