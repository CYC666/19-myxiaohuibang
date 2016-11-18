//
//  MyContactViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/26.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyMessageNavDelegate <NSObject>

- (void)MyMessagePushViewColltroller:(UIViewController *)MyMessageViewColltroller;

@end

@interface MyContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak)id <MyMessageNavDelegate>delegate;

@property(nonatomic, retain)  UISearchBar *searchFriendsBar;

@property(nonatomic, strong) NSDictionary *allFriendSectionDic;

@property(nonatomic, retain)  UITableView *friendsTabelView;

@property(nonatomic, strong) NSArray *seletedUsers;

@property(nonatomic, strong) NSString *titleStr;

@property(nonatomic, strong) void (^selectUserList)(NSArray<RCUserInfo *> *selectedUserList);

@end
