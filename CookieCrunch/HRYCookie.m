//
//  HRYCookie.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYCookie.h"

const NSUInteger HRYCookieNumCookieTypes = 6;

@implementation HRYCookie

- (NSString *)spriteName {
    static NSString * const spriteNames[] = {
        @"Croissant",
        @"Cupcake",
        @"Danish",
        @"Donut",
        @"Macaroon",
        @"SugarCookie",
    };

    return spriteNames[self.cookieType - 1];
}

- (NSString *)highlightedSpriteName {
    static NSString * const highlightedSpriteNames[] = {
        @"Croissant-Highlighted",
        @"Cupcake-Highlighted",
        @"Danish-Highlighted",
        @"Donut-Highlighted",
        @"Macaroon-Highlighted",
        @"SugarCookie-Highlighted",
    };

    return highlightedSpriteNames[self.cookieType - 1];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld, %ld)",
            (long)self.cookieType, (long)self.column, (long)self.row];
}

@end
