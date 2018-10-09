//
//  CXLaunchAdModel.m
//  CXLaunchAd
//
//  Created by 陈晓辉 on 2018/10/9.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXLaunchAdModel.h"

@implementation CXLaunchAdModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        self.content = dict[@"content"];
        self.openUrl = dict[@"openUrl"];
        self.duration = [dict[@"duration"] integerValue];
        self.contentSize = dict[@"contentSize"];
    }
    return self;
}
-(CGFloat)width
{
    return [[[self.contentSize componentsSeparatedByString:@"*"] firstObject] floatValue];
}
-(CGFloat)height
{
    return [[[self.contentSize componentsSeparatedByString:@"*"] lastObject] floatValue];
}

@end
