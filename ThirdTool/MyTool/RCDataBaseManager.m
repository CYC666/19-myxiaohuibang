//
//  RCDataBaseManager.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 2016/10/24.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "RCDataBaseManager.h"

#import "RCDUtilities.h"

@interface RCDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation RCDataBaseManager

static NSString *const userTableName = @"USERTABLE";
static NSString *const groupTableName = @"GROUPTABLEV2";
static NSString *const friendTableName = @"FRIENDSTABLE";
static NSString *const blackTableName = @"BLACKTABLE";
static NSString *const groupMemberTableName = @"GROUPMEMBERTABLE";

+ (RCDataBaseManager *)shareInstance {
    static RCDataBaseManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        [instance dbQueue];
    });
    return instance;
}

//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId {
    __block RCUserInfo *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?", userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}

//存储用户信息
- (void)insertUserToDB:(RCUserInfo *)user {
    NSString *insertSql =
    @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, user.userId, user.name, user.portraitUri];
    }];
}

//存储好友信息
- (void)insertFriendToDB:(RCDUserInfo *)friendInfo {
    NSString *insertSql = @"REPLACE INTO FRIENDSTABLE (userid, name, "
    @"portraitUri, status,updatedAt,displayName) VALUES (?, ?, ?, ?, "@"?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, friendInfo.userId, friendInfo.name,
         friendInfo.portraitUri, friendInfo.status,
         friendInfo.updatedAt, friendInfo.displayName];
    }];
}

//从表中获取所有用户信息
- (NSArray *)getAllUserInfo {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//从表中获取所有好友信息 //RCUserInfo
- (NSArray *)getAllFriends {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FRIENDSTABLE"];
        while ([rs next]) {
            //            RCUserInfo *model;
            RCDUserInfo *model;
            model = [[RCDUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.status = [rs stringForColumn:@"status"];
            model.updatedAt = [rs stringForColumn:@"updatedAt"];
            model.displayName = [rs stringForColumn:@"displayName"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//从表中获取群组信息
- (RCDGroupInfo *)getGroupByGroupId:(NSString *)groupId {
    __block RCDGroupInfo *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db
                           executeQuery:@"SELECT * FROM GROUPTABLEV2 where groupId = ?", groupId];
        while ([rs next]) {
            model = [[RCDGroupInfo alloc] init];
            model.groupId = [rs stringForColumn:@"groupId"];
            model.groupName = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.number = [rs stringForColumn:@"inNumber"];
            model.maxNumber = [rs stringForColumn:@"maxNumber"];
            model.introduce = [rs stringForColumn:@"introduce"];
            model.creatorId = [rs stringForColumn:@"creatorId"];
            model.creatorTime = [rs stringForColumn:@"creatorTime"];
            model.isJoin = [rs boolForColumn:@"isJoin"];
            model.isDismiss = [rs stringForColumn:@"isDismiss"];
        }
        [rs close];
    }];
    return model;
}

//存储群组信息
- (void)insertGroupToDB:(RCDGroupInfo *)group {
    if (group == nil || [group.groupId length] < 1)
        return;
    
    NSString *insertSql = @"REPLACE INTO GROUPTABLEV2 (groupId, "
    @"name,portraitUri,inNumber,maxNumber,introduce,"
    @"creatorId,creatorTime,isJoin,isDismiss) VALUES "
    @"(?,?,?,?,?,?,?,?,?,?)";
                                                                                                                                                            
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, group.groupId, group.groupName,
         group.portraitUri, group.number, group.maxNumber,
         group.introduce, group.creatorId, group.creatorTime,
         [NSString stringWithFormat:@"%d", group.isJoin],
         group.isDismiss];
    }];
}

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB {
    __block BOOL result = NO;
    NSString *clearSql = [NSString stringWithFormat:@"DELETE FROM GROUPTABLEV2"];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:clearSql];
    }];
    return result;
}

//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId {
    if ([groupId length] < 1)
        return;
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",
     @"GROUPTABLEV2", @"groupid", groupId];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:
         @"SELECT * FROM GROUPMEMBERTABLE where groupid=? order by id",
         groupId];
        while ([rs next]) {
            //            RCUserInfo *model;
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId {
    if (groupMemberList == nil || [groupMemberList count] < 1)
        return;
    
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",
     @"GROUPMEMBERTABLE", @"groupid", groupId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:deleteSql];
            for (RCUserInfo *user in groupMemberList) {
                NSString *insertSql = @"REPLACE INTO GROUPMEMBERTABLE (groupid, userid, "
                @"name, portraitUri) VALUES (?, ?, ?, ?)";
                if (user.portraitUri.length <= 0) {
                    user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                }
                [db executeUpdate:insertSql, groupId, user.userId, user.name,
                 user.portraitUri];
            }
        }];
    });
}

//从表中获取某个好友的信息
- (RCDUserInfo *)getFriendInfo:(NSString *)friendId {
    __block RCDUserInfo *friendInfo;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db
                           executeQuery:@"SELECT * FROM FRIENDSTABLE WHERE userid=?", friendId];
        while ([rs next]) {
            friendInfo = [RCDUserInfo new];
            friendInfo.userId = [rs stringForColumn:@"userid"];
            friendInfo.name = [rs stringForColumn:@"name"];
            friendInfo.portraitUri = [rs stringForColumn:@"portraitUri"];
            friendInfo.status = [rs stringForColumn:@"status"];
            friendInfo.updatedAt = [rs stringForColumn:@"updatedAt"];
            friendInfo.displayName = [rs stringForColumn:@"displayName"];
        }
        [rs close];
    }];
    return friendInfo;
}

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup {
    NSMutableArray *allGroups = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =
        [db executeQuery:@"SELECT * FROM GROUPTABLEV2 ORDER BY groupId"];
        while ([rs next]) {
            RCDGroupInfo *model;
            model = [[RCDGroupInfo alloc] init];
            model.groupId = [rs stringForColumn:@"groupId"];
            model.groupName = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.number = [rs stringForColumn:@"inNumber"];
            model.maxNumber = [rs stringForColumn:@"maxNumber"];
            model.introduce = [rs stringForColumn:@"introduce"];
            model.creatorId = [rs stringForColumn:@"creatorId"];
            model.creatorTime = [rs stringForColumn:@"creatorTime"];
            model.isJoin = [rs boolForColumn:@"isJoin"];
            [allGroups addObject:model];
        }
        [rs close];
    }];
    return allGroups;
}

//清空好友缓存数据
- (void)clearFriendsData {
    NSString *deleteSql = @"DELETE FROM FRIENDSTABLE";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

- (FMDatabaseQueue *)dbQueue {
    if ([RCIMClient sharedRCIMClient].currentUserInfo.userId == nil) {
        return nil;
    }
    
    if (!_dbQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory
                            stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"XiaoHuiBangDB%@",
                             [RCIMClient sharedRCIMClient]
                             .currentUserInfo.userId]];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        if (_dbQueue) {
            [self createUserTableIfNeed];
        }
    }
    return _dbQueue;
}

//创建用户存储表
- (void)createUserTableIfNeed {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isTableOK:userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY "
            @"KEY autoincrement, userid text,name text, "
            @"portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_userid ON USERTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:groupTableName withDB:db]) {
            NSString *createTableSQL =
            @"CREATE TABLE GROUPTABLEV2 (id integer PRIMARY KEY autoincrement, "
            @"groupId text,name text, portraitUri text,inNumber text,maxNumber "
            @"text ,introduce text ,creatorId text,creatorTime text, isJoin "
            @"text, isDismiss text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_groupid ON GROUPTABLEV2(groupId);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:friendTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE FRIENDSTABLE (id integer "
            @"PRIMARY KEY autoincrement, userid "
            @"text,name text, portraitUri text, status "
            @"text, updatedAt text, displayName text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_friendsId ON FRIENDSTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        } else if (![self isColumnExist:@"displayName" inTable:friendTableName withDB:db]) {
            [db executeUpdate:@"ALTER TABLE FRIENDSTABLE ADD COLUMN displayName text"];
        }
        
        if (![self isTableOK:blackTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE BLACKTABLE (id integer PRIMARY "
            @"KEY autoincrement, userid text,name text, "
            @"portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL =
            @"CREATE unique INDEX idx_blackId ON BLACKTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:groupMemberTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPMEMBERTABLE (id integer "
            @"PRIMARY KEY autoincrement, groupid text, "
            @"userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_groupmemberId ON "
            @"GROUPMEMBERTABLE(groupid,userid);";
            [db executeUpdate:createIndexSQL];
        }
    }];
}

- (BOOL)isTableOK:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isOK = NO;
    
    FMResultSet *rs =
    [db executeQuery:@"select count(*) as 'count' from sqlite_master where "
     @"type ='table' and name = ?",
     tableName];
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count) {
            isOK = NO;
        } else {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

- (BOOL)isColumnExist:(NSString *)columnName inTable:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isExist = NO;
    
    NSString *columnQurerySql = [NSString stringWithFormat:@"SELECT %@ from %@", columnName, tableName];
    FMResultSet *rs = [db executeQuery:columnQurerySql];
    if ([rs next]) {
        isExist = YES;
    } else {
        isExist = NO;
    }
    [rs close];
    
    return isExist;
}

- (void)closeDBForDisconnect {
    self.dbQueue = nil;
}

@end
