//
//  CXNetwork.m
//  CXLaunchAd
//
//  Created by 陈晓辉 on 2018/10/9.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXNetwork.h"

@implementation CXNetwork

/**
 *  此处模拟广告数据请求,实际项目中请做真实请求
 */
+(void)getLaunchAdImageDataSuccess:(NetworkSucess)success failure:(NetworkFailure)failure;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LaunchImageAd" ofType:@"json"]];
        NSDictionary *json =  [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        if(success) success(json);
        
    });
}
/**
 *  此处模拟广告数据请求,实际项目中请做真实请求
 */
+(void)getLaunchAdVideoDataSuccess:(NetworkSucess)success failure:(NetworkFailure)failure;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LaunchVideoAd" ofType:@"json"]];
        NSDictionary *json =  [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        if(success) success(json);
        
    });
}

@end
