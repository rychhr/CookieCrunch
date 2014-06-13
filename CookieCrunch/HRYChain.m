//
//  HRYChain.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYChain.h"

@interface HRYChain ()

@end

@implementation HRYChain {
    NSMutableArray *_cookies;
}

#pragma mark - Accessors

- (NSArray *)cookies {
    return [_cookies copy];
}

#pragma mark - Public

- (void)addCookie:(HRYCookie *)cookie {
    if (!_cookies) {
        _cookies = [@[] mutableCopy];
    }
    [_cookies addObject:cookie];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld cookies:%@", (long)self.chainType, self.cookies];
}

@end
