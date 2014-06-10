//
//  HRYLevel.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYLevel.h"
#import "HRYCookie.h"

const NSInteger HRYLevelNumColumns = 9;
const NSInteger HRYLevelNumRows    = 9;

@interface HRYLevel ()

@end

@implementation HRYLevel {
    // The 2D array that keeps track of where the RWTCookies are.
    HRYCookie *_cookies[HRYLevelNumColumns][HRYLevelNumRows];
}

#pragma mark - Public

- (HRYCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    // Verify that the specified column and row numbers are withinthe valid range of 0-8.
    // C-arrays don't check that the index you specify is within bounds.
    NSAssert1(column >= 0 && column < HRYLevelNumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < HRYLevelNumRows, @"Invalid row: %ld", (long)row);

    return _cookies[column][row];
}

- (NSSet *)shuffle {
    return [self p_createInitialCookies];
}

#pragma mark - Private

- (NSSet *)p_createInitialCookies {
    NSMutableSet *set = [NSMutableSet set];

    // NOTE: column 0, row 0 is in the bottom-left corner of the 2D grid.
    for (NSInteger row = 0; row < HRYLevelNumRows; row++) {

        for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {

            // Picks a random cookie type
            NSUInteger cookieType = arc4random_uniform(HRYCookieNumCookieTypes) + 1;

            HRYCookie *cookie = [self p_createCookieAtColumn:column row:row withType:cookieType];
            [set addObject:cookie];
        }
    }

    return set;
}

- (HRYCookie *)p_createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType {
    HRYCookie *cookie = [[HRYCookie alloc] init];
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;

    return cookie;
}

@end
