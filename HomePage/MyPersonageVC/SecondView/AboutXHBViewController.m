//
//  AboutXHBViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AboutXHBViewController.h"

@interface AboutXHBViewController ()

@end

@implementation AboutXHBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"关于消汇邦";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *aboutXHBTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    aboutXHBTableView.delegate = self;
    aboutXHBTableView.dataSource = self;
    aboutXHBTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    aboutXHBTableView.scrollEnabled = NO;
    [self.view addSubview:aboutXHBTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 150.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 150)];
    
    UIImageView *logoImg = [[UIImageView alloc] initWithFrame:CGRectMake(My_Screen_Width/2-40, 20, 80, 80)];
    logoImg.image = [UIImage imageNamed:@"logo"];
    [view addSubview:logoImg];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(30, 110, My_Screen_Width-60, 30)];
    lab.text = @"消汇邦   1.0.0";
    lab.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lab];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"systemSettingCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"systemSettingCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"消汇邦简介";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"消汇邦用户协议";
    } else {
        cell.textLabel.text = @"为我们评分";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
