//
//  UserSexViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/30.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "UserSexViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface UserSexViewController ()
{
    NSIndexPath         *_currentIndexPath;
    NSIndexPath         *_previousIndexPath;
    
    NSString            *_tempAddressStr;
}
@end

@implementation UserSexViewController

- (id)initWithUserSex:(NSString *)userSex {
    self = [super init];
    
    if (self) {
        self.userSexStr = userSex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"性别";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *userSexTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    userSexTableView.delegate = self;
    userSexTableView.dataSource = self;
    userSexTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userSexTableView.scrollEnabled = NO;
    [self.view addSubview:userSexTableView];
    
    KMLog(@"%@",self.userSexStr);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSexCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserSexCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"男";
    } else {
        cell.textLabel.text = @"女";
    }
    if ([self.userSexStr isEqualToString:@"0"]) {
        
    } else if ([self.userSexStr isEqualToString:@"1"]) {
        if (!_previousIndexPath) {
            _previousIndexPath = indexPath;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _currentIndexPath = indexPath;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        if (!_previousIndexPath) {
            _previousIndexPath = indexPath;
            cell.accessoryType = UITableViewCellAccessoryNone;
            _currentIndexPath = indexPath;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
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
    
    NSString *ageStr = [NSString stringWithFormat:@"%ld",_currentIndexPath.row+1];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserInformationModifyURL];
    
    NSDictionary *dic = @{
                          @"id":[USER_D objectForKey:@"user_id"],
                          @"sex":ageStr
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
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            [SVProgressHUD showWithStatus:@"正在加载"];
        } else {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KMLog(@"Error:%@",error);
    }];
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
