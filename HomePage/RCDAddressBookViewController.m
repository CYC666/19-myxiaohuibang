//
//  RCDAddressBookViewController.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/25.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "RCDAddressBookViewController.h"

#import "RCDAddressBookTableViewCell.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"

#import "RCDHttpTool.h"

#import "MyChatConversationViewController.h"

@interface RCDAddressBookViewController ()

@property(nonatomic, strong) NSMutableArray *tempOtherArr;
@property(nonatomic, strong) NSMutableArray *friends;
@property(nonatomic, strong) NSMutableDictionary *friendsDic;

@end

@implementation RCDAddressBookViewController
{
    NSInteger tag;
    BOOL isSyncFriends;
}
+ (instancetype)addressBookViewController {
    return [[self alloc]init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.frame = CGRectMake(0, 0, My_Screen_Width, My_Screen_Height);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"新朋友";
    
    self.tableView.tableFooterView = [UIView new];
    
    _friendsDic = [[NSMutableDictionary alloc] init];
    
    tag = 0;
    isSyncFriends = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _needSyncFriendList = YES;
    [self getAllData];
}

- (void)getAllData {
    _friends = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
    
    if ([_friends count] > 0) {        
        self.hideSectionHeader = YES;
        _friends = [self sortForFreindList:_friends];
        
        NSLog(@"_____%@",_friends);
        
        tag = 0;
        [self.tableView reloadData];
    }
    if (isSyncFriends == NO) {
        [RCDDataSource syncFriendList:[USER_D objectForKey:@"user_id"]
                             complete:^(NSMutableArray *result) {
//                                 NSLog(@"~~~~~~~~~%@",result);
                                 
                                 isSyncFriends = YES;
                                 [self getAllData];
                             }];
    }
}

- (NSMutableArray *)sortForFreindList:(NSMutableArray *)friendList {
    NSMutableDictionary *tempFrinedsDic = [NSMutableDictionary new];
    NSMutableArray *updatedAtList = [NSMutableArray new];
    
    for (RCDUserInfo *friend in _friends) {
        NSString *key = friend.updatedAt;
        
        if (key == nil) {
            NSLog([NSString stringWithFormat:@"%@'s updatedAt is nil",friend.userId],nil);
            return nil;
        } else {
            [tempFrinedsDic setObject:friend forKey:key];
            [updatedAtList addObject:key];
        }
    }    
    updatedAtList = [self sortForUpdateAt:updatedAtList];
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *key in updatedAtList) {
        for (NSString *k in [tempFrinedsDic allKeys]) {
            if ([key isEqualToString:k]) {
                [result addObject:[tempFrinedsDic objectForKey:k]];
            }
        }
    }
    return result;
}

- (NSMutableArray *)sortForUpdateAt:(NSMutableArray *)updatedAtList {
    NSMutableArray *sortedList = [NSMutableArray new];
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    for (NSString *updateAt in updatedAtList) {
        NSString *str1 =
        [updateAt stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        NSString *str2 =
        [str1 stringByReplacingOccurrencesOfString:@"T" withString:@"/"];
        NSString *str3 =
        [str2 stringByReplacingOccurrencesOfString:@":" withString:@"/"];
        NSMutableString *str = [[NSMutableString alloc] initWithString:str3];
        NSString *point = @"+";
        if ([str rangeOfString:point].location != NSNotFound) {
            NSRange rang = [updateAt rangeOfString:point];
            [str deleteCharactersInRange:NSMakeRange(rang.location,
                                                     str.length - rang.location)];
            [sortedList addObject:str];
            [tempDic setObject:updateAt forKey:str];
        }
    }
    sortedList = (NSMutableArray *)[sortedList
                                    sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                        [formatter setDateFormat:@"yyyy/MM/dd/hh/mm/ss"];
                                        if (obj1 == [NSNull null]) {
                                            obj1 = @"0000/00/00/00/00/00";
                                        }
                                        if (obj2 == [NSNull null]) {
                                            obj2 = @"0000/00/00/00/00/00";
                                        }
                                        NSDate *date1 = [formatter dateFromString:obj1];
                                        NSDate *date2 = [formatter dateFromString:obj2];
                                        NSComparisonResult result = [date1 compare:date2];
                                        return result == NSOrderedAscending;
                                    }];
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *key in sortedList) {
        for (NSString *k in [tempDic allKeys]) {
            if ([key isEqualToString:k]) {
                [result addObject:[tempDic objectForKey:k]];
            }
        }
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDAddressBookCell";
    RCDAddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if(!cell) {
        cell = [[RCDAddressBookTableViewCell alloc]init];
    }
    cell.tag = tag + 5000;
    cell.acceptBtn.tag = tag + 10000;
    tag++;
    
    RCDUserInfo *user = _friends[indexPath.row];
    [_friendsDic setObject:user
                    forKey:[NSString stringWithFormat:@"%ld", (long)cell.tag]];
    [cell setModel:user];
    
    if ([user.status intValue] == 3) {
        cell.selected = NO;
        cell.acceptBtn.hidden = NO;
        [cell.acceptBtn addTarget:self action:@selector(doAccept:) forControlEvents:UIControlEventTouchUpInside];
        cell.arrow.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserInfo *user = _friends[indexPath.row];
    if ([user.status intValue] == 2 || [user.status intValue] == 3) {
        return;
    }
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = user.userId;
    userInfo.portraitUri = user.portraitUri;
    userInfo.name = user.name;
    
    MyChatConversationViewController *chatViewController =
    [[MyChatConversationViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = userInfo.userId;
    chatViewController.title = userInfo.name;
    chatViewController.displayUserNameInCell = NO;
    [self.navigationController pushViewController:chatViewController
                                         animated:YES];
}

- (void)doAccept:(UIButton *)button {
    NSLog(@"123");
    
    [SVProgressHUD showInfoWithStatus:@"添加好友中"];
    
    NSInteger tempTag = button.tag;
    tempTag -= 5000;
    RCDAddressBookTableViewCell *cell =
    (RCDAddressBookTableViewCell *)[self.view viewWithTag:tempTag];
    
    RCDUserInfo *friend = [_friendsDic
                           objectForKey:[NSString stringWithFormat:@"%ld", (long)tempTag]];
    
    [RCDHTTPTOOL processInviteFriendRequest:friend.userId
                                 withUserId:[USER_D objectForKey:@"user_id"]
                                   complete:^(BOOL request) {
                                       if (request) {
                                           [RCDHTTPTOOL
                                            getFriendsUserID:[USER_D objectForKey:@"user_id"]
                                            complete:^(NSMutableArray *result) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    cell.acceptBtn.hidden = YES;
                                                    cell.arrow.hidden = NO;
                                                    cell.rightLabel.hidden = NO;
                                                    cell.rightLabel.text = @"已接受";
                                                    cell.selected = YES;
                                                    
                                                    [SVProgressHUD dismiss];
                                                    [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                                                });
                                            }];
                                           [RCDHTTPTOOL
                                            getFriendsUserID:[USER_D objectForKey:@"user_id"]
                                            complete:^(NSMutableArray *result) {
                                                
                                            }];
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               
                                               [SVProgressHUD dismiss];
                                               [SVProgressHUD showErrorWithStatus:@"添加失败"];
                                           });
                                       }
                                   }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",[_friends count]);
    
    return [_friends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDAddressBookTableViewCell cellHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
