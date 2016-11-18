//
//  AddFridensDataViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/13.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AddFridensDataViewController.h"

#import "PersonageTableViewCell.h"

#import "FriendsNoteViewController.h"
#import "FriendsValidationViewController.h"

#import <UIImageView+WebCache.h>

@interface AddFridensDataViewController ()
{
    UITableView *_friendsDataTableView;
}
@end

@implementation AddFridensDataViewController

- (id)initWithUserData:(NSDictionary *)userData {
    self = [super init];
    
    if (self) {
        self.userDataDic = userData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.text = @"详细资料";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = title;
    
    NSLog( @"%@",self.userDataDic);
    
    _friendsDataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, My_Screen_Height) style:UITableViewStyleGrouped];
    _friendsDataTableView.delegate = self;
    _friendsDataTableView.dataSource = self;
    _friendsDataTableView.tableFooterView = [self tableViewFoodView];
    [self.view addSubview:_friendsDataTableView];
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

- (UIView *)tableViewFoodView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 80)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *addFriendsBtn = [UIButton new];
    addFriendsBtn.frame = CGRectMake(45, 20, My_Screen_Width-90, 40);
    addFriendsBtn.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:141.0/255.0 blue:239.0/255.0 alpha:1.0];
    addFriendsBtn.layer.cornerRadius = 5;
    addFriendsBtn.layer.masksToBounds = YES;
    [addFriendsBtn setTitle:@"添加到通讯录" forState:UIControlStateNormal];
    [addFriendsBtn addTarget:self action:@selector(addBuddyToAddressBookButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addFriendsBtn];
    
    return view;
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
    return 1;
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
        }
        cell.userHeadImg.layer.cornerRadius = 5;
        cell.userHeadImg.layer.masksToBounds = YES;
        
        [cell.userHeadImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.userDataDic objectForKey:@"head_img"]]]];
//        NSString *userPhoneStr = [NSString jsonUtils:_userMobileStr];
//        cell.userIDLab.text = [NSString stringWithFormat:@"ID:%@",userPhoneStr];
        cell.userNameLab.text = [NSString jsonUtils:[self.userDataDic objectForKey:@"name"]];
        
        if ([[self.userDataDic objectForKey:@"age"] isEqualToString:@"0"]) {
            cell.userSexImg.image = [UIImage imageNamed:@""];
        } else if ([[self.userDataDic objectForKey:@"age"] isEqualToString:@"1"]) {
            cell.userSexImg.image = [UIImage imageNamed:@"icon_man"];
        } else if ([[self.userDataDic objectForKey:@"age"] isEqualToString:@"2"]) {
            cell.userSexImg.image = [UIImage imageNamed:@"icon_woman"];
        } else {
            cell.userSexImg.image = [UIImage imageNamed:@""];
        }
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountSecurityCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"accountSecurityCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = @"手机号码";
        cell.detailTextLabel.text = [NSString jsonUtils:[self.userDataDic objectForKey:@"mobile"]];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"noticeCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"设置备注名称";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        FriendsNoteViewController *friendsNoteVC = [[FriendsNoteViewController alloc] init];
        [self.navigationController pushViewController:friendsNoteVC animated:YES];
    } else {
        
    }
}

- (void)addBuddyToAddressBookButtonClick:(UIButton *)button {
    FriendsValidationViewController *friendsValidationVC = [[FriendsValidationViewController alloc] initWithFriendsiD:[self.userDataDic objectForKey:@"id"]];
    [self.navigationController pushViewController:friendsValidationVC animated:YES];
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
