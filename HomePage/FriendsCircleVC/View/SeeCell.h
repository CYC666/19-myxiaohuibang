//
//  SeeCell.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeeLayout.h"


@interface SeeCell : UITableViewCell

@property (strong, nonatomic) SeeLayout *seeLayout;                     // 储存动态内容和动态布局
@property (assign, nonatomic) NSInteger indexpathRow;                   // 当前单元格对应表视图的indexpathRow 

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;        // 头像
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;            // 昵称

@property (strong, nonatomic) UILabel *contentLabel;                    // 动态内容视图
@property (strong, nonatomic) UIImageView *aboutImageView;              // 动态的图片视图
@property (strong, nonatomic) UILabel *timeLabel;                       // 显示发布动态的时间Label
@property (strong, nonatomic) UIButton *deleteButton;                   // 删除按钮
@property (strong, nonatomic) UIButton *proButton;                      // 点赞按钮
@property (strong, nonatomic) UIButton *commentButton;                  // 评论按钮
@property (strong, nonatomic) UIView *commentAndProView;                // 点赞跟评论的背景视图
@property (strong, nonatomic) UIImageView *proListIcon;                 // 点赞详情的icon
@property (strong, nonatomic) UILabel *proListLabel;                    // 点赞详情标签


@property (assign, nonatomic) BOOL isLike;                              // 是否点赞
































/*
 
被丢弃的代码
 
@property (strong, nonatomic) UIView *commentsListView;                 // 评论详情列表

 //@property (strong, nonatomic) UIImage *headImage;                       // 头像
 //@property (strong, nonatomic) UIImage *aboutImage;                      // 动态图像

 
 
*/











@end
