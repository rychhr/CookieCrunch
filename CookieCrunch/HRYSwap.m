//
//  HRYSwap.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/11.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYSwap.h"

@implementation HRYSwap

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

@end
