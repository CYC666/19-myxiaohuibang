//
//  RCDHttpTool.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/22.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "RCDHttpTool.h"

#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "RCDUserInfo.h"

#import "SortForTime.h"

@implementation RCDHttpTool

+ (RCDHttpTool *)shareInstance {
    static RCDHttpTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        instance.allGroups = [NSMutableArray new];
    });
    return instance;
}

//根据userId获取单个用户信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion {
    RCUserInfo *userInfo = [[RCDataBaseManager shareInstance] getUserByUserId:userID];
    if (!userInfo) {
        [AFHttpTool getUserInfo:userID
                        success:^(id response) {
                            if (response) {
                                NSString *msgStr = [response objectForKey:@"msg"];
                                NSNumber *msg = (NSNumber *)msgStr;
                                if ([msg isEqualToNumber:@1]) {
                                    NSDictionary *dic = response[@"data"];
                                    RCUserInfo *user = [RCUserInfo new];
                                    user.userId = dic[@"id"];
                                    user.name = [dic objectForKey:@"nickname"];
                                    user.portraitUri = [dic objectForKey:@"head_img"];
                                    if (!user.portraitUri || user.portraitUri.length <= 0) {
                                        user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                                    }
                                    [[RCDataBaseManager shareInstance] insertUserToDB:user];
                                    if (completion) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(user);
                                        });
                                    }
                                } else {
                                    RCUserInfo *user = [RCUserInfo new];
                                    user.userId = userID;
                                    user.name = [NSString stringWithFormat:@"name%@", userID];
                                    user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                                    
                                    if (completion) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(user);
                                        });
                                    }
                                }
                            } else {
                                RCUserInfo *user = [RCUserInfo new];
                                user.userId = userID;
                                user.name = [NSString stringWithFormat:@"name%@", userID];
                                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                                
                                if (completion) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completion(user);
                                    });
                                }
                            }
                        }
                        failure:^(NSError *err) {
                            NSLog(@"getUserInfoByUserID error");
                            if (completion) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    RCUserInfo *user = [RCUserInfo new];
                                    user.userId = userID;
                                    user.name = [NSString stringWithFormat:@"name%@", userID];
                                    user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                                    
                                    completion(user);
                                });
                            }
                        }];
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!userInfo.portraitUri || userInfo.portraitUri.length <= 0) {
                    userInfo.portraitUri = [RCDUtilities defaultUserPortrait:userInfo];
                }
                completion(userInfo);
            });
        }
    }
}

- (void)getFriendsUserID:(NSString *)userID complete:(void (^)(NSMutableArray *result))friendList {
    NSMutableArray *list = [NSMutableArray new];
    
    [AFHttpTool getFriendListFromServerUserId:userID success:^(id response) {
        NSLog(@"-=-=-=-%@",response);
        
        if (friendList) {
            NSString *msgStr = [response objectForKey:@"msg"];
            NSNumber *msg = (NSNumber *)msgStr;
            if ([msg isEqualToNumber:@1]) {
                [_allFriends removeAllObjects];
                NSArray *regDataArray = response[@"data"];
                [[RCDataBaseManager shareInstance] clearFriendsData];
                
                if (regDataArray.count <= 0) {
                    [SVProgressHUD showErrorWithStatus:@"您的账号当前没有好友，请添加"];
                } else {
                    for (int i = 0; i < regDataArray.count; i++) {
                        NSDictionary *dic = [regDataArray objectAtIndex:i];
                        //                    if([[dic objectForKey:@"status"] intValue]
                        //                    != 1)
                        //                        continue;
                        NSDictionary *userDic = dic[@"user"];
                        
                        if (![userDic[@"id"] isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                            RCDUserInfo *userInfo = [RCDUserInfo new];
                            userInfo.userId = userDic[@"id"];
                            userInfo.name = userDic[@"nickname"];
                            userInfo.portraitUri = userDic[@"head_img"];
                            userInfo.displayName = userDic[@"nickname"];
                            if (!userInfo.portraitUri || userInfo.portraitUri <= 0) {
                                userInfo.portraitUri =
                                [RCDUtilities defaultUserPortrait:userInfo];
                            }
                            userInfo.status = [NSString
                                               stringWithFormat:@"%@", [dic objectForKey:@"status"]];
                            userInfo.updatedAt = [NSString
                                                  stringWithFormat:@"%@", [dic objectForKey:@"updatedAt"]];
                            [list addObject:userInfo];
                            [_allFriends addObject:userInfo];
                            
                            RCUserInfo *user = [RCUserInfo new];
                            user.userId = userDic[@"id"];
                            user.name = userDic[@"nickname"];
                            user.portraitUri = userDic[@"head_img"];
                            if (!user.portraitUri || user.portraitUri <= 0) {
                                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                            }
                            [[RCDataBaseManager shareInstance] insertUserToDB:user];
                            [[RCDataBaseManager shareInstance] insertFriendToDB:userInfo];
                        }
                    }
                }
            } else {
                [SVProgressHUD showErrorWithStatus:[response objectForKey:@"data"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                friendList(list);
            });
        } else {
            friendList(list);
        }
    } failure:^(NSError *err) {
//        NSLog(@"%@",err);
    }];
}

- (void)requestFriend:(NSString *)friendId
           withUserId:(NSString *)userId
             complete:(void (^)(BOOL result))result{
    [AFHttpTool inviteFriendId:friendId
                    withUserId:userId
                       success:^(id response) {
                           
                           NSLog(@"=====%@",response);
                           
                           NSString *msgStr = [response objectForKey:@"msg"];
                           NSNumber *msg = (NSNumber *)msgStr;
                           if ([msg isEqualToNumber:@1]) {
                               dispatch_async(dispatch_get_main_queue(), ^(void) {
                                   result(YES);
                               });
                           } else if (result) {
                               result(NO);
                           }
    } failure:^(NSError *err) {
        if(result) {
            result(NO);
        }
    }];
}

- (void)processInviteFriendRequest:(NSString *)friendId
                        withUserId:(NSString *)userId
                          complete:(void (^)(BOOL request))result {
    [AFHttpTool processInviteFriendRequest:friendId withUserId:userId success:^(id response) {
//        NSLog(@"ok:%@",response);
        NSString *msgStr = [response objectForKey:@"msg"];
        NSNumber *msg = (NSNumber *)msgStr;
        if ([msg isEqualToNumber:@1]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                result(YES);
            });
        } else if (result) {
            result(NO);
        }
    } failure:^(NSError *err) {
        if (result) {
            result(NO);
        }
    }];
}

//获取用户详细资料
- (void)getFriendDetailsWithFriendId:(NSString *)friendId
                             success:(void (^)(RCDUserInfo *user))success
                             failure:(void (^)(NSError *err))failure {
    [AFHttpTool getUserInfo:friendId
                    success:^(id response) {
                        NSString *msgStr = [response objectForKey:@"msg"];
                        NSNumber *msg = (NSNumber *)msgStr;
                        if ([msg isEqualToNumber:@1]) {
                            NSDictionary *dic = response[@"data"];
                            RCUserInfo *user = [RCUserInfo new];
                            user.userId = [dic objectForKey:@"id"];
                            user.name = [dic objectForKey:@"nickname"];
                            NSString *portraitUri = [dic objectForKey:@"head_img"];
                            if (!portraitUri || portraitUri.length <= 0) {
                                portraitUri = [RCDUtilities defaultUserPortrait:user];
                            }
                            user.portraitUri = portraitUri;
                            [[RCDataBaseManager shareInstance] insertUserToDB:user];
                            
                            RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:friendId];
                            Details.name = [dic objectForKey:@"nickname"];
                            Details.portraitUri = portraitUri;
                            Details.displayName = dic[@"displayName"];
                            [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(Details);
                                });
                            }
                        }
                    }
                    failure:^(NSError *err) {
                        failure(err);
                    }];
}

//根据id获取单个群组
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(RCDGroupInfo *group))completion {
    [AFHttpTool getGroupByID:groupID
                     success:^(id response) {
                         
                         NSLog(@"~!!!!!!!~!!!!!!!~%@",response);
                         
                         NSString *msgStr = [response objectForKey:@"msg"];
                         NSNumber *msg = (NSNumber *)msgStr;
                         NSDictionary *result = response[@"data"];
                         if ([msg isEqualToNumber:@1]) {
                             RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                             group.groupId = [result objectForKey:@"id"];
                             group.groupName = [result objectForKey:@"name"];
                             group.portraitUri = [result objectForKey:@"group_img"];
                             
                             if (!group.portraitUri || group.portraitUri.length <= 0) {
                                 group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                             }
                             group.creatorId = [result objectForKey:@"user_id"];
                             group.introduce = [result objectForKey:@"content"];
                             if (!group.introduce) {
                                 group.introduce = @"";
                             }
                             group.number = [result objectForKey:@"memberCount"];
                             group.maxNumber = [result objectForKey:@"max_number"];
                             group.creatorTime = [result objectForKey:@"time"];
                             if (![[result objectForKey:@"deletedAt"]
                                   isKindOfClass:[NSNull class]]) {
                                 group.isDismiss = @"YES";
                             } else {
                                 group.isDismiss = @"NO";
                             }
                             [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                             if ([group.groupId isEqualToString:groupID] && completion) {
                                 completion(group);
                             } else if (completion) {
                                 completion(nil);
                             }
                         } else {
                             if (completion) {
                                 completion(nil);
                             }
                         }
                     }
                     failure:^(NSError *err) {
                         RCDGroupInfo *group = [[RCDataBaseManager shareInstance] getGroupByGroupId:groupID];
                         if (!group.portraitUri || group.portraitUri.length <= 0) {
                             group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                         }
                         completion(group);
                     }];
}

//修改群组名称
- (void)renameGroupWithGoupId:(NSString *)groupID
                    groupName:(NSString *)groupName
                     complete:(void (^)(BOOL))result {
    [AFHttpTool renameGroupWithGroupId:groupID
                             GroupName:groupName
                               success:^(id response) {
                                   
                                   NSString *msgStr = [response objectForKey:@"msg"];
                                   NSNumber *msg = (NSNumber *)msgStr;
                                   if ([msg isEqualToNumber:@1]) {
                                       result(YES);
                                   } else {
                                       result(NO);
                                   }
                               }
                               failure:^(NSError *err) {
                                   result(NO);
                               }];
}

//根据groupId获取群组成员信息
- (void)getGroupMembersWithGroupId:(NSString *)groupId
                             Block:(void (^)(NSMutableArray *result))block {
    [AFHttpTool getGroupMembersByID:groupId
                            success:^(id response) {
                                
                                NSLog(@"%@",response);
                                
                                NSMutableArray *tempArr = [NSMutableArray new];
                                NSString *msgStr = [response objectForKey:@"msg"];
                                NSNumber *msg = (NSNumber *)msgStr;
                                if ([msg isEqualToNumber:@1]) {
                                    NSArray *members = response[@"data"];
                                    
                                    for (NSDictionary *memberInfo in members) {
                                        NSDictionary *tempInfo = memberInfo[@"user"];
                                        RCDUserInfo *member = [[RCDUserInfo alloc] init];
                                        member.userId = tempInfo[@"id"];
                                        member.name = tempInfo[@"nickname"];
                                        member.portraitUri = tempInfo[@"head_img"];
                                        member.updatedAt = memberInfo[@"updatedAt"];
                                        member.displayName = memberInfo[@"displayName"];
                                        if (!member.portraitUri || member.portraitUri <= 0) {
                                            member.portraitUri = [RCDUtilities defaultUserPortrait:member];
                                        }
                                        [tempArr addObject:member];
                                    }
                                }
                                //按加成员入群组时间的升序排列
                                SortForTime *sort = [[SortForTime alloc] init];
                                tempArr = [sort sortForUpdateAt:tempArr order:NSOrderedDescending];
                                
                                if (block) {
                                    block(tempArr);
                                }
                            }
                            failure:^(NSError *err) {
                                block(nil);
                            }];
}

//添加群组成员
- (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSString *)usersId
                 complete:(void (^)(BOOL))result {
    [AFHttpTool addUsersIntoGroup:groupID
                          usersId:usersId
                          success:^(id response) {
                              NSLog(@"res:%@",response);
                              
                              NSString *msgStr = [response objectForKey:@"msg"];
                              NSNumber *msg = (NSNumber *)msgStr;
                              if ([msg isEqualToNumber:@1]) {
                                  result(YES);
                              } else {
                                  result(NO);
                              }
                          } failure:^(NSError *err) {
                              NSLog(@"%@",err);
                              result(NO);
                          }];
}

//将用户踢出群组
- (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSString *)usersId
                   complete:(void (^)(BOOL))result {
    [AFHttpTool kickUsersOutOfGroup:groupID
                            usersId:usersId
                            success:^(id response) {
                                NSLog(@"%@",response);
                                
                                NSString *msgStr = [response objectForKey:@"msg"];
                                NSNumber *msg = (NSNumber *)msgStr;
                                if ([msg isEqualToNumber:@1]) {
                                    result(YES);
                                } else {
                                    result(NO);
                                }
                            }
                            failure:^(NSError *err) {
                                NSLog(@"%@",err);
                                result(NO);
                            }];
}

//解散群组
- (void)dismissGroupWithGroupId:(NSString *)groupID
                    withCreatId:(NSString *)userId
                       complete:(void (^)(BOOL))result {
    [AFHttpTool dismissGroupWithGroupId:groupID
                            withCreatId:userId
                                success:^(id response) {
                                    
                                    NSString *msgStr = [response objectForKey:@"msg"];
                                    NSNumber *msg = (NSNumber *)msgStr;
                                    if ([msg isEqualToNumber:@1]) {
                                        result(YES);
                                    } else {
                                        result(NO);
                                    }
                                }
                                failure:^(NSError *err) {
                                    result(NO);
                                }];
}

//退出群组
- (void)quitGroupWithGroupId:(NSString *)groupID
                  withUserId:(NSString *)userId
                    complete:(void (^)(BOOL))result {
    [AFHttpTool quitGroupWithGroupId:groupID
                          withUserId:userId
                             success:^(id response) {
                                 
                                 NSString *msgStr = [response objectForKey:@"msg"];
                                 NSNumber *msg = (NSNumber *)msgStr;
                                 if ([msg isEqualToNumber:@1]) {
                                     result(YES);
                                 } else {
                                     result(NO);
                                 }
                             }
                             failure:^(NSError *err) {
                                 result(NO);
                             }];
}

//获取当前用户所在的所有群组信息
- (void)getMyGroupsListWithUserId:(NSString *)userId
                            block:(void (^)(NSMutableArray *result))block {
    [AFHttpTool getMyGroupsListWithUserid:userId
                                  success:^(id response) {
                                      NSArray *allGroups = response[@"data"];
                                      NSMutableArray *tempArr = [NSMutableArray new];
                                      
                                      NSString *msgStr = [response objectForKey:@"msg"];
                                      NSNumber *msg = (NSNumber *)msgStr;
                                      
                                      NSLog(@"%@~~~~~~~%@",allGroups,response);
                                      
                                      if ([msg isEqualToNumber:@1]) {
                                          if (allGroups) {
                                              [[RCDataBaseManager shareInstance] clearGroupfromDB];
                                              for (int i = 0; i < allGroups.count; i ++) {
                                                  
                                                  RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                                                  group.groupId = [[allGroups objectAtIndex:i] objectForKey:@"id"];
                                                  group.groupName = [[allGroups objectAtIndex:i] objectForKey:@"name"];
                                                  group.portraitUri = [[allGroups objectAtIndex:i] objectForKey:@"group_img"];
                                                  if (!group.portraitUri || group.portraitUri.length == 0) {
                                                      group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                                                  }
                                                  group.creatorId = [[allGroups objectAtIndex:i] objectForKey:@"user_id"];
                                                  group.maxNumber = @"500";
                                                  [tempArr addObject:group];
                                                  group.isJoin = YES;
                                                  dispatch_async(
                                                                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                                     [[RCDataBaseManager shareInstance] insertGroupToDB:group];
                                                                 });
                                              }
                                              if (block) {
                                                  block(tempArr);
                                              }
                                          } else {
                                              block(nil);
                                          }
                                      } else {
                                          block(nil);
                                      }
                                  }
                                  failure:^(NSError *err) {
                                      NSMutableArray *tempArr = [[RCDataBaseManager shareInstance] getAllGroup];
                                      for (RCDGroupInfo *group in tempArr) {
                                          if (!group.portraitUri || group.portraitUri.length <= 0) {
                                              group.portraitUri = [RCDUtilities defaultGroupPortrait:group];
                                          }
                                      }
                                  }];
}

- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(RCDUserInfo *user))success
               failure:(void (^)(NSError *err))failure {
    [AFHttpTool getUserInfo:userID
                    success:^(id response) {
                        NSString *msgStr = [response objectForKey:@"msg"];
                        NSNumber *msg = (NSNumber *)msgStr;
                        if ([msg isEqualToNumber:@1]) {
                            NSDictionary *dic = response[@"data"];
                            RCUserInfo *user = [RCUserInfo new];
                            user.userId = [dic objectForKey:@"id"];
                            user.name = [dic objectForKey:@"nickname"];
                            NSString *portraitUri = [dic objectForKey:@"head_img"];
                            if (!portraitUri || portraitUri.length <= 0) {
                                portraitUri = [RCDUtilities defaultUserPortrait:user];
                            }
                            user.portraitUri = portraitUri;
                            [[RCDataBaseManager shareInstance] insertUserToDB:user];
                            
                            RCDUserInfo *Details = [[RCDataBaseManager shareInstance] getFriendInfo:userID];
                            Details.name = [dic objectForKey:@"nickname"];
                            Details.portraitUri = portraitUri;
                            Details.displayName = dic[@"displayName"];
                            [[RCDataBaseManager shareInstance] insertFriendToDB:Details];
                            if (success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    success(Details);
                                });
                            }
                        }
                    }
                    failure:^(NSError *err) {
                        failure(err);
                    }];
}

@end
