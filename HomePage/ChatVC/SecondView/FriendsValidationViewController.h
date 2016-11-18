//
//  FriendsValidationViewController.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/13.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RongIMLib/RCUserInfo.h>

@interface FriendsValidationViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) RCUserInfo *targetUserInfo;

@property (nonatomic, retain) NSString *friendId;

- (id)initWithFriendsiD:(NSString *)friendId;

@end
