//
//  RCDRCIMDataSource.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RongIMKit/RongIMKit.h>

#define RCDDataSource [RCDRCIMDataSource shareInstance]

@interface RCDRCIMDataSource : NSObject <RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource, RCIMGroupMemberDataSource>

+ (RCDRCIMDataSource *)shareInstance;

/**
 *  同步自己的所属群组到融云服务器,修改群组信息后都需要调用同步
 */
- (void)syncGroups;

/**
 *  获取群中的成员列表
 */
- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray *userIdList))resultBlock;

/**
 *  从服务器同步好友列表
 */
- (void)syncFriendList:(NSString *)userId
              complete:(void (^)(NSMutableArray *friends))completion;
/*
 * 获取所有用户信息
 */
- (NSArray *)getAllUserInfo:(void (^)())completion;
/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)())completion;
/*
 * 获取所有好友信息
 */
- (NSArray *)getAllFriends:(void (^)())completion;

@end
