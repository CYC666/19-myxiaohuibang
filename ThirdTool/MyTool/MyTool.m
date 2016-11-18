//
//  MyTool.m
//  XiaoHuiBang
//
//  Created by 消汇邦 on 16/9/28.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "MyTool.h"

#import "MyMessageListViewController.h"
#import "PersonageViewController.h"

#import "FriendsCircleViewController.h"

@implementation MyTool

//字典转json字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//json字符串转字典
+ (id)toArrayOrNSDictionary:(NSData *)jsonData {
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}

+ (void)toMainVCRequest {
    MyMessageListViewController *messageListVC = [[MyMessageListViewController alloc] init];
//    [messageListVC updateBadgeValueForTabBarItem];
    UINavigationController *messageListNAV = [[UINavigationController alloc] initWithRootViewController:messageListVC];
    messageListNAV.title = @"消信";
    messageListNAV.tabBarItem.image = [UIImage imageNamed:@"icon_xiaoxin_unselected_"];
    messageListNAV.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_xiaohui_selected-"];
    messageListNAV.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
    
    FriendsCircleViewController *friendCircleVC = [[FriendsCircleViewController alloc] init];
    UINavigationController *friendCircleNAV = [[UINavigationController alloc] initWithRootViewController:friendCircleVC];
    friendCircleNAV.title = @"邦友圈";
    friendCircleNAV.tabBarItem.image = [UIImage imageNamed:@"icon_moments_unselected"];
    friendCircleNAV.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_moments_selected_selected"];
    friendCircleNAV.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
    
    PersonageViewController *personageVC = [[PersonageViewController alloc] init];
    UINavigationController *personageNAV = [[UINavigationController alloc] initWithRootViewController:personageVC];
    personageNAV.title = @"我的";
    personageNAV.tabBarItem.image = [UIImage imageNamed:@"icon_profile_unselected"];
    personageNAV.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_profile_selected"];
    personageNAV.navigationBar.barTintColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:48.0/255.0 alpha:1.0];
    
    UITabBarController * tabbarController=[[UITabBarController alloc]init];
    tabbarController.tabBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    tabbarController.viewControllers=@[messageListNAV,friendCircleNAV,personageNAV];
    tabbarController.selectedIndex = 0;
    [tabbarController.tabBar setBackgroundImage:[UIImage imageNamed:@""]];
//    tabbarController.tabBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:124.0/255.0 blue:56.0/255.0 alpha:1];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    window.rootViewController = tabbarController;
}


@end
