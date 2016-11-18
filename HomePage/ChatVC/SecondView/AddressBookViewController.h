//
//  AddressBookViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SDBaseTableViewController.h"

@interface AddressBookViewController : SDBaseTableViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, UISearchControllerDelegate>

+ (instancetype)addressBookViewController;

@property(nonatomic, strong) UISearchBar *searchFriendsBar;

@end
