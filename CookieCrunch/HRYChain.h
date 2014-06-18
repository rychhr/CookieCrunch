//
//  HRYChain.h
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import Foundation;

@class HRYCookie;

typedef NS_ENUM(NSUInteger, HRYChainType) {
    HRYChainTypeHorizontal,
    HRYChainTypeVertical,
};

@interface HRYChain : NSObject

@property (nonatomic, copy, readonly) NSArray *cookies;
@property (nonatomic, assign) HRYChainType chainType;
@property (nonatomic, assign) NSUInteger score;

- (void)addCookie:(HRYCookie *)cookie;

@end
