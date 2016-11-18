//
//  AppDelegate.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AppDelegate.h"

#import "RCDHttpTool.h"
#import "AFHttpTool.h"
#import "RCDataBaseManager.h"

#define RONGCLOUD_IM_APPKEY @"8w7jv4qb77oay"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    
    //设置会话列表头像和会话界面头像
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    
    [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    
    //开启用户信息和群组信息的持久化
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    
    [RCIM sharedRCIM].enableTypingStatus = YES;
    
    [RCIM sharedRCIM].enabledReadReceiptConversationTypeList = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION),@(ConversationType_GROUP)];
    
     [RCIM sharedRCIM].enableSyncReadStatus = YES;
    
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;
    
    [RCIM sharedRCIM].groupMemberDataSource = RCDDataSource;
    //开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
    [RCIM sharedRCIM].enableMessageMentioned = YES;
    
    //开启消息撤回功能
    [RCIM sharedRCIM].enableMessageRecall = YES;
    
    NSString *usrId = [USER_D objectForKey:@"user_id"];
    NSString *nickname =  [USER_D objectForKey:@"nickname"];
    NSString *headImg =  [USER_D objectForKey:@"head_img"];
    
    NSString *token = [USER_D objectForKey:@"key_token"];
    
    NSString *userPortraitUri = [USER_D objectForKey:@"userPortraitUri"];
    NSString *userNickName = [USER_D objectForKey:@"userNickName"];
    
    NSLog(@"%@~~~~~~%@",nickname,headImg);
    
    if (usrId != nil) {
        RCUserInfo *_currentUserInfo = [[RCUserInfo alloc] initWithUserId:usrId
                                                                     name:userPortraitUri
                                                                 portrait:userNickName];
        [RCIM sharedRCIM].currentUserInfo = _currentUserInfo;
        
        //登录融云服务器
        [[RCIM sharedRCIM] connectWithToken:token
                                    success:^(NSString *userId) {
                                        NSLog(@"%@",userId);
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [RCDHTTPTOOL
                                             getUserInfoByUserID:userId
                                             completion:^(RCUserInfo *user) {
                                                 [USER_D setObject:user.portraitUri
                                                            forKey:@"userPortraitUri"];
                                                 [USER_D setObject:user.name
                                                            forKey:@"userNickName"];
                                                 [USER_D synchronize];
                                                 [RCIMClient sharedRCIMClient].currentUserInfo =
                                                 user;
                                             }];
                                            //登录demoserver成功之后才能调demo 的接口
                                            [RCDDataSource syncGroups];
                                            [RCDDataSource syncFriendList:userId
                                                                 complete:^(NSMutableArray *result){
                                                                 }];
                                            [MyTool toMainVCRequest];
                                            
                                            //                                            [RCDDataSource syncFriendList:userId
                                            //                                                                 complete:^(NSMutableArray *result){
                                            //                                                                 }];
                                        });
                                    }
                                      error:^(RCConnectErrorCode status) {
                                          NSLog(@"RCConnectErrorCode is %ld", (long)status);
                                      }
                             tokenIncorrect:^{
                                 NSLog(@"IncorrectToken");
                             }];
    } else {
        
    }
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    
    
    // 请求远程推送权限
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        //注册推送，用于iOS8之前的系统
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
                                           UIRemoteNotificationTypeAlert |
                                           UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    // 远程推送的内容
//    NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    return YES;
}
// 如果 App 未被系统冻结，则您在下面的方法中可以捕获该消息
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // userInfo为远程推送的内容
}


- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCIMClient sharedRCIMClient].sdkRunningMode ==
        RCSDKRunningMode_Backgroud && 0 == left.integerValue) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                             @(ConversationType_PRIVATE),
                                                                             @(ConversationType_DISCUSSION),
                                                                             @(ConversationType_APPSERVICE),
                                                                             @(ConversationType_PUBLICSERVICE),
                                                                             @(ConversationType_GROUP)
                                                                             ]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount;
    }
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    if ([message.content
         isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *msg = 
        (RCInformationNotificationMessage *)message.content;
        // NSString *str = [NSString stringWithFormat:@"%@",msg.message];
        if ([msg.message rangeOfString:@"你已添加了"].location != NSNotFound) {
            [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                                 complete:^(NSMutableArray *friends){
                                 }];
            
            NSLog(@"123");
        }
    } else if ([message.content
                isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *msg =
        (RCContactNotificationMessage *)message.content;
        if ([msg.operation
             isEqualToString:
             ContactNotificationMessage_ContactOperationAcceptResponse]) {
            [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                                 complete:^(NSMutableArray *friends){
                                 }];
            NSLog(@"456");
        }
    } else if ([message.content
                isMemberOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *msg =
        (RCGroupNotificationMessage *)message.content;
        if ([msg.operation isEqualToString:@"Dismiss"] &&
            [msg.operatorUserId
             isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP
                                                    targetId:message.targetId];
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP
                                                         targetId:message.targetId];
            } else if ([msg.operation isEqualToString:@"Rename"]) {
                [RCDHTTPTOOL getGroupByID:message.targetId
                        successCompletion:^(RCDGroupInfo *group) {
                            [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                            [[RCIM sharedRCIM] refreshGroupInfoCache:group
                                                         withGroupId:group.groupId];
                        }];
                NSLog(@"789");
            }
    }
}

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:
                              @"您的帐号在别的设备上登录，"
                              @"您被迫下线！"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
//        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
//        // [loginVC defaultLogin];
//        // RCDLoginViewController* loginVC = [storyboard
//        // instantiateViewControllerWithIdentifier:@"loginVC"];
//        RCDNavigationViewController *_navi = [[RCDNavigationViewController alloc]
//                                              initWithRootViewController:loginVC];
//        self.window.rootViewController = _navi;
//    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
//        [AFHttpTool getTokenSuccess:^(id response) {
//            NSString *token = response[@"result"][@"token"];
//            [[RCIM sharedRCIM] connectWithToken:token
//                                        success:^(NSString *userId) {
//                                            
//                                        } error:^(RCConnectErrorCode status) {
//                                            
//                                        } tokenIncorrect:^{
//                                            
//                                        }];
//        }
//                            failure:^(NSError *err) {
//                                
//                            }];
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_APPSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    application.applicationIconBadgeNumber = unreadMsgCount;
}

// 注册用户通知设置1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    
    
    [application registerForRemoteNotifications];
}
// 注册用户通知设置2
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                                   stringByReplacingOccurrencesOfString:@">" withString:@""]
                                                   stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
