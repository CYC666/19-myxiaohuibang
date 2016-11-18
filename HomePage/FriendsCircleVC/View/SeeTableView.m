//
//  SeeTableView.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "SeeTableView.h"
#import "SeeCell.h"
#import "SeeLayout.h"
#import "PraiseModel.h"
#import <UIImageView+WebCache.h>

#define kScreenHeight [UIScreen mainScreen].bounds.size.height  // 屏高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width    // 屏宽
#define kSpace 12.3           // 控件之间的Y空隙
#define kContentX 66.0      // 正文的开始X
#define kProListHeight 25       // 点赞列表的高度

#define SeeCellID @"SeeCellID"
#define reloadTableViewDataNotification @"reloadTableViewDataNotification"  // 刷新表视图通知
#define DeleteRow @"DeleteRow"  // 删除单元格并刷新表视图的通知名

@implementation SeeTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

    self = [super initWithFrame:frame style:style];
    if (self != nil) {
        self.delegate = self;
        self.dataSource = self;
        [self setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.backgroundColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        // [self registerNib:[UINib nibWithNibName:@"SeeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SeeCellID];
        
        // 不开启减速
        // self.decelerationRate = UIScrollViewDecelerationRateFast;
        // 添加点赞通知接收，刷新表视图
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadDataNotification:)
                                                     name:reloadTableViewDataNotification
                                                   object:nil];
        // 删除单元格
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deleteRowNotification:)
                                                     name:DeleteRow
                                                   object:nil];
        
    }
    return self;
}


#pragma mark - 组的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

#pragma mark - 单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _seeLayoutList.count;

}

#pragma mark - 创建单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // SeeCell *cell = [tableView dequeueReusableCellWithIdentifier:SeeCellID];
    // SeeCell *cell = [[SeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SeeCellID];
    SeeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SeeCell" owner:nil options:nil] lastObject];
    cell.indexpathRow = indexPath.row;
    cell.seeLayout = _seeLayoutList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    SeeLayout *seeLayout = self.seeLayoutList[indexPath.row];
    return seeLayout.cellHeight;

}

#pragma mark - 头视图高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return kScreenHeight*.42;

}

#pragma mark - 头视图的创建
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    // 背景视图
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.4)];
    headView.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight*.37)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[USER_D objectForKey:@"head_img"]]];
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [headView addSubview:imageView];
    
    // 头像
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - kScreenWidth*.192 - 13, kScreenHeight*.4 - kScreenWidth*.192, kScreenWidth*.192, kScreenWidth*.192)];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:[USER_D objectForKey:@"head_img"]]];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = kScreenWidth*.192/2.0;
    headImageView.layer.borderWidth = 2.0;
    headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [headView addSubview:headImageView];
    
    // 昵称
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - kScreenWidth*.192 - 13 - 100, kScreenHeight*.4 - kScreenWidth*.192/2.0 - 15, 100, 30)];
    nickName.text = [USER_D objectForKey:@"nickname"];
    nickName.textColor = [UIColor whiteColor];
    nickName.font = [UIFont systemFontOfSize:17];
    [headView addSubview:nickName];
    
    return headView;

}

#pragma mark - 滑动表视图隐藏标签栏
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    UITabBarController *tabbarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (_lastOffset < scrollView.contentOffset.y) {
        
        [UIView animateWithDuration:.35
                         animations:^{
                             tabbarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 49);
                         }];
        
    } else {
    
        [UIView animateWithDuration:.35
                         animations:^{
                             tabbarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
                         }];
    
    }
    _lastOffset = scrollView.contentOffset.y;
    
}




#pragma mark - 懒加载
- (NSMutableArray *)seeLayoutList {

    if (_seeLayoutList == nil) {
        _seeLayoutList = [NSMutableArray array];
    }
    return _seeLayoutList;
    
}


#pragma mark - 通知，点赞修改frame，更新显示点赞详情列表
- (void)reloadDataNotification:(NSNotification *)notification {

    // 判断是否未空，如果为空则需要创建，不为空再说
    
    // 查找列表中是否存在我，判断是否已经点赞
    // 如果已经点赞，则将我从列表中移除
    // 如果没有点赞，则将我存入列表
    // 之前字段praise对应的是普通数组，不能操作里边的元素。必须改成可变数组
    NSInteger indexpathRow =  [notification.object integerValue];
    SeeLayout *seeLayout = self.seeLayoutList[indexpathRow];
    
    if (seeLayout.seeModel.praise.count == 0) {
        seeLayout.seeModel.praise = [NSMutableArray array];
        PraiseModel *newPraise = [[PraiseModel alloc] init];
        newPraise.user_id = [USER_D objectForKey:@"user_id"];
        newPraise.nickname = [USER_D objectForKey:@"nickname"];
        [seeLayout.seeModel.praise addObject:newPraise];
        
        
        
    } else {
        
        for (int i = 0; i < seeLayout.seeModel.praise.count; i++) {
            PraiseModel *praise = seeLayout.seeModel.praise[i];
            // 如果已经点赞
            if (praise.user_id == [USER_D objectForKey:@"user_id"]) {
                if (seeLayout.seeModel.praise.count == 1) {
                    [seeLayout.seeModel.praise removeAllObjects];
                    break;
                } else {
                    [seeLayout.seeModel.praise removeObjectAtIndex:i];
                    break;
                }
            }
            
            // 找到最后还是没能找到我(注意啊，i要取最后一个，计数要-1，刚刚就在这被误导了！！！必须-1)
            if (i == (seeLayout.seeModel.praise.count - 1)) {
                PraiseModel *newPraise = [[PraiseModel alloc] init];
                newPraise.user_id = [USER_D objectForKey:@"user_id"];
                newPraise.nickname = [USER_D objectForKey:@"nickname"];
                [seeLayout.seeModel.praise insertObject:newPraise atIndex:0];
                break;
            }
        }
    }
    
    // for循环重新设置model，就会重新计算frame，最后再刷新表视图
    NSMutableArray *newArray = [NSMutableArray array];
    for (SeeLayout *tempLayout in self.seeLayoutList) {
        SeeLayout *newLayout = [[SeeLayout alloc] init];
        newLayout.seeModel = tempLayout.seeModel;
        [newArray addObject:newLayout];
    }
    self.seeLayoutList = newArray;
    
    // 刷新表视图
    [self reloadData];
    

}
- (void)deleteRowNotification:(NSNotification *)notification {

    NSInteger indexpathRow =  [notification.object integerValue];
    [self.seeLayoutList removeObjectAtIndex:indexpathRow];
    [self reloadData];

}



























@end



















/*
 
 被丢弃的垃圾
 
 //    cell.headImage = _headImgArr[indexPath.row];
 // 判断数组中对应的这个元素是不是图像
 //    id image = _aboutImgArr[indexPath.row];
 //    if ([image isKindOfClass:[UIImage class]]) {
 //        cell.aboutImage = _aboutImgArr[indexPath.row];
 //    }

 //    [imageView setImage:_selfHeadImage];
 
 //    [headImageView setImage:_selfHeadImage];
 
 #pragma mark - 懒加载
 //- (NSMutableArray *)headImgArr {
 //
 //    if (_headImgArr == nil) {
 //        _headImgArr = [NSMutableArray array];
 //    }
 //    return _headImgArr;
 //
 //}
 
 //- (NSMutableArray *)aboutImgArr {
 //
 //    if (_aboutImgArr == nil) {
 //        _aboutImgArr = [NSMutableArray array];
 //    }
 //    return _aboutImgArr;
 //
 //}
 
 //- (void)setSelfHeadImage:(UIImage *)selfHeadImage {
 //
 //    _selfHeadImage = selfHeadImage;
 //
 //}
 
 
 
*/

















