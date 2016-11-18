//
//  FriendsValidationViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/13.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "FriendsValidationViewController.h"

#import "PersonageTableViewCell.h"

#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "RCDHttpTool.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface FriendsValidationViewController ()

@end

@implementation FriendsValidationViewController

- (id)initWithFriendsiD:(NSString *)friendId {
    self = [super init];
    
    if (self) {
        self.friendId = friendId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"朋友验证";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    UITableView *validationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    validationTableView.delegate = self;
    validationTableView.dataSource = self;
    [self.view addSubview:validationTableView];
    
    UIButton *releaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [releaseButton setTitle:@"确定" forState:UIControlStateNormal];
    releaseButton.frame = CGRectMake(0, 0, 60, 30);
    [releaseButton addTarget:self action:@selector(releaseInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *releaseButtonItem = [[UIBarButtonItem alloc] initWithCustomView:releaseButton];
    self.navigationItem.rightBarButtonItem = releaseButtonItem;
}

- (void)releaseInfo:(UIButton *)button {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:@"正在加载"];
    
    RCDUserInfo *user = [[RCDataBaseManager shareInstance] getFriendInfo:self.friendId];
    if ([user.status isEqualToString:@"2"]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"已发送好友邀请"
                                  delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        
        [RCDHTTPTOOL requestFriend:self.friendId
                        withUserId:[USER_D objectForKey:@"user_id"]
                          complete:^(BOOL result) {
                              if (result) {
                                  [SVProgressHUD showSuccessWithStatus:@"请求已发送"];
                                  
                                  [RCDHTTPTOOL getFriendsUserID:[USER_D objectForKey:@"user_id"]
                                                       complete:^(NSMutableArray *result) {
                                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                                       }];
                              } else {
                                  [SVProgressHUD showErrorWithStatus:@"请求失败，请重试"];
                              }
                        }];
    }
    
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XFriendsAddURL];
//    
//    NSDictionary *dic = @{
//                          @"id":[USER_D objectForKey:@"user_id"],
//                          @"friend_id":self.friendId,
//                          };
//    //        NSLog(@"dic:%@",dic);
//    
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
//    //    session.requestSerializer.timeoutInterval = 5.0;
//    [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"success:%@",responseObject);
//        
//        NSLog(@"%@",[MyTool dictionaryToJson:responseObject]);
//        
//        NSString *msgStr = [responseObject objectForKey:@"msg"];
//        NSNumber *msg = (NSNumber *)msgStr;
//        if ([msg isEqualToNumber:@1]) {
////            //创建通知
////            NSNotification *notification =[NSNotification notificationWithName:@"tongzhi" object:nil userInfo:dict];
////            //通过通知中心发送通知
////            [[NSNotificationCenter defaultCenter] postNotification:notification];
////            [self.navigationController popViewControllerAnimated:YES];
//            
//            [self.navigationController popToRootViewControllerAnimated:YES];
//            
//            [SVProgressHUD dismiss];
//        } else {
//            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        KMLog(@"Error:%@",error);
//    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Height, 45)];
        view.backgroundColor = [UIColor clearColor];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, My_Screen_Height-30, 30)];
        lab.text = @"你需要发送验证申请，等对方通过";
        lab.textColor = [UIColor grayColor];
        lab.font = [UIFont systemFontOfSize:14];
        [view addSubview:lab];
        
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UITextField *phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, 200, 45)];
    phoneTF.placeholder = @"你好，我的朋友";
    [cell.contentView addSubview:phoneTF];
    
    return cell;
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
