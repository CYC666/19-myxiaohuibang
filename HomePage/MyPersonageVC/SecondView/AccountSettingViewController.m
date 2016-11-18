//
//  AccountSettingViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AccountSettingViewController.h"

#import "ChangePswViewController.h"
#import "ChangePhoneViewController.h"

#import "ViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface AccountSettingViewController ()
{
    UITableView *_accountSettingTableView;
}
@end

@implementation AccountSettingViewController

- (id)initWithUserPhone:(NSString *)phone {
    self = [super init];
    
    if (self) {
        self.phoneStr = phone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"账号设置";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _accountSettingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    _accountSettingTableView.delegate = self;
    _accountSettingTableView.dataSource = self;
    _accountSettingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _accountSettingTableView.scrollEnabled = NO;
    [self.view addSubview:_accountSettingTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountSettingCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"accountSettingCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"更改密码";
        } else {
            cell.textLabel.text = @"更换手机号码";
            cell.detailTextLabel.text = self.phoneStr;
        }
    } else {
        UILabel *exitLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, [[UIScreen mainScreen] bounds].size.width, 30)];
        exitLab.text = @"退出登录";
        exitLab.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:exitLab];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"验证原密码" message:@"为了你的数据安全，操作前请先填写原密码" preferredStyle:(UIAlertControllerStyleAlert)];
            
            // 创建文本框
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
                textField.placeholder = @"请输入您的密码";
                textField.secureTextEntry = YES;
            }];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                // 读取文本框的值显示出来
                UITextField *userPsw = alertController.textFields.firstObject;
                KMLog(@"%@",userPsw.text);
                
                NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserVerifyPswURL];
                
                NSDictionary *dic = @{
                                      @"id":[USER_D objectForKey:@"user_id"],
                                      @"password":userPsw.text,
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
                        ChangePswViewController *changePswVC = [[ChangePswViewController alloc] init];
                        [self.navigationController pushViewController:changePswVC animated:YES];
                    } else {
                        [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    KMLog(@"Error:%@",error);
                }];
            }];
            // 注意取消按钮只能添加一个
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
                
            }];
            // 添加按钮 将按钮添加到UIAlertController对象上
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            
            // 将UIAlertController模态出来 相当于UIAlertView show 的方法
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            ChangePhoneViewController *changePhoneVC = [[ChangePhoneViewController alloc] init];
            [self.navigationController pushViewController:changePhoneVC animated:YES];
        }
    } else {
        [USER_D removeObjectForKey:@"user_id"];
        [USER_D synchronize];
        
        [_accountSettingTableView reloadData];
        
        ViewController *loginVC = [[ViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
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
