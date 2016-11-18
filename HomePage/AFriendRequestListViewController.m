//
//  AFriendRequestListViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/25.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AFriendRequestListViewController.h"

#import "RCDUserInfo.h"
#import "RCDChatListCell.h"
#import "RCDHttpTool.h"

#import "RCDAddressBookViewController.h"

#import <UIImageView+WebCache.h>

@interface AFriendRequestListViewController ()

@end

@implementation AFriendRequestListViewController

- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
                                            @(ConversationType_PRIVATE),
                                            @(ConversationType_DISCUSSION),
                                            @(ConversationType_APPSERVICE),
                                            @(ConversationType_PUBLICSERVICE),
                                            @(ConversationType_GROUP),
                                            @(ConversationType_SYSTEM)
                                            ]];
        
        //聚合会话类型
        [self setCollectionConversationType:@[@(ConversationType_SYSTEM)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.conversationListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.conversationListTableView.frame = CGRectMake(0, 0, My_Screen_Width, My_Screen_Height);
    self.conversationListTableView.backgroundColor = [UIColor whiteColor];
    
    self.conversationListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.conversationListTableView];
}

//自定义cell
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:
(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    NSLog(@"%@",model);
    __block NSString *userName = nil;
    __block NSString *portraitUri = nil;
    
    __weak AFriendRequestListViewController *weakSelf = self;
    //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
    if (nil == model.extend) {
        // Not finished yet, To Be Continue...
        if (model.conversationType == ConversationType_SYSTEM &&
            [model.lastestMessage
             isMemberOfClass:[RCContactNotificationMessage class]]) {
                RCContactNotificationMessage *_contactNotificationMsg =
                (RCContactNotificationMessage *)model.lastestMessage;
                if (_contactNotificationMsg.sourceUserId == nil) {
                    RCDChatListCell *cell =
                    [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@""];
                    cell.lblDetail.text = @"好友请求";
                    [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                                  placeholderImage:[UIImage imageNamed:@"system_notice"]];
                    return cell;
                }
                NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]
                                                 objectForKey:_contactNotificationMsg.sourceUserId];
                if (_cache_userinfo) {
                    userName = _cache_userinfo[@"username"];
                    portraitUri = _cache_userinfo[@"portraitUri"];
                } else {
                    NSDictionary *emptyDic = @{};
                    [[NSUserDefaults standardUserDefaults]
                     setObject:emptyDic
                     forKey:_contactNotificationMsg.sourceUserId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [RCDHTTPTOOL
                     getUserInfoByUserID:_contactNotificationMsg.sourceUserId
                     completion:^(RCUserInfo *user) {
                         if (user == nil) {
                             return;
                         }
                         RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                         rcduserinfo_.name = user.name;
                         rcduserinfo_.userId = user.userId;
                         rcduserinfo_.portraitUri = user.portraitUri;
                         
                         model.extend = rcduserinfo_;
                         
                         // local cache for userInfo
                         NSDictionary *userinfoDic = @{
                                                       @"username" : rcduserinfo_.name,
                                                       @"portraitUri" : rcduserinfo_.portraitUri
                                                       };
                         [[NSUserDefaults standardUserDefaults]
                          setObject:userinfoDic
                          forKey:_contactNotificationMsg.sourceUserId];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         [weakSelf.conversationListTableView
                          reloadRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:
                          UITableViewRowAnimationAutomatic];
                     }];
                }
            }
    } else {
        RCDUserInfo *user = (RCDUserInfo *)model.extend;
        userName = user.name;
        portraitUri = user.portraitUri;
        
        NSLog(@"%@~~~%@",userName,portraitUri);
    }
    RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.lblDetail.text =
    [NSString stringWithFormat:@"来自%@的好友请求", userName];
    [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                  placeholderImage:[UIImage imageNamed:@"system_notice"]];
    cell.labelTime.text = [RCKitUtility ConvertMessageTime:model.sentTime/1000];
    cell.model = model;
    
    NSLog(@"%@",cell.lblDetail.text);
    
    return cell;
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    if (model.conversationModelType ==
        RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
        
    }
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
            RCDAddressBookViewController * addressBookVC= [RCDAddressBookViewController addressBookViewController];
            addressBookVC.needSyncFriendList = YES;
            
            [self.navigationController pushViewController:addressBookVC
                                                 animated:YES];
            return;
        }
        //如果是单聊，不显示发送方昵称
    }
    //聚合会话类型，此处自定设置。
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        
        AFriendRequestListViewController *temp =
        [[AFriendRequestListViewController alloc] init];
        NSArray *array = [NSArray
                          arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        temp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
    
    //自定义会话类型
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        RCConversationModel *model = self.conversationListDataSource[indexPath.row];
        
        if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
            
            RCDAddressBookViewController * addressBookVC= [RCDAddressBookViewController addressBookViewController];
            [self.navigationController pushViewController:addressBookVC animated:YES];
        }
    }
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       [self refreshConversationTableViewIfNeeded];
                   });
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
