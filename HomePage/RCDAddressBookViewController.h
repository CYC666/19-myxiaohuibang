//
//  RCDAddressBookViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/25.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDAddressBookViewController : UITableViewController

+ (instancetype)addressBookViewController;

@property(nonatomic, strong) NSArray *keys;

@property(nonatomic, strong) NSMutableDictionary *allFriends;

@property(nonatomic, strong) NSArray *allKeys;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, assign) BOOL hideSectionHeader;

@property(nonatomic, assign) BOOL needSyncFriendList;

@end
