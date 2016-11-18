//
//  SeeLayout.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SeeLayout.h"
#import "AveluateModel.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kSpace 12.3           // 控件之间的Y空隙
#define kNickLabelHight 33.3  // 昵称高度，昵称下面就是动态正文
#define kContentX 66.0      // 正文的开始X
#define kContentY 35      // 正文的开始Y
#define kFontSzie 15        // 正文字体大小
#define kCommentFontSize 14 // 评论文本字体大小
#define kImgSize (kScreenWidth - kContentX - kContentX)         // 图片大小
#define kDeleteButtonWidth 30   // 删除按钮长度
#define kTimeLabelWidth 60      // 时间文本的长度
#define kTimeLabelHeight 12     // 时间文本的高度
#define kCommentWidth 15.5      // 评论按钮长度
#define kCommentHeight 14.5     // 评论按钮高度
#define kProWidth 16            // 点赞按钮的宽度
#define kProHeight 14.5         // 点赞按钮的高度
#define kProListHeight 25       // 点赞列表的高度
#define kCommentX 77          // 评论的起点X


@implementation SeeLayout


- (void)setSeeModel:(SeeModel *)seeModel {
    _seeModel = seeModel;
    
    // 单元格的高度 = 昵称文本框高度 + 空隙
    self.cellHeight = kNickLabelHight + kSpace;
    
    CGRect textRect = [self.seeModel.content boundingRectWithSize:CGSizeMake(kScreenWidth - 97, 99999)
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kFontSzie]}
                                                          context:nil];
    // 获取动态内容文本的高度
    CGFloat contentHeight = textRect.size.height;
    // 计算动态内容文本的frame
    self.seeFrame = CGRectMake(kContentX, kContentY, kScreenWidth - 97, contentHeight);
    //  更新单元格的高度(不加空隙，挤一点好看)
    self.cellHeight += CGRectGetHeight(self.seeFrame);
    
    
    // 当动态携带图片时
    if (![self.seeModel.about_img isEqualToString:@"0"]) {
        self.imgFrame = CGRectMake(kContentX, self.cellHeight, kImgSize, kImgSize);
        self.cellHeight += kImgSize + kSpace;
    }
    
    // 删除按钮
    self.deleteFrame = CGRectMake(kContentX, self.cellHeight-5, kDeleteButtonWidth, kTimeLabelHeight);
    
    // 时间标签
    if (_seeModel.user_id == [USER_D objectForKey:@"user_id"]) {
        self.timeFrame = CGRectMake(kContentX + kDeleteButtonWidth + kSpace, self.cellHeight-5, kTimeLabelWidth, kTimeLabelHeight);
    } else {
        self.timeFrame = CGRectMake(kContentX, self.cellHeight-5, kTimeLabelWidth, kTimeLabelHeight);
    }
    
    // 将原始时间戳，转换成过去时间
    NSString *create_time = self.seeModel.create_time;
    NSInteger overTime = [[NSDate date] timeIntervalSince1970] - [create_time integerValue];
    NSInteger countTime = overTime / 60;
    if (countTime >= 0 && countTime < 60) {
        self.timeText = [NSString stringWithFormat:@"%ld分钟前", countTime];
    } else {
        countTime = countTime / 60;
        if (countTime >= 0 && countTime < 24) {
            self.timeText = [NSString stringWithFormat:@"%ld小时前", countTime];
        } else {
            countTime = countTime / 24;
            self.timeText = [NSString stringWithFormat:@"%ld天前", countTime];
        }
    }
    
    
    // 评论按钮
    self.commentFrame = CGRectMake(kScreenWidth - kCommentWidth - 13, self.cellHeight - 5, kCommentWidth, kCommentHeight);
    
    // 点赞按钮
    self.proFrame = CGRectMake(kScreenWidth - kCommentWidth - 13 - kProWidth - 15, self.cellHeight - 5, kProWidth, kProHeight);

    // 这行的内容尺寸求好了，更新单元格高度
    self.cellHeight += (12 + kSpace);

    // 点赞列表
    if (_seeModel.praise.count != 0) {
        self.proListIconFrame = CGRectMake(kContentX + 8.5, self.cellHeight + 8.5, 14.5, 13);
        self.proListLabelFrame = CGRectMake(kContentX + 8.5 + 20, self.cellHeight + 8.5, kScreenWidth - kContentX - 12.5 - 20, 13);
        self.proAndCommentFrame = CGRectMake(kContentX, self.cellHeight, kScreenWidth - kContentX - 12.5, kProListHeight);
        self.cellHeight += (kProListHeight + kSpace);
    }
    
    // 评论列表
    if (_seeModel.aveluate.count != 0) {
        
        CGFloat tempHeight = 0;
        for (int i = 0; i < _seeModel.aveluate.count; i++) {
            
            AveluateModel *aveluate = _seeModel.aveluate[i];
            // 根据评论内容来获取区域大小
            NSString *str = [NSString stringWithFormat:@"%@: %@", aveluate.nickname, aveluate.about_content];
            CGRect rect = [str boundingRectWithSize:CGSizeMake(kScreenWidth - 110, 99999)
                                            options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCommentFontSize]}
                                            context:nil];
            // 设置这条评论的frame
            CGFloat commentHeight = rect.size.height;
            CGRect commentFrame = CGRectMake(kContentX + 12.5 , self.cellHeight, kScreenWidth - 110, commentHeight);
            // 将计算好的frame转换成value对象，存入数组
            [self.commentListFrameArr addObject:[NSValue valueWithCGRect:commentFrame]];
            // 累计评论的高度
            tempHeight += (commentHeight + 8.5);
            // 重新获取单元格的高度
            self.cellHeight += (commentHeight + 8.5);
        }
        
        // 点赞+评论
        CGRect tempRect = self.proAndCommentFrame;
        tempRect.size.height += (tempHeight + kSpace);
        self.proAndCommentFrame = tempRect;
        
        self.cellHeight += kSpace;
        
    } else {
        self.commentListFrameArr = nil;
    }
    
    
    

}



#pragma mark - 储存各条评论frame的数组
- (NSMutableArray *)commentListFrameArr {

    if (_commentListFrameArr == nil) {
        _commentListFrameArr = [NSMutableArray array];
    }
    return _commentListFrameArr;

}

























/*
 
被丢弃的代码
 
//        self.commentsListViewFrame = CGRectMake(kCommentX, self.cellHeight, kScreenWidth - 100, 0);
 
// 评论区的frame
CGRect tempRect = self.commentsListViewFrame;
tempRect.size.height = tempHeight;
self.commentsListViewFrame = tempRect;

 
 
*/






@end
