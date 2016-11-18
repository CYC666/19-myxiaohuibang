//
//  PraiseModel.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 点赞model

#import <Foundation/Foundation.h>

@interface PraiseModel : NSObject

@property (copy, nonatomic) NSString *nickname;     // 用户昵称
@property (copy, nonatomic) NSString *user_id;      // 用户ID

@end


/*
 
         "nickname": "13705038428",
         "user_id": "9"
         
*/
