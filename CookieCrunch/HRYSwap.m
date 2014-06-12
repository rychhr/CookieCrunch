//
//  HRYSwap.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/11.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYSwap.h"
#import "HRYCookie.h"

@implementation HRYSwap

#pragma mark - Public (Override)

- (BOOL)isEqual:(id)object {
    // You can only compare this object against other HRYSwap objects.
    if (![object isKindOfClass:[self class]]) return NO;

    // Two swaps are equal if they contain the same cookie, but it doesn't
    // matter whether they're called A in one and B in the other.
    HRYSwap *other = (HRYSwap *)object;

    return (other.cookieA == self.cookieA && other.cookieB == self.cookieB) ||
           (other.cookieB == self.cookieA && other.cookieA == self.cookieB);
}

- (NSUInteger)hash {
    return [self.cookieA hash] ^ [self.cookieB hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

@end
