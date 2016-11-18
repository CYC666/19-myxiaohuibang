//
//  SeeLayout.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//


// 动态布局model


#import <Foundation/Foundation.h>
#import "SeeModel.h"

@interface SeeLayout : NSObject

@property (strong, nonatomic) SeeModel *seeModel;       // 动态数据
@property (assign, nonatomic) CGFloat cellHeight;       // 单元格的高度
@property (assign, nonatomic) CGRect seeFrame;          // 正文frame
@property (assign, nonatomic) CGRect imgFrame;          // 图片frame
@property (assign, nonatomic) CGRect timeFrame;         // 时间frame
@property (assign, nonatomic) CGRect deleteFrame;       // 删除按钮frame
@property (copy, nonatomic) NSString *timeText;         // 转化后的时间
@property (assign, nonatomic) CGRect proFrame;          // 点赞按钮frame
@property (assign, nonatomic) CGRect commentFrame;      // 评论按钮frame
@property (assign, nonatomic) CGRect proListIconFrame;  // 点赞列表图标的frame
@property (assign, nonatomic) CGRect proListLabelFrame; // 点赞人员标签的frame
@property (assign, nonatomic) CGRect commentsListViewFrame; // 评论区域的frame
@property (strong, nonatomic) NSMutableArray *commentListFrameArr;  // 评论列表frame数组
@property (assign, nonatomic) CGRect proAndCommentFrame;    // 点赞列表和评论列表的背景视图


@end
