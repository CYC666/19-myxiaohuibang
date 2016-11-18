//
//  NotificationSettingViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "NotificationSettingViewController.h"

#import "SetMessageToInformViewController.h"

@interface NotificationSettingViewController ()

@end

@implementation NotificationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"消息通知";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    notificationTableView.delegate = self;
    notificationTableView.dataSource = self;
    notificationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    notificationTableView.scrollEnabled = NO;
    [self.view addSubview:notificationTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 20.0;
    } else {
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 60.0;
    } else {
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 60)];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, My_Screen_Width-20, 50)];
        lab.numberOfLines = 0;
        lab.text = @"如果你要关闭或开启新消息通知，请在iPhone的“设置”-“通知”功能中，找到应用程序“消汇邦”更改。";
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor grayColor];
        [view addSubview:lab];
        
        return view;
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"notificationCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"接受新消息通知";
        cell.detailTextLabel.text = @"已开启";
    } else {
        cell.textLabel.text = @"消息通知免打扰";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        SetMessageToInformViewController *setMessageVC = [[SetMessageToInformViewController alloc] init];
        [self.navigationController pushViewController:setMessageVC animated:YES];
    } else {
        
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
