//
//  SeeModel.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 用户动态的model



#import <Foundation/Foundation.h>

@interface SeeModel : NSObject

@property (copy, nonatomic) NSString *about_id;         // 动态ID
@property (copy, nonatomic) NSString *user_id;          // 用户ID
@property (copy, nonatomic) NSString *nickname;         // 用户昵称
@property (copy, nonatomic) NSString *head_img;         // 用户头像URL
@property (copy, nonatomic) NSString *content;          // 动态内容
@property (copy, nonatomic) NSString *about_img;        // 动态的图片URL
@property (copy, nonatomic) NSString *create_time;      // 动态创建的时间
@property (strong, nonatomic) NSMutableArray *praise;          // 点赞
@property (strong, nonatomic) NSMutableArray *aveluate;        // 评论


@end



/*
 
         "id": "35",
         "user_id": "9",
         "nickname": "13705038428",
         "head_img": "http://115.28.6.7/Public/head/581d7b02d43f4.jpg",
         "content": "Gg",
         "about_img": "http://115.28.6.7/Public/about/58291610be22c.jpg",
         "create_time": "1479087632",
         "praise": [
         {
         "nickname": "13705038428",
         "user_id": "9"
         },
         {
         "nickname": "刘助",
         "user_id": "2"
         }
         ],
         "aveluate": [
         {
         "nickname": "13705038428",
         "user_id": "9",
         "about_content": "测试一下评论功能",
         "eva_id": "0"
         },
         {
         "nickname": "刘助",
         "user_id": "2",
         "about_content": "我也来测试一下评论功能",
         "eva_id": "0"
         },
         {
         "nickname": "Veeve",
         "user_id": "1",
         "about_content": "说的好像我不能来测试似的",
         "eva_id": "0"
         }
 ]
 
*/
