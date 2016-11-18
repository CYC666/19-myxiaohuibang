//
//  AFHttpTool.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "AFHttpTool.h"

@implementation AFHttpTool

+ (AFHttpTool *)shareInstance {
    static AFHttpTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(  NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",XBaseURL,url];
    //
    //    NSDictionary *dic = @{
    //                          @"name":self.accountNumTF.text,
    //                          @"password":self.pswTF.text,
    //                          };
    //        NSLog(@"dic:%@",dic);
    
//    NSLog(@"!!!!!%@",urlStr);
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    session.requestSerializer.timeoutInterval = 5.0;
    
    switch (methodType) {
        case RequestMethodTypeGet: {
            // GET请求
            [session GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        } break;
            
        case RequestMethodTypePost: {            
            // POST请求
            [session POST:urlStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
//                NSLog(@"~~~%@",[MyTool dictionaryToJson:responseObject]);
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        } break;
        default:
            break;
    }
}

// login
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               success:(void (^)(id response))success
               failure:(void (^)(NSError *error))failure {
    NSDictionary *params = @{
                             @"name" : phone,
                             @"password" : password
                             };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XLoginURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)getUserInfo:(NSString *)userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError *err))failure{
    NSDictionary *params = @{
                             @"id" : userId
                             };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XUserMessageURL
                           params:params
                          success:success
                          failure:failure];
}

//获取好友列表
+ (void)getFriendListFromServerUserId:(NSString *)userId
                              success:(void (^)(id response))success
                              failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"id" : userId
                             };
    
    //获取除自己之外的好友信息
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XUserFriendURL
                           params:params
                          success:success
                          failure:failure];
}

//获取用户详细资料
+ (void)getFriendDetailsByID:(NSString *)friendId
                  WithMobile:(NSString *)mobile
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"mobile" : mobile
                             };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XUserQueryFriendsURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)inviteFriendId:(NSString *)friendId
            withUserId:(NSString *)userId
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"id" : userId,
                             @"friend_id" : friendId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XUserAddFriendsURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)processInviteFriendRequest:(NSString *)friendUserId
                        withUserId:(NSString *)userId
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"friend_id" : friendUserId,
                             @"id" : userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XUserAddOKFriendsURL
                           params:params
                          success:success
                          failure:failure];
}

// get group by id
+ (void)getGroupByID:(NSString *)groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"id" : groupID,
                             };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XGroupInfoURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)renameGroupWithGroupId:(NSString *)groupID
                     GroupName:(NSString *)groupName
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"group_id" : groupID,
                              @"name" : groupName
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XGroupNameEditURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)getGroupMembersByID:(NSString *)groupID
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"group_id" : groupID,
                             };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XGroupUserInfoURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSString *)usersId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"group_id" : groupID,
                              @"user_id" : usersId,
                              };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XAddGroupMembersURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSString *)usersId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"group_id" : groupID,
                             @"user_id" : usersId };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XOutGroupMembersURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)dismissGroupWithGroupId:(NSString *)groupID
                    withCreatId:(NSString *)userId
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"group_id" : groupID,
                             @"user_id":userId
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XDelGroupURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)quitGroupWithGroupId:(NSString *)groupID
                  withUserId:(NSString *)userId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"id" : groupID,
                             @"user_id" : userId
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XOutGroupUserURL
                           params:params
                          success:success
                          failure:failure];
}

+ (void)getMyGroupsListWithUserid:(NSString *)userId
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{
                             @"user_id" : userId };
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:XMyGroupListurl
                           params:params
                          success:success
                          failure:failure];
}

@end
