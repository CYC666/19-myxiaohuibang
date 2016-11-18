//
//  PersonageViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/28.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "PersonageViewController.h"

#import "PersonageTableViewCell.h"

#import "UserInformationViewController.h"
#import "AccountSettingViewController.h"
#import "NotificationSettingViewController.h"
#import "SystemSettingViewController.h"
#import "AboutXHBViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface PersonageViewController ()
{
    NSString *_userHeadImg;
    NSString *_userNmaeStr;
    NSString *_userSexStr;
    NSString *_userMobileStr;
    
    NSString *_userQRcodeStr;
    
    UITableView *_myPersonageTableView;
}
@end

@implementation PersonageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self requestUserMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"我的";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    _myPersonageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    _myPersonageTableView.delegate = self;
    _myPersonageTableView.dataSource = self;
    _myPersonageTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_myPersonageTableView];
    
    [self requestUserMessage];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,@"user/user_code"];
    
    NSDictionary *dic = @{
                          @"id":[USER_D objectForKey:@"user_id"],
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
            _userQRcodeStr = [responseObject objectForKey:@"data"];
            
            [_myPersonageTableView reloadData];
        } else {
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KMLog(@"Error:%@",error);
    }];
}

- (void)requestUserMessage {
    [AFHttpTool getUserInfo:[USER_D objectForKey:@"user_id"] success:^(id response) {
        KMLog(@"success:%@",response);
        
        KMLog(@"%@",[MyTool dictionaryToJson:response]);
        
        NSString *msgStr = [response objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            _userHeadImg = [[response objectForKey:@"data"] objectForKey:@"head_img"];
            _userNmaeStr = [[response objectForKey:@"data"] objectForKey:@"nickname"];
            _userSexStr = [[response objectForKey:@"data"] objectForKey:@"sex"];
            _userMobileStr = [[response objectForKey:@"data"] objectForKey:@"mobile"];
            
            [_myPersonageTableView reloadData];
        } else {
            
        }
    } failure:^(NSError *err) {
        KMLog(@"Error:%@",err);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return 0.01;
//    }
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80.0;
    }
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PersonageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myPersonageCell"];
        
        if (!cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PersonageTableViewCell" owner:nil options:nil];
            //        判断类型
            if ([array[0] isKindOfClass:[PersonageTableViewCell class]]) {
                cell = (PersonageTableViewCell *)array[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.userHeadImg.layer.cornerRadius = 5;
        cell.userHeadImg.layer.masksToBounds = YES;
        
        [cell.userHeadImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_userHeadImg]]];
        NSString *userPhoneStr = [NSString jsonUtils:_userMobileStr];
        cell.userIDLab.text = [NSString stringWithFormat:@"ID:%@",userPhoneStr];
        cell.userNameLab.text = [NSString jsonUtils:_userNmaeStr];
        
        UIButton *codeBtn = [UIButton new];
        codeBtn.frame = CGRectMake(My_Screen_Width-56, 28, 22, 22);
        [codeBtn setBackgroundImage:[UIImage imageNamed:@"图层-2"] forState:UIControlStateNormal];
        [cell addSubview:codeBtn];
        
        if ([_userSexStr isEqualToString:@"0"]) {
            cell.userSexImg.image = [UIImage imageNamed:@""];
        } else if ([_userSexStr isEqualToString:@"1"]) {
            cell.userSexImg.image = [UIImage imageNamed:@"icon_man"];
        } else if ([_userSexStr isEqualToString:@"2"]) {
            cell.userSexImg.image = [UIImage imageNamed:@"icon_woman"];
        } else {
            cell.userSexImg.image = [UIImage imageNamed:@""];
        }
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountSecurityCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"accountSecurityCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"账号与安全";
        cell.imageView.image = [UIImage imageNamed:@"icon_Security"];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noticeCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"消息通知";
            cell.imageView.image = [UIImage imageNamed:@"icon_massage"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"系统通知";
            cell.imageView.image = [UIImage imageNamed:@"icon_setting"];
        } else {
            cell.textLabel.text = @"关于消汇邦";
            cell.imageView.image = [UIImage imageNamed:@"icon_about"];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UserInformationViewController *userInformationVC = [[UserInformationViewController alloc] init];
        userInformationVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInformationVC animated:YES];
    } else if (indexPath.section == 1) {
        AccountSettingViewController *accountVC = [[AccountSettingViewController alloc] initWithUserPhone:_userMobileStr];
        accountVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:accountVC animated:YES];
    } else {
        if (indexPath.row == 0) {
            NotificationSettingViewController *notificationVC = [[NotificationSettingViewController alloc] init];
            notificationVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:notificationVC animated:YES];
        } else if (indexPath.row == 1) {
            SystemSettingViewController *systemVC = [[SystemSettingViewController alloc] init];
            systemVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:systemVC animated:YES];
        } else {
            AboutXHBViewController *aboutVC = [[AboutXHBViewController alloc] init];
            aboutVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
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
