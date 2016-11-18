//
//  RCDUserInfoManager.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/24.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "RCDUtilities.h"

#import <RongIMKit/RongIMKit.h>

@interface RCDUserInfoManager : NSObject

+ (RCDUserInfoManager *)shareInstance;

//通过自己Id获取自己的用户信息
- (void)getUserInfo:(NSString *)userId
         completion:(void (^)(RCUserInfo *))completion;

//通过好友Id获取好友的用户信息
- (void)getFriendInfo:(NSString *)friendId
           completion:(void (^)(RCUserInfo *))completion;

//通过好友Id从数据库中获取好友的用户信息
- (RCUserInfo *)getFriendInfoFromDB:(NSString *)friendId;

//如有好友备注，则显示备注
-(NSArray *)getFriendInfoList:(NSArray *)friendList;

//通过userId设置默认的用户信息
- (RCUserInfo *)generateDefaultUserInfo:(NSString *)userId;

@end
