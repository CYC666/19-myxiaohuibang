//
//  MyTool.h
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/28.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyTool : NSObject

//字典转json字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

//json字符串转字典
+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

//进入主页
+ (void)toMainVCRequest;

@end
