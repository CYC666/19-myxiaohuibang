//
//  CNetTool.m
//  XiaoHuiBang
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 消汇邦. All rights reserved.
//

#import "CNetTool.h"

@implementation CNetTool


// 获取动态
+ (void)loadAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure{

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_see";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];


}


// 发表动态(不含图片)
+ (void)postAboutWithParameters:(id)parameters
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}




// 发表动态(含图片)
+ (void)postAboutWithParameters:(id)parameters
                           data:(NSData *)data
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_publish";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           [formData appendPartWithFileData:data name:@"file" fileName:@"user.jpg" mimeType:@"image/jpg"];
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];
    

}


// 点赞功能
+ (void)postProWithParameters:(id)parameters
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_praise";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];


}


// 删除动态
+ (void)deleteAboutWithParameters:(id)parameters
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure {

    NSString *urlStr = @"http://115.28.6.7/rongyun.php/Home/about/about_remove";
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [session POST:urlStr
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
       } progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              success(responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(error);
          }];

}





























@end
