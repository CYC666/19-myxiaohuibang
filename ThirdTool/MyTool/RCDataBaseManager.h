//
//  RCDataBaseManager.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/24.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDB.h>

#import "RCDUserInfo.h"
#import "RCDGroupInfo.h"

@interface RCDataBaseManager : NSObject

+ (RCDataBaseManager *)shareInstance;

//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId;

//存储用户信息
- (void)insertUserToDB:(RCUserInfo *)user;

//存储好友信息
- (void)insertFriendToDB:(RCDUserInfo *)friendInfo;

//从表中获取所有用户信息
- (NSArray *)getAllUserInfo;

//从表中获取所有好友信息 //RCUserInfo
- (NSArray *)getAllFriends;

//从表中获取群组信息
- (RCDGroupInfo *)getGroupByGroupId:(NSString *)groupId;

//存储群组信息
- (void)insertGroupToDB:(RCGroup *)group;

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB;

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId;

//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId;

//从表中获取某个好友的信息
- (RCDUserInfo *)getFriendInfo:(NSString *)friendId;

//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId;

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup;

//清空好友缓存数据
- (void)clearFriendsData;

- (void)closeDBForDisconnect;

@end
