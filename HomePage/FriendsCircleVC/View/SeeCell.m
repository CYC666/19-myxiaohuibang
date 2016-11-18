//
//  SeeCell.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SeeCell.h"
#import "PraiseModel.h"
#import "AveluateModel.h"
#import <UIImageView+WebCache.h>
#import "CNetTool.h"

#define reloadTableViewDataNotification @"reloadTableViewDataNotification"  // 刷新表视图通知
#define DeleteRow @"DeleteRow"  // 删除单元格并刷新表视图的通知名
#define kProListHeight 25       // 点赞列表的高度

@implementation SeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 22;
    self.headImageView.layer.masksToBounds = YES;
    
}


#pragma mark - 懒加载
// 动态的内容label
- (UILabel *)contentLabel {

    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;

}

// 动态的图片视图（一张）
- (UIImageView *)aboutImageView {

    if (_aboutImageView == nil) {
        _aboutImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _aboutImageView.contentMode = UIViewContentModeScaleAspectFit;
        _aboutImageView.clipsToBounds = YES;
        [self.contentView addSubview:_aboutImageView];
    }
    return _aboutImageView;

}

// 时间文本
- (UILabel *)timeLabel {

    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;

}

// 删除按钮
- (UIButton *)deleteButton {

    if (_deleteButton == nil) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithRed:220/225.0 green:42/255.0 blue:63/255.0 alpha:1]
                            forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
    }
    return _deleteButton;

}

// 点赞按钮
- (UIButton *)proButton {

    if (_proButton == nil) {
        _proButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
        [_proButton addTarget:self action:@selector(proAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_proButton];
    }
    return _proButton;

}

// 评论按钮
- (UIButton *)commentButton {

    if (_commentButton == nil) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_commentButton];
    }
    return _commentButton;

}

// 点赞跟评论的背景视图
- (UIView *)commentAndProView {

    if (_commentAndProView == nil) {
        _commentAndProView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentAndProView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        [self.contentView addSubview:_commentAndProView];
    }
    return _commentAndProView;

}

// 点赞详情icon
- (UIImageView *)proListIcon {

    if (_proListIcon == nil) {
        _proListIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _proListIcon.image = [UIImage imageNamed:@"icon_pro_blue"];
        [self.contentView addSubview:_proListIcon];
    }
    return _proListIcon;

}

// 点赞详情标签
- (UILabel *)proListLabel {

    if (_proListLabel == nil) {
        _proListLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _proListLabel.font = [UIFont systemFontOfSize:13];
        _proListLabel.textColor = [UIColor colorWithRed:35/255.0 green:97/255.0 blue:185/255.0 alpha:1];
        [self.contentView addSubview:_proListLabel];
    }
    return _proListLabel;

}









#pragma mark - 数据传给cell的时候对cell的内容进行赋值
- (void)setSeeLayout:(SeeLayout *)seeLayout {
    _seeLayout = seeLayout;
    // 说说的头像
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_seeLayout.seeModel.head_img]
                      placeholderImage:[UIImage imageNamed:@"pic_loading"]];
    
    // 设置昵称
    _nickNameLabel.text = _seeLayout.seeModel.nickname;

    // 设置动态内容label
    self.contentLabel.text = _seeLayout.seeModel.content;
    self.contentLabel.frame = _seeLayout.seeFrame;
    
    // 设置动态图片的frame
    if (_seeLayout.seeModel.about_img != nil) {
        [self.aboutImageView sd_setImageWithURL:[NSURL URLWithString:_seeLayout.seeModel.about_img]
                               placeholderImage:[UIImage imageNamed:@"pic_loading"]];
        self.aboutImageView.frame = _seeLayout.imgFrame;
    }
    
    // 当微博是自己的时候，显示删除按钮
    if (_seeLayout.seeModel.user_id == [USER_D objectForKey:@"user_id"]) {
        self.deleteButton.frame = _seeLayout.deleteFrame;
    }
    
    // 设置动态发布的时间
    self.timeLabel.text = _seeLayout.timeText;
    self.timeLabel.frame = _seeLayout.timeFrame;
    
    
    
    
    // 设置点赞按钮
    self.proButton.frame = _seeLayout.proFrame;
    for (PraiseModel *praise in _seeLayout.seeModel.praise) {
        if (praise.user_id == [USER_D objectForKey:@"user_id"]) {
            _isLike = YES;
            break;
        }
    }
    if (_isLike == YES) {
        [self.proButton setImage:[UIImage imageNamed:@"icon_pro_blue"] forState:UIControlStateNormal];
    } else {
        [self.proButton setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    }
    
    // 设置评论按钮
    self.commentButton.frame = _seeLayout.commentFrame;
    
    // 点赞+评论背景视图
    self.commentAndProView.frame = _seeLayout.proAndCommentFrame;
    
    // 点赞详情按钮icon
    self.proListIcon.frame = _seeLayout.proListIconFrame;
    
    // 点赞详情label
    self.proListLabel.frame = _seeLayout.proListLabelFrame;
    NSMutableString *mString = [NSMutableString string];
    for (int i = 0; i < _seeLayout.seeModel.praise.count; i++) {
        PraiseModel *praise = _seeLayout.seeModel.praise[i];
        if (i < 3) {
            if (i == 0) {
                [mString appendString:praise.nickname];
            } else {
                [mString appendFormat:@",%@", praise.nickname];
            }
        }
    }
    if (_seeLayout.seeModel.praise.count > 3) {
        [mString appendFormat:@"等%ld人", _seeLayout.seeModel.praise.count];
    }
    self.proListLabel.text = mString;
    
    // 评论详情    
    for (int i = 0; i < _seeLayout.commentListFrameArr.count; i++) {
        AveluateModel *aveluate = _seeLayout.seeModel.aveluate[i];
        CGRect frame = [_seeLayout.commentListFrameArr[i] CGRectValue];
        UILabel *comment = [[UILabel alloc] initWithFrame:frame];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:14];
        comment.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        
        // 富文本
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", aveluate.nickname, aveluate.about_content]];
        [attribute addAttribute:NSForegroundColorAttributeName
                          value:[UIColor colorWithRed:25/255.0 green:97/255.0 blue:185/255.0 alpha:1]
                          range:NSMakeRange(0, aveluate.nickname.length+1)];
        comment.attributedText = attribute;
        
        [self.contentView addSubview:comment];
        
    }
}


#pragma mark - 点赞、评论按钮响应
- (void)proAction:(UIButton *)button {

    _isLike = !_isLike;
    if (_isLike == YES) {
        [button setImage:[UIImage imageNamed:@"icon_pro_blue"] forState:UIControlStateNormal];
        
        // 网络请求点赞功能
        NSDictionary *param = @{
                                @"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_seeLayout.seeModel.about_id
                                };
        [CNetTool postProWithParameters:param
                                success:^(id response) {

                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"已经点赞"];
                                    // 刷新表视图 -- -- -- SeetableView
                                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadTableViewDataNotification
                                                                                        object:[NSString stringWithFormat:@"%ld", _indexpathRow]];
                                
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"点赞失败"];
                                }];
        
    } else {
        
        // 网络请求取消赞功能
        NSDictionary *param = @{
                                @"user_id":[USER_D objectForKey:@"user_id"],
                                @"about_id":_seeLayout.seeModel.about_id
                                };
        [CNetTool postProWithParameters:param
                                success:^(id response) {
                                    
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"已取消点赞"];
                                    // 刷新表视图 -- -- -- SeetableView
                                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadTableViewDataNotification
                                                                                        object:[NSString stringWithFormat:@"%ld", _indexpathRow]];
                                    
                                } failure:^(NSError *err) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showSuccessWithStatus:@"取消点赞失败"];
                                }];
        [button setImage:[UIImage imageNamed:@"icon_pro_gray"] forState:UIControlStateNormal];
    }
    
    

}

- (void)commentAction:(UIButton *)button {
    
    
    
}

#pragma mark - 删除按钮
- (void)deleteAction:(UIButton *)button {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除此条目？"
                                                                   message:@"删除后不可恢复"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 确定删除动态按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
// 网络请求删除动态，并且删除单元格  -- -- -- SeetableView
[[NSNotificationCenter defaultCenter] postNotificationName:DeleteRow
                                                    object:[NSString stringWithFormat:@"%ld", _indexpathRow]];
NSDictionary *param = @{@"id":_seeLayout.seeModel.about_id};
[CNetTool deleteAboutWithParameters:param
                            success:^(id response) {
                                [SVProgressHUD dismiss];
                                [SVProgressHUD showSuccessWithStatus:@"删除动态成功"];
                            } failure:^(NSError *err) {
                                [SVProgressHUD dismiss];
                                [SVProgressHUD showSuccessWithStatus:@"删除动态失败"];
                            }];
                                                       }];
    
    // 取消删除动态按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];

//    [self removeFromSuperview];

}



#pragma mark - 移除通知
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:reloadTableViewDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleteRow object:[NSString stringWithFormat:@"%ld", _indexpathRow]];

}














/*
 
被丢弃的代码
 
self.commentsListView.frame = _seeLayout.commentsListViewFrame;
 
 
// 评论详情列表
- (UIView *)commentsListView {

if (_commentsListView == nil) {
_commentsListView = [[UIView alloc] initWithFrame:CGRectZero];
_commentsListView.backgroundColor = [UIColor clearColor];
[self.contentView addSubview:_commentsListView];

}
return _commentsListView;

}
 
 //// 头像的图片
 //- (void)setHeadImage:(UIImage *)headImage {
 //
 //    _headImage = headImage;
 //    _headImageView.image = headImage;
 //
 //}
 //
 //// 动态的图片
 //- (void)setAboutImage:(UIImage *)aboutImage {
 //
 //    _aboutImage = aboutImage;
 //    self.aboutImageView.image = aboutImage;
 //
 //}

 
*/










- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
