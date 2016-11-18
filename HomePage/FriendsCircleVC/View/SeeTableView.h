//
//  SeeTableView.h
//  XiaoHuiBang
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

// 动态表视图


#import <UIKit/UIKit.h>

@interface SeeTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *seeLayoutList;   // 储存动态内容和动态布局的数组

@property (assign, nonatomic) float lastOffset;                // 上次位置

@end






















/*
 
 //@property (strong, nonatomic) UIImage *selfHeadImage;   // 自己的头像
 //@property (strong, nonatomic) NSMutableArray *headImgArr;   // 头像数组
 //@property (strong, nonatomic) NSMutableArray *aboutImgArr;  // 动态图像数组
 
 
 
 
 
 
*/














