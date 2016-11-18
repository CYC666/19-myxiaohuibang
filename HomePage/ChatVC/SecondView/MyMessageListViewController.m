//
//  MyMessageListViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/10.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "MyMessageListViewController.h"

#import "MyChatConversationViewController.h"

#import "FTPopOverMenu.h"

#import "AddFriendViewController.h"

#import "AddFridensDataViewController.h"

#import "RCDContactSelectedTableViewController.h"

#import "RCDAddressBookViewController.h"

#import "MyContactViewController.h"

#import "RCDChatListCell.h"
#import "RCDUserInfo.h"
#import "RCDHttpTool.h"

#import "UITabBar+badge.h"

#import "AFriendRequestListViewController.h"

#import "UsersToTheirOwnGroupViewController.h"

#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MyMessageListViewController ()
{
    UIView *_myMessageListView;
    
    //    AddressBookViewController *_addressBookView;
    
    MyContactViewController *_myContactView;
}
@property(nonatomic, assign) BOOL isClick;
@property(nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) UIScrollView *contentScrollview;
@property (nonatomic, assign) UISegmentedControl *segmentedControl;

@end

@implementation MyMessageListViewController

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

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;  //默认的值是黑色的
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UIButton *releaseButton = [UIButton new];
    releaseButton.frame = CGRectMake(0, 0, 20, 20);
    [releaseButton setBackgroundImage:[UIImage imageNamed:@"icon_add.png"] forState:UIControlStateNormal];
    [releaseButton addTarget:self action:@selector(onNavButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *releaseButtonItem = [[UIBarButtonItem alloc] initWithCustomView:releaseButton];
    self.navigationItem.rightBarButtonItem = releaseButtonItem;
    
    NSArray *segmentedArray = [NSArray arrayWithObjects:@"消息",@"通讯录", nil];
    UISegmentedControl *segmentedTemp = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segmentedControl = segmentedTemp;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    _segmentedControl.layer.masksToBounds = YES;
    _segmentedControl.layer.cornerRadius = 5;
    _segmentedControl.tintColor = [UIColor colorWithRed:29.0/255.0 green:161.0/255.0 blue:243.0/255.0 alpha:1.0];
    
    // 正常状态下
    NSDictionary * normalTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17.0f],NSForegroundColorAttributeName : [UIColor grayColor] };
    [_segmentedControl setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];
    // 选中状态下
    NSDictionary * selctedTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0f],NSForegroundColorAttributeName : [UIColor whiteColor]};
    [_segmentedControl setTitleTextAttributes:selctedTextAttributes forState:UIControlStateSelected];
    
    [_segmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentedControl;
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-112)];
    
    _contentScrollview = scrollview;
    _contentScrollview.contentSize = CGSizeMake(2*[[UIScreen mainScreen] bounds].size.width, 0);
    _contentScrollview.backgroundColor = [UIColor whiteColor];
    _contentScrollview.pagingEnabled = YES;
    _contentScrollview.showsHorizontalScrollIndicator = NO;
    _contentScrollview.showsVerticalScrollIndicator = NO;
    _contentScrollview.directionalLockEnabled = YES;
    _contentScrollview.bounces = NO;
    _contentScrollview.delegate =self;
    _contentScrollview.scrollEnabled = NO;
    
    _myMessageListView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, My_Screen_Width, My_Screen_Height-114)];
    _myMessageListView.backgroundColor = [UIColor whiteColor];
    
    self.conversationListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.conversationListTableView.frame = CGRectMake(0, 0, My_Screen_Width, My_Screen_Height-50-64);
    self.conversationListTableView.backgroundColor = [UIColor whiteColor];
    
    
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor clearColor] andHeight:32.0f];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 50)];
    
    //设置顶部搜索栏的背景图片
    [_searchBar setBackgroundImage:searchBarBg];
    //设置顶部搜索栏的背景色
    [_searchBar setBackgroundColor:HEXCOLOR(0xf0f0f6)];
    _searchBar.delegate = self;
    _searchBar.layer.borderWidth = 1.0;
    _searchBar.layer.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
    //    //改变searchBar的默认颜色
    //    UIView *segment = [searchBar.subviews objectAtIndex:0];
    //    [segment removeFromSuperview];
    //    searchBar.backgroundColor = [UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:.5f];
    //
    //    //改变searchBar的键盘划出类型
    //    UITextField *sear chTF = [[searchBar subviews] lastObject];
    //    [searchTF setReturnKeyType:UIReturnKeyDone];
    //
    //    searchBar.barStyle = UIBarStyleBlackTranslucent;
    //    searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.placeholder = @"搜索";
    self.conversationListTableView.tableHeaderView = _searchBar;
    
    [_myMessageListView addSubview:self.conversationListTableView];
    
    //    _addressBookView = [[AddressBookViewController alloc] init];
    //    _addressBookView.delegate = self;
    //    _addressBookView.view.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width, -64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-114);
    
    _myContactView = [[MyContactViewController alloc] init];
    _myContactView.delegate = self;
    _myContactView.view.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width, -64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-113);
    
    [_contentScrollview addSubview:_myMessageListView];
    [_contentScrollview addSubview:_myContactView.view];
    
    [self.view addSubview:_contentScrollview];
    [self.view sendSubviewToBack:_contentScrollview];
    
    //定位未读数会话
    self.index = 0;
    //接收定位到未读数会话的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GotoNextCoversation)
                                                 name:@"GotoNextCoversation"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForSharedMessageInsertSuccess) name:@"RCDSharedMessageInsertSuccess"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateBadgeValueForTabBarItem)
                                                name:RCKitDispatchReadReceiptNotification
                                              object:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isClick = YES;
    
//    [_myContactView.friendsTabelView reloadData];
    
    //  [self notifyUpdateUnreadMessageCount];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNeedRefreshNotification:)
                                                 name:@"kRCNeedReloadDiscussionListNotification"
                                               object:nil];
    RCUserInfo *groupNotify = [[RCUserInfo alloc] initWithUserId:@"__system__"
                                                            name:@"群组通知"
                                                        portrait:nil];
    [[RCIM sharedRCIM] refreshUserInfoCache:groupNotify withUserId:@"__system__"];
}

//自定义cell
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    NSLog(@"%@",model);
    __block NSString *userName = nil;
    __block NSString *portraitUri = nil;
    
    __weak MyMessageListViewController *weakSelf = self;
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
    RCDChatListCell *cell =
    [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:@""];
    cell.lblDetail.text = [NSString stringWithFormat:@"来自%@的好友请求", userName];
    [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]];
    cell.labelTime.text = [RCKitUtility ConvertMessageTime:model.sentTime/1000];
    cell.model = model;
    
    NSLog(@"%@",cell.lblDetail.text);
    
    return cell;
}

#pragma mark - 收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification {
    __weak typeof(&*self) blockSelf_ = self;
    //处理好友请求
    RCMessage *message = notification.object;
    if ([message.content isMemberOfClass:[RCContactNotificationMessage class]]) {
        
        if (message.conversationType != ConversationType_SYSTEM) {
            NSLog(@"好友消息要发系统消息！！！");
#if DEBUG
            @throw [[NSException alloc]
                    initWithName:@"error"
                    reason:@"好友消息要发系统消息！！！"
                    userInfo:nil];
#endif
        }
        RCContactNotificationMessage *_contactNotificationMsg =
        (RCContactNotificationMessage *)message.content;
        if (_contactNotificationMsg.sourceUserId == nil ||
            _contactNotificationMsg.sourceUserId.length == 0) {
            return;
        }
        //该接口需要替换为从消息体获取好友请求的用户信息
        [RCDHTTPTOOL getUserInfoByUserID:_contactNotificationMsg.sourceUserId completion:^(RCUserInfo *user) {
            RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
            rcduserinfo_.name = user.name;
            rcduserinfo_.userId = user.userId;
            rcduserinfo_.portraitUri = user.portraitUri;
            
            RCConversationModel *customModel = [RCConversationModel new];
            customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
            customModel.extend = rcduserinfo_;
            customModel.conversationType = message.conversationType;
            customModel.targetId = message.targetId;
            customModel.sentTime = message.sentTime;
            customModel.receivedTime = message.receivedTime;
            customModel.senderUserId = message.senderUserId;
            customModel.lastestMessage = _contactNotificationMsg;
            //[_myDataSource insertObject:customModel atIndex:0];
            
            // local cache for userInfo
            NSDictionary *userinfoDic = @{
                                          @"username" : rcduserinfo_.name,
                                          @"portraitUri" : rcduserinfo_.portraitUri
                                          };
            
            //            NSLog(@"%@",userinfoDic);
            
            [[NSUserDefaults standardUserDefaults] setObject:userinfoDic forKey:_contactNotificationMsg.sourceUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //调用父类刷新未读消息数
                //                 [blockSelf_
                //                  refreshConversationTableViewWithConversationModel:
                //                  customModel];
                //                 [self notifyUpdateUnreadMessageCount];
                
                //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
                //原因请查看super didReceiveMessageNotification的注释。
                NSNumber *left = [notification.userInfo objectForKey:@"left"];
                if (0 == left.integerValue) {
                    [super refreshConversationTableViewIfNeeded];
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //调用父类刷新未读消息数
            [super didReceiveMessageNotification:notification];
        });
    }
}

- (void)didTapCellPortrait:(RCConversationModel *)model {
    if (model.conversationModelType ==
        RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
        MyChatConversationViewController *_conversationVC =
        [[MyChatConversationViewController alloc] init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        //        _conversationVC.userName = model.conversationTitle;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = model.conversationTitle;
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        _conversationVC.navigationItem.titleView = title;
        
        _conversationVC.conversation = model;
        _conversationVC.unReadMessage = model.unreadMessageCount;
        _conversationVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        MyChatConversationViewController *_conversationVC =
        [[MyChatConversationViewController alloc] init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.userName = model.conversationTitle;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        title.text = model.conversationTitle;
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        _conversationVC.navigationItem.titleView = title;
        
        _conversationVC.conversation = model;
        _conversationVC.unReadMessage = model.unreadMessageCount;
        _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
        _conversationVC.enableUnreadMessageIcon = YES;
        _conversationVC.hidesBottomBarWhenPushed = YES;
        if (model.conversationType == ConversationType_SYSTEM) {
            _conversationVC.userName = @"系统消息";
            _conversationVC.title = @"系统消息";
        }
        if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
            RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
            addressBookVC.needSyncFriendList = YES;
            addressBookVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addressBookVC animated:YES];
            return;
        }
        //如果是单聊，不显示发送方昵称
        if (model.conversationType == ConversationType_PRIVATE) {
            _conversationVC.displayUserNameInCell = NO;
        }
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }
    //聚合会话类型，此处自定设置。
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        MyMessageListViewController *temp = [[MyMessageListViewController alloc] init];
        NSArray *array = [NSArray
                          arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        temp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
    //自定义会话类型
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        //        RCConversationModel *model = self.conversationListDataSource[indexPath.row];
        if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
            RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
            addressBookVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addressBookVC animated:YES];
        }
    }
}
 
//插入自定义会话model
- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource {
    for (int i = 0; i < dataSource.count; i++) {
        RCConversationModel *model = dataSource[i];
        //筛选请求添加好友的系统消息，用于生成自定义会话类型的cell
        if (model.conversationType == ConversationType_SYSTEM &&
            [model.lastestMessage
             isMemberOfClass:[RCContactNotificationMessage class]]) {
                model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
            }
        if ([model.lastestMessage
             isKindOfClass:[RCGroupNotificationMessage class]]) {
            RCGroupNotificationMessage *groupNotification =
            (RCGroupNotificationMessage *)model.lastestMessage;
            if ([groupNotification.operation isEqualToString:@"Quit"]) {
                NSData *jsonData = [groupNotification.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *data = [dictionary[@"data"] isKindOfClass:[NSDictionary class]] ? dictionary[@"data"] : nil;
                NSString *nickName = [data[@"operatorNickname"] isKindOfClass:[NSString class]] ? data[@"operatorNickname"] : nil;
                if ([nickName isEqualToString:[RCIM sharedRCIM].currentUserInfo.name]) {
                    [[RCIMClient sharedRCIMClient] removeConversation:model.conversationType targetId:model.targetId];
                    [self refreshConversationTableViewIfNeeded];
                }
            }
        }
    }
    return dataSource;
}

- (void)receiveNeedRefreshNotification:(NSNotification *)status {
    __weak typeof(&*self) __blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (__blockSelf.displayConversationTypeArray.count == 1 &&
            [self.displayConversationTypeArray[0] integerValue] ==
            ConversationType_DISCUSSION) {
            [__blockSelf refreshConversationTableViewIfNeeded];
        }
    });
}

- (void) GotoNextCoversation {
    NSUInteger i;
    //设置contentInset是为了滚动到底部的时候，避免conversationListTableView自动回滚。
    self.conversationListTableView.contentInset = UIEdgeInsetsMake(0, 0, self.conversationListTableView.frame.size.height, 0);
    for (i = self.index + 1; i < self.conversationListDataSource.count; i++) {
        RCConversationModel *model = self.conversationListDataSource[i];
        if (model.unreadMessageCount > 0) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            self.index = i;
            [self.conversationListTableView scrollToRowAtIndexPath:scrollIndexPath
                                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
    }
    //滚动到起始位置
    if (i >= self.conversationListDataSource.count) {
        //    self.conversationListTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        for (i = 0; i < self.conversationListDataSource.count; i++) {
            RCConversationModel *model = self.conversationListDataSource[i];
            if (model.unreadMessageCount > 0) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                self.index = i;
                [self.conversationListTableView scrollToRowAtIndexPath:scrollIndexPath
                                                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
                break;
            }
        }
    }
}

- (void)updateForSharedMessageInsertSuccess{
    [self refreshConversationTableViewIfNeeded];
}

- (void)updateBadgeValueForTabBarItem {
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient]
                     getUnreadCount:self.displayConversationTypeArray];
        if (count > 0) {
            //      __weakSelf.tabBarItem.badgeValue =
            //          [[NSString alloc] initWithFormat:@"%d", count];
            [__weakSelf.tabBarController.tabBar showBadgeOnItemIndex:0 badgeValue:count];
            
        } else {
            //      __weakSelf.tabBarItem.badgeValue = nil;
            [__weakSelf.tabBarController.tabBar hideBadgeOnItemIndex:0];
        }
    });
}

- (void)MyMessagePushViewColltroller:(UIViewController *)MyMessageViewColltroller {
    [self.navigationController pushViewController:MyMessageViewColltroller animated:YES];
}

- (void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event {
    [FTPopOverMenu showFromEvent:event
                        withMenu:@[@"  发起群聊",@"  添加好友",@"  扫一扫"]
                  imageNameArray:@[@"icon_group-chat.png",@"icon_加人.png",@"saoyisao.png"]
                       doneBlock:^(NSInteger selectedIndex) {
                           KMLog(@"%ld",selectedIndex);
                           
                           switch (selectedIndex) {
                               case 0:
                               {
                                   RCDContactSelectedTableViewController *contactSelectedVC = [[RCDContactSelectedTableViewController alloc]init];
                                   contactSelectedVC.forCreatingGroup = YES;
                                   contactSelectedVC.isAllowsMultipleSelection = YES;
                                   UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                                   title.text = @"选择联系人";
                                   title.textAlignment = NSTextAlignmentCenter;
                                   title.textColor = [UIColor whiteColor];
                                   contactSelectedVC.navigationItem.titleView = title;
//                                   contactSelectedVC.titleStr = @"选择联系人";
                                   contactSelectedVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:contactSelectedVC animated:YES];
                               }
                                   break;
                               case 1:
                               {
                                   AddFriendViewController *addFriendVC = [[AddFriendViewController alloc] init];
                                   addFriendVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:addFriendVC animated:YES];
                               }
                                   break;
                               case 2:
                               {
                                   EZQRCodeScanner *scanner = [[EZQRCodeScanner alloc] init];
                                   scanner.delegate = self;
                                   scanner.scanStyle = EZScanStyleNetGrid;
                                   
                                   UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                                   title.text = @"扫描二维码";
                                   title.textAlignment = NSTextAlignmentCenter;
                                   title.textColor = [UIColor whiteColor];
                                   scanner.navigationItem.titleView = title;
                                   
                                   scanner.hidesBottomBarWhenPushed = YES;
//                                   scanner.showButton = NO;
                                   [self.navigationController pushViewController:scanner animated:YES];
                               }
                                   break;
                                   
                               default:
                                   break;
                           }
                       } dismissBlock:^{
                           KMLog(@"123");
                       }];
}

- (void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage {
    NSLog(@"%@",errorMessage);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output {
//    [self.navigationController popViewControllerAnimated:YES];
    
    NSLog(@"%@",output);
    
    NSDictionary *diccc = [MyTool toArrayOrNSDictionary:[output dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *typeStr = [diccc objectForKey:@"type"];
    
    if ([typeStr isEqualToString:@"user"]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,XUserQueryFriendsURL];
        
        NSDictionary *dic = @{
                              @"mobile":[diccc objectForKey:@"mobile"],
                              };
        
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        session.requestSerializer.timeoutInterval = 5.0;
        [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success:%@",responseObject);
            
            KMLog(@"%@",[MyTool dictionaryToJson:responseObject]);
            
            NSString *msgStr = [responseObject objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                
                AddFridensDataViewController *addFriendsDataVC = [[AddFridensDataViewController alloc] initWithUserData:[responseObject objectForKey:@"data"]];
                [self.navigationController pushViewController:addFriendsDataVC animated:YES];
                [SVProgressHUD dismiss];
            } else {
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"data"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            KMLog(@"Error:%@",error);
        }];
    } else if ([typeStr isEqualToString:@"group"]) {
//                              @"id":[diccc objectForKey:@"id"],
//                              @"user_id":[USER_D objectForKey:@"user_id"]
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // your navigation controller action goes here
            
            UsersToTheirOwnGroupViewController *userGroupVC = [[UsersToTheirOwnGroupViewController alloc] initWithGroupId:[diccc objectForKey:@"id"]];
            [self.navigationController pushViewController:userGroupVC animated:YES];
        });
    }
}

- (void)segmentClick:(UISegmentedControl *)segment {
    NSInteger index = segment.selectedSegmentIndex;
    //    NSLog(@"-========----%lu",index);
    
    CGPoint point = _contentScrollview.frame.origin;
    point.x = index * CGRectGetWidth(_contentScrollview.frame);
    point.y = -64;
    
    [_contentScrollview setContentOffset:point animated:NO];
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell
                             atIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    
    if (model.conversationType == ConversationType_PRIVATE) {
        RCConversationCell *conversationCell = (RCConversationCell *)cell;
        conversationCell.conversationTitle.text = model.conversationTitle;
    }
}

//- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
//                                  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
//}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    if (_isClick) {
        _isClick = NO;
        if (model.conversationModelType ==
            RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
            //新建一个聊天会话View Controller对象
            MyChatConversationViewController *chat = [[MyChatConversationViewController alloc]init];
            //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
            chat.conversationType = model.conversationType;
            //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
            chat.targetId = model.targetId;
            //设置聊天会话界面要显示的标题
            
            //            KMLog(@"~!~!~!~%@",model.conversationTitle);
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            title.text = model.conversationTitle;
            title.textAlignment = NSTextAlignmentCenter;
            title.textColor = [UIColor whiteColor];
            chat.navigationItem.titleView = title;
            //    chat.title = model.conversationTitle;
            chat.hidesBottomBarWhenPushed = YES;
            //    chat.userName = model.conversationTitle;
            //显示聊天会话界面
            [self.navigationController pushViewController:chat animated:YES];
        }
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
            //新建一个聊天会话View Controller对象
            MyChatConversationViewController *chat = [[MyChatConversationViewController alloc]init];
            //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
            chat.conversationType = model.conversationType;
            //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
            chat.targetId = model.targetId;
            //设置聊天会话界面要显示的标题
            
            KMLog(@"~ID~：%@",model.targetId);
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            title.text = model.conversationTitle;
            title.textAlignment = NSTextAlignmentCenter;
            title.textColor = [UIColor whiteColor];
            chat.navigationItem.titleView = title;
            //    chat.title = model.conversationTitle;
            chat.hidesBottomBarWhenPushed = YES;
            //    chat.userName = model.conversationTitle;
            //显示聊天会话界面
            
            chat.unReadMessage = model.unreadMessageCount;
            chat.enableNewComingMessageIcon = YES; //开启消息提醒
            chat.enableUnreadMessageIcon = YES;
            if (model.conversationType == ConversationType_SYSTEM) {
                //                chat.userName = @"系统消息";
                chat.title = @"系统消息";
            }
            if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
                RCDAddressBookViewController * addressBookVC= [RCDAddressBookViewController addressBookViewController];
                addressBookVC.needSyncFriendList = YES;
                
                [self.navigationController pushViewController:addressBookVC
                                                     animated:YES];
                return;
            }
            //如果是单聊，不显示发送方昵称
            if (model.conversationType == ConversationType_PRIVATE) {
                chat.displayUserNameInCell = NO;
            }
            [self.navigationController pushViewController:chat animated:YES];
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
            RCConversationModel *model =
            self.conversationListDataSource[indexPath.row];
            
            if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
                RCDAddressBookViewController * addressBookVC= [RCDAddressBookViewController addressBookViewController];
                [self.navigationController pushViewController:addressBookVC
                                                     animated:YES];
            }
        }
    }
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       [self refreshConversationTableViewIfNeeded];
                   });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height {
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
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
