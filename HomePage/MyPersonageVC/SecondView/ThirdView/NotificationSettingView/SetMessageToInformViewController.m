//
//  SetMessageToInformViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/10/6.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SetMessageToInformViewController.h"

@interface SetMessageToInformViewController ()
{
    NSIndexPath         *_currentIndexPath;
    NSIndexPath         *_previousIndexPath;
    
    NSString            *_tempAddressStr;
}
@end

@implementation SetMessageToInformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"消息免打扰";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *setMessageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    setMessageTableView.delegate = self;
    setMessageTableView.dataSource = self;
    setMessageTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    setMessageTableView.scrollEnabled = NO;
    [self.view addSubview:setMessageTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 90)];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, My_Screen_Width-20, 80)];
        lab.numberOfLines = 0;
        lab.text = @"设置为“开启”，消汇邦收到信息或通知后，手机不会震动与发出提示音\n\n设置为“只在夜间开启”，则只在22:00到08:00间生效";
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor grayColor];
        [view addSubview:lab];
        
        return view;
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setMessageCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setMessageCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"开启";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"只在夜间开启";
    } else {
        cell.textLabel.text = @"关闭";
    }
    if (!_previousIndexPath) {
        _previousIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _currentIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentIndexPath = indexPath;
    
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = (_previousIndexPath != nil) ? [_previousIndexPath row] : -1;
    
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:
                                    indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:
                                    _previousIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        _previousIndexPath = [indexPath copy];//一定要这么写，要不报错
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
