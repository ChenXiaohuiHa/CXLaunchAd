//
//  CXNetwork.h
//  CXLaunchAd
//
//  Created by 陈晓辉 on 2018/10/9.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NetworkSucess) (NSDictionary * response);
typedef void(^NetworkFailure) (NSError *error);

@interface CXNetwork : NSObject

/**
 *  此处用于模拟广告数据请求,实际项目中请做真实请求
 */
+(void)getLaunchAdImageDataSuccess:(NetworkSucess)success failure:(NetworkFailure)failure;
+(void)getLaunchAdVideoDataSuccess:(NetworkSucess)success failure:(NetworkFailure)failure;

@end

NS_ASSUME_NONNULL_END
