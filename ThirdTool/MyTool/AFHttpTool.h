//
//  AFHttpTool.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import <SVProgressHUD.h>

typedef NS_ENUM(NSInteger, RequestMethodType) {
    RequestMethodTypePost = 1,
    RequestMethodTypeGet = 2
};

@interface AFHttpTool : NSObject

/**
 *  发送一个请求
 *
 *  @param methodType   请求方法
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

// 登录
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

// 获取用户信息
+ (void)getUserInfo:(NSString *)userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError *err))failure;

//获取好友列表
+ (void)getFriendListFromServerUserId:(NSString *)userId
                              success:(void (^)(id response))success
                              failure:(void (^)(NSError *err))failure;

//修改群名称
+ (void)renameGroupWithGroupId:(NSString *)groupID
                     GroupName:(NSString *)groupName
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *err))failure;

//获取用户详细资料
+ (void)getFriendDetailsByID:(NSString *)friendId
                  WithMobile:(NSString *)mobile
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

//请求添加好友
+ (void)inviteFriendId:(NSString *)friendId
            withUserId:(NSString *)userId
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

//确认好友添加请求
+ (void)processInviteFriendRequest:(NSString *)friendUserId
                        withUserId:(NSString *)userId
                           success:(void (^)(id))success
                           failure:(void (^)(NSError *))failure;

//根据群id获取群信息
+ (void)getGroupByID:(NSString *)groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError *err))failure;

//根据群id获取群成员资料
+ (void)getGroupMembersByID:(NSString *)groupID
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

//添加群成员
+ (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSString *)usersId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

//踢出群成员
+ (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSString *)usersId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

//群主解散群
+ (void)dismissGroupWithGroupId:(NSString *)groupID
                    withCreatId:(NSString *)userId
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;

//退出群
+ (void)quitGroupWithGroupId:(NSString *)groupID
                  withUserId:(NSString *)userId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

//查看我所在的所有群组
+ (void)getMyGroupsListWithUserid:(NSString *)userId
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure;

@end
