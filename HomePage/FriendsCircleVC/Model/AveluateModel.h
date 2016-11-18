//
//  AveluateModel.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 评论Model


#import <Foundation/Foundation.h>

@interface AveluateModel : NSObject


@property (copy, nonatomic) NSString *nickname;         // 用户昵称
@property (copy, nonatomic) NSString *user_id;          // 用户ID
@property (copy, nonatomic) NSString *about_content;    // 评论的内容
@property (copy, nonatomic) NSString *eva_id;           // 父评论的ID，如果没有，则为0


@end






/*
 
         "nickname": "13705038428",
         "user_id": "9",
         "about_content": "测试一下评论功能",
         "eva_id": "0"
 
*/
