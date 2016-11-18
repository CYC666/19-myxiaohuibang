//
//  CLocationController.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/10.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CLocationController.h"

@interface CLocationController ()

@end

@implementation CLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"选取位置";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(sureButtonItemAction:)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    // 注意：改变按钮的颜色，不能用barTintColor
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
}


#pragma mark - 导航栏按钮
- (void)sureButtonItemAction:(UIBarButtonItem *)button {

    // 将位置信息返回

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)backButtonItemAction:(UIBarButtonItem *)button {
    
    // 返回上一层
    [self.navigationController popViewControllerAnimated:YES];
    
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
