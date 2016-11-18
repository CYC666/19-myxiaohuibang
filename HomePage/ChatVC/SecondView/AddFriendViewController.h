//
//  AddFriendViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/7.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SearchListViewController.h"

@interface AddFriendViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,AddFriendNavDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;

@end
