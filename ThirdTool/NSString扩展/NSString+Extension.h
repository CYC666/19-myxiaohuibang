//
//  NSString+Extension.h
//  TOP_zrt
//
//  Created by Laughing on 16/5/20.
//  Copyright © 2016年 topzrt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface NSString (Extension)

/*
 * 字符串解析
 */
+(NSString *)jsonUtils:(id)stringValue;

/*
 * 判断字符串是否为空
 */
- (BOOL)isEmpty;

// 手机号码验证
+ (BOOL)validateMobile:(NSString *)mobile;

//固话验证
+ (BOOL)validateAreaTel:(NSString *)areaTel;

// 把手机号第4-7位变成星号
+ (NSString *)phoneNumToAsterisk:(NSString*)phoneNum;

// 邮箱验证
+ (BOOL)validateEmail:(NSString *)email;

// 把邮箱@前面变成星号
+ (NSString*)emailToAsterisk:(NSString *)email;

// 判断是否是身份证号码
+ (BOOL)validateIdCard:(NSString *)idCard;

// 把身份证号第5-14位变成星号
+ (NSString *)idCardToAsterisk:(NSString *)idCardNum;

//通过文本宽度计算高度
- (CGSize)calculateSize:(UIFont *)font maxWidth:(CGFloat)width;

//重写containsString方法，兼容8.0以下版本
- (BOOL)containsString:(NSString *)aString NS_AVAILABLE(10_10, 8_0);

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstCharactor:(NSString *)aString;

//判断字符串是否有中文
+ (BOOL)IsChinese:(NSString *)str;

// 密码
+ (BOOL)validatePassword:(NSString *)password;

// 判断是否含有表情
+ (BOOL)stringContainsEmoji:(NSString *)string;


@end
