//
//  MyContactViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "MyContactViewController.h"

#import "RCDContactTableViewCell.h"

#import "RCDUtilities.h"
#import "pinyin.h"
#import "RCDataBaseManager.h"
#import "RCDUserInfoManager.h"
#import "DefaultPortraitView.h"

#import "RCDPersonDetailViewController.h"

#import "RCDGroupViewController.h"

#import <UIImageView+WebCache.h>


#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MyContactViewController ()

@property(strong, nonatomic) NSMutableArray *matchFriendList;
@property(strong, nonatomic) NSArray *defaultCellsTitle;
@property(strong, nonatomic) NSArray *defaultCellsPortrait;
@property(nonatomic, assign) BOOL hasSyncFriendList;
@property(nonatomic, assign) BOOL isBeginSearch;
@property(nonatomic, strong) NSMutableDictionary *resultDic;
@end

@implementation MyContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // initial data
    self.matchFriendList = [[NSMutableArray alloc] init];
    self.allFriendSectionDic = [[NSDictionary alloc] init];
    
    self.friendsTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, My_Screen_Width, My_Screen_Height-144) style:UITableViewStyleGrouped];
    self.friendsTabelView.tableFooterView = [UIView new];
    self.friendsTabelView.delegate = self;
    self.friendsTabelView.dataSource = self;
    self.friendsTabelView.backgroundColor = HEXCOLOR(0xf0f0f6);
    self.friendsTabelView.separatorColor = HEXCOLOR(0xdfdfdf);
    
    self.friendsTabelView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.friendsTabelView.bounds.size.width, 0.01f)];
    
    [self.view addSubview:self.friendsTabelView];
    
    //设置右侧索引
    self.friendsTabelView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.friendsTabelView.sectionIndexColor = HEXCOLOR(0x555555);
    
    if ([self.friendsTabelView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.friendsTabelView setSeparatorInset:UIEdgeInsetsMake(0, 14, 0, 0)];
    }
    if ([self.friendsTabelView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.friendsTabelView setLayoutMargins:UIEdgeInsetsMake(0, 14, 0, 0)];
    }
    
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor clearColor] andHeight:32.0f];
    
    self.searchFriendsBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, My_Screen_Width, 50)];
    
    //设置顶部搜索栏的背景图片
    [self.searchFriendsBar setBackgroundImage:searchBarBg];
    //设置顶部搜索栏的背景色
    [self.searchFriendsBar setBackgroundColor:HEXCOLOR(0xf0f0f6)];
    
    self.searchFriendsBar.layer.borderWidth = 1.0;
    self.searchFriendsBar.layer.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
    
    //设置顶部搜索栏输入框的样式
    UITextField *searchField = [self.searchFriendsBar valueForKey:@"_searchField"];
    searchField.layer.borderWidth = 0.5f;
    searchField.layer.borderColor = [HEXCOLOR(0xdfdfdf) CGColor];
    searchField.layer.cornerRadius = 5.f;
    self.searchFriendsBar.placeholder = @"搜索";
    
    [self.view addSubview:self.searchFriendsBar];
    
    self.defaultCellsTitle = [NSArray
                              arrayWithObjects:@"群组", nil];
    self.defaultCellsPortrait = [NSArray
                                 arrayWithObjects:@"icon_group-chat-qun", nil];
    
    self.isBeginSearch = NO;
    
    [self.searchFriendsBar resignFirstResponder];
    
    [self sortAndRefreshWithList:[self getAllFriendList]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.searchFriendsBar resignFirstResponder];
    
    [self sortAndRefreshWithList:[self getAllFriendList]];
    
    //自定义rightBarButtonItem
//    RCDUIBarButtonItem *rightBtn =
//    [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"add_friend"]
//                                  imageViewFrame:CGRectMake(0, 0, 18, 20)
//                                     buttonTitle:nil
//                                      titleColor:nil
//                                      titleFrame:CGRectZero
//                                     buttonFrame:CGRectMake(0, 0, 18, 20)
//                                          target:self
//                                          action:@selector(pushAddFriend:)];
//    self.tabBarController.navigationItem.rightBarButtonItems = [rightBtn setTranslation:rightBtn translation:-6];
    
    self.tabBarController.navigationItem.title = @"通讯录";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_isBeginSearch == YES) {
        
        [self sortAndRefreshWithList:[self getAllFriendList]];
        _isBeginSearch = NO;
        self.searchFriendsBar.showsCancelButton = NO;
        [self.searchFriendsBar resignFirstResponder];
        self.searchFriendsBar.text = @"";
        [self.matchFriendList removeAllObjects];
        [self.friendsTabelView setContentOffset:CGPointMake(0,0) animated:NO];
    }
}

#pragma mark - 获取好友并且排序

- (NSArray *)getAllFriendList {
    NSMutableArray *friendList = [[NSMutableArray alloc] init];
    NSMutableArray *userInfoList = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
    
    NSLog(@"userFriend:%@",[[RCDataBaseManager shareInstance] getAllFriends]);
    
    for (RCDUserInfo *user in userInfoList) {
        
        NSLog(@"friend:%@",user.displayName);
        
        if ([user.status isEqualToString:@"1"]) {
            [friendList addObject:user];
        }
    }
    if (friendList.count <= 0 && !self.hasSyncFriendList) {
        [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                             complete:^(NSMutableArray *result) {
                                 
//                                 NSLog(@"~~~~~%@",result);
                                 
                                 self.hasSyncFriendList = YES;
                                 [self sortAndRefreshWithList:[self getAllFriendList]];
                             }];
    }
    //如有好友备注，则显示备注
    NSArray *resultList = [[RCDUserInfoManager shareInstance] getFriendInfoList:friendList];
    
    return resultList;
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.resultDic = [RCDUtilities sortedArrayWithPinYinDic:friendList];
        
        NSLog(@"self:%@",self.resultDic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allFriendSectionDic = self.resultDic[@"infoDic"];
            
            [self.friendsTabelView reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        if (_isBeginSearch == YES) {
            rows = 0;
        } else {
            rows = 2;
        }
    } else {
        NSString *letter = self.resultDic[@"allKeys"][section -1];
        
//        NSLog(@"~~~~%@",self.resultDic[@"allKeys"]);
        
        rows = [self.allFriendSectionDic[letter] count];
        
//        NSLog(@"~~~~%lu",rows);
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.resultDic[@"allKeys"] count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 21.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 22);
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 3, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    title.textColor = HEXCOLOR(0x999999);
    
    [view addSubview:title];
    
    if (section == 0) {
        title.text = nil;
    } else {
        title.text = self.resultDic[@"allKeys"][section - 1];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];
    static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
    RCDContactTableViewCell *cell = [self.friendsTabelView
                                     dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDContactTableViewCell alloc] init];
    }
    if (indexPath.section == 0 && indexPath.row < 1) {
        cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
        [cell.portraitView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_defaultCellsPortrait objectAtIndex:indexPath.row]]]];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        if ([isDisplayID isEqualToString:@"YES"]) {
            cell.userIdLabel.text = [RCIM sharedRCIM].currentUserInfo.userId;
        }        
        cell.nicknameLabel.text = [RCIM sharedRCIM].currentUserInfo.name;
        
        NSLog(@"%@~~~~~%@", [RCIM sharedRCIM].currentUserInfo.name,[RCIM sharedRCIM].currentUserInfo.portraitUri);
        
        [cell.portraitView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[RCIM sharedRCIM].currentUserInfo.portraitUri]]];
    } if (indexPath.section != 0) {
        NSString *letter = self.resultDic[@"allKeys"][indexPath.section -1];
        NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];
        RCDUserInfo *userInfo = sectionUserInfoList[indexPath.row];
        if (userInfo) {
            if ([isDisplayID isEqualToString:@"YES"]) {
                cell.userIdLabel.text = userInfo.userId;
            }
            cell.nicknameLabel.text = userInfo.name;
            if ([userInfo.portraitUri isEqualToString:@""]) {
                DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
                                                        initWithFrame:CGRectMake(0, 0, 100, 100)];
                [defaultPortrait setColorAndLabel:userInfo.userId Nickname:userInfo.name];
                UIImage *portrait = [defaultPortrait imageFromView];
                cell.portraitView.image = portrait;
            } else {
                [cell.portraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]];
            }
        }
    }
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
        [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        cell.portraitView.layer.masksToBounds = YES;
        cell.portraitView.layer.cornerRadius = 20.f;
    } else {
        cell.portraitView.layer.masksToBounds = YES;
        cell.portraitView.layer.cornerRadius = 5.f;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;
    cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultDic[@"allKeys"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;  //（这种是点击的时候有效果，返回后效果消失）
    
    RCDUserInfo *user = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                RCDGroupViewController *groupVC = [[RCDGroupViewController alloc]init];
                groupVC.hidesBottomBarWhenPushed = YES;
                [self.delegate MyMessagePushViewColltroller:groupVC];
                return;
            } break;
                
            case 1: {
                
                return;
                
            } break;
                
            case 2: {
//                RCDPublicServiceListViewController *publicServiceVC =
//                [[RCDPublicServiceListViewController alloc] init];
//                [self.navigationController pushViewController:publicServiceVC
//                                                     animated:YES];
                return;
                
            } break;
                
            case 3: {
//                UIStoryboard *storyboard =
//                [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                RCDPersonDetailViewController *detailViewController =
//                [storyboard instantiateViewControllerWithIdentifier:
//                 @"RCDPersonDetailViewController"];
//                
//                [self.navigationController pushViewController:detailViewController
//                                                     animated:YES];
//                detailViewController.userId = [RCIM sharedRCIM].currentUserInfo.userId;
                return;
            }
                
            default:
                break;
        }
    }
    NSString *letter = self.resultDic[@"allKeys"][indexPath.section -1];
    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];
    user = sectionUserInfoList[indexPath.row];
    if (user == nil) {
        return;
    }
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = user.userId;
    userInfo.portraitUri = user.portraitUri;
    userInfo.name = user.name;
    
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDPersonDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];
    detailViewController.userId = user.userId;
    detailViewController.hidesBottomBarWhenPushed = YES;
    [self.delegate MyMessagePushViewColltroller:detailViewController];
//    [self.navigationController pushViewController:detailViewController
//                                         animated:YES];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchFriendsBar resignFirstResponder];
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
