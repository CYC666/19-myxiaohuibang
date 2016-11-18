//
//  MyChatConversationViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/21.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "MyChatConversationViewController.h"

#import "RCDPrivateSettingsTableViewController.h"

#import "RCDGroupSettingsTableViewController.h"

#import "RCDUtilities.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "RCDUserInfoManager.h"

@interface MyChatConversationViewController () <RCMessageCellDelegate>

@property(nonatomic, strong) RCDGroupInfo *groupInfo;

@end

@implementation MyChatConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [backBtn addSubview:backImg];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9,4, 85, 17)];
    backText.text = @"返回";
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(toBackButtonClickInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
//    NSLog(@"%@",self.targetId);
    
    if (self.conversationType == ConversationType_PRIVATE) {
        UIButton *privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [releaseButton setTitle:@"确定" forState:UIControlStateNormal];
        privateButton.frame = CGRectMake(0, 0, 22, 22);
        [privateButton setBackgroundImage:[UIImage imageNamed:@"icon_profile"] forState:UIControlStateNormal];
        [privateButton addTarget:self action:@selector(privateButtonClickInfo:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *privateButtonItem = [[UIBarButtonItem alloc] initWithCustomView:privateButton];
        self.navigationItem.rightBarButtonItem = privateButtonItem;
    } else if (self.conversationType == ConversationType_GROUP) {
        UIButton *groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [releaseButton setTitle:@"确定" forState:UIControlStateNormal];
        groupButton.frame = CGRectMake(0, 0, 24, 20);
        [groupButton setBackgroundImage:[UIImage imageNamed:@"icon_groupdetails"] forState:UIControlStateNormal];
        [groupButton addTarget:self action:@selector(groupButtonClickInfo:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *groupButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupButton];
        self.navigationItem.rightBarButtonItem = groupButtonItem;
    } else {
        
    }
    
    //刷新个人或群组的信息
//    [self refreshUserInfoOrGroupInfo];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateForSharedMessageInsertSuccess:) name:@"RCDSharedMessageInsertSuccess"
//                                               object:nil];
}

- (void)updateForSharedMessageInsertSuccess:(NSNotification *)notification {
    RCMessage *message = notification.object;
    if (message.conversationType == self.conversationType &&
        [message.targetId isEqualToString:self.targetId]) {
        [self appendAndDisplayMessage:message];
    }
}

- (void)refreshUserInfoOrGroupInfo {
    //打开单聊强制从demo server 获取用户信息更新本地数据库
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            __weak typeof(self) weakSelf = self;
            [[RCDRCIMDataSource shareInstance]
             getUserInfoWithUserId:self.targetId
             completion:^(RCUserInfo *userInfo) {
                 [[RCDHttpTool shareInstance] updateUserInfo:weakSelf.targetId
                                                     success:^(RCDUserInfo *user) {
                                                         RCUserInfo *updatedUserInfo = [[RCUserInfo alloc] init];
                                                         updatedUserInfo.userId = user.userId;
                                                         if (user.displayName.length > 0) {
                                                             updatedUserInfo.name = user.displayName;
                                                         } else {
                                                             updatedUserInfo.name = user.name;
                                                         }
                                                         updatedUserInfo.portraitUri = user.portraitUri;
                                                         weakSelf.navigationItem.title = updatedUserInfo.name;
                                                         [[RCIM sharedRCIM] refreshUserInfoCache:updatedUserInfo withUserId: updatedUserInfo.userId];
                                                     }
                                                     failure:^(NSError *err){
                                                         
                                                     }];
             }];
        }
    }
    //打开群聊强制从demo server 获取群组信息更新本地数据库
    if (self.conversationType == ConversationType_GROUP) {
        __weak typeof(self) weakSelf = self;
        [RCDHTTPTOOL getGroupByID:self.targetId
                successCompletion:^(RCDGroupInfo *group) {
                    RCGroup *Group = [[RCGroup alloc] initWithGroupId:weakSelf.targetId groupName:group.groupName portraitUri:group.portraitUri];
                    [[RCIM sharedRCIM] refreshGroupInfoCache:Group withGroupId:weakSelf.targetId];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf refreshTitle];
                    });
                }];
    }
    //更新群组成员用户信息的本地缓存
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSMutableArray *groupList = [[RCDataBaseManager shareInstance] getGroupMember:self.targetId];
//        NSArray *resultList = [[RCDUserInfoManager shareInstance] getFriendInfoList:groupList];
//        groupList = [[NSMutableArray alloc] initWithArray:resultList];
//       for (RCUserInfo *user in groupList) {
//            if ([user.portraitUri isEqualToString:@""]) {
//                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
//            }
//            if ([user.portraitUri hasPrefix:@"file:///"]) {
//                NSString *filePath = [RCDUtilities getIconCachePath:[NSString
//                                                                     stringWithFormat:@"user%@.png", user.userId]];
//                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
//                    user.portraitUri = [portraitPath absoluteString];
//                } else {
//                    user.portraitUri = [RCDUtilities defaultUserPortrait:user];
//                }
//            }
//            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
//        }
    });
}

- (void)toBackButtonClickInfo:(UIButton *)button {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)privateButtonClickInfo:(UIButton *)button {
    UIStoryboard *secondStroyBoard =
    [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDPrivateSettingsTableViewController *settingsVC =
    [secondStroyBoard instantiateViewControllerWithIdentifier:
     @"RCDPrivateSettingsTableViewController"];
    
    settingsVC.userId = self.targetId;
    
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)groupButtonClickInfo:(UIButton *)button {
    RCDGroupSettingsTableViewController *settingsVC = [RCDGroupSettingsTableViewController groupSettingsTableViewController];
    
    NSLog(@"%@~!!!!!!~!~!~!~~~~~%@",_groupInfo,self.targetId);
    
    if (_groupInfo == nil) {
        settingsVC.Group = [[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId];
    } else {
        settingsVC.Group = _groupInfo;
    }
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)refreshTitle {
    int count = [[[RCDataBaseManager shareInstance] getGroupByGroupId:self.targetId].number intValue];
    if(self.conversationType == ConversationType_GROUP && count > 0){
        self.title = [NSString stringWithFormat:@"%@(%d)",self.userName,count];
    }
}

- (void)didTapCellPortrait:(NSString *)userId {
    NSLog(@"userID:  %@",userId);
    
    if (userId != [USER_D objectForKey:@"user_id"]) {
        UIStoryboard *secondStroyBoard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDPrivateSettingsTableViewController *settingsVC =
        [secondStroyBoard instantiateViewControllerWithIdentifier:
         @"RCDPrivateSettingsTableViewController"];
        
        settingsVC.userId = userId;
        
        [self.navigationController pushViewController:settingsVC animated:YES];
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
