//
//  RCDHttpTool.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RongIMLib/RCGroup.h>
#import <RongIMLib/RCUserInfo.h>

#import "RCDUserInfo.h"
#import "RCDGroupInfo.h"

#define RCDHTTPTOOL [RCDHttpTool shareInstance]

@interface RCDHttpTool : NSObject

@property(nonatomic, strong) NSMutableArray *allFriends;
@property(nonatomic, strong) NSMutableArray *allGroups;

+ (RCDHttpTool *)shareInstance;

//获取个人信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion;

//获取好友列表
- (void)getFriendsUserID:(NSString *)userID
                complete:(void (^)(NSMutableArray *result))friendList;

//获取用户详细资料
- (void)getFriendDetailsWithFriendId:(NSString *)friendId
                             success:(void (^)(RCDUserInfo *user))success
                             failure:(void (^)(NSError *err))failure;

//请求添加好友
- (void)requestFriend:(NSString *)friendId
           withUserId:(NSString *)userId
             complete:(void (^)(BOOL result))result;

//确认用户好友添加请求
- (void)processInviteFriendRequest:(NSString *)friendId
                        withUserId:(NSString *)userId
                          complete:(void (^)(BOOL request))result;

//获取群组信息
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(RCDGroupInfo *group))completion;

//修改群组名称
- (void)renameGroupWithGoupId:(NSString *)groupID
                    groupName:(NSString *)groupName
                     complete:(void (^)(BOOL))result;

//获取群成员信息
- (void)getGroupMembersWithGroupId:(NSString *)groupId
                             Block:(void (^)(NSMutableArray *result))block;

//添加群组成员
- (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSString *)usersId
                 complete:(void (^)(BOOL))result;

//将用户踢出群组
- (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSString *)usersId
                   complete:(void (^)(BOOL))result;

//解散群组
- (void)dismissGroupWithGroupId:(NSString *)groupID
                    withCreatId:(NSString *)userId
                       complete:(void (^)(BOOL))result;

//退出群组
- (void)quitGroupWithGroupId:(NSString *)groupID
                  withUserId:(NSString *)userId
                    complete:(void (^)(BOOL))result;

//获取当前用户所在的所有群组信息
- (void)getMyGroupsListWithUserId:(NSString *)userId
                            block:(void (^)(NSMutableArray *result))block;

//更新用户信息
- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(RCDUserInfo *user))success
               failure:(void (^)(NSError *err))failure;

@end
