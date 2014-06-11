//
//  HRYLevel.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYLevel.h"
#import "HRYCookie.h"
#import "HRYTile.h"

const NSInteger HRYLevelNumColumns = 9;
const NSInteger HRYLevelNumRows    = 9;

@interface HRYLevel ()

@end

@implementation HRYLevel {
    // The 2D array that keeps track of where the RWTCookies are.
    HRYCookie *_cookies[HRYLevelNumColumns][HRYLevelNumRows];

    // The 2D array that describes the structure of the level.
    HRYTile *_tiles[HRYLevelNumColumns][HRYLevelNumRows];
}

#pragma mark - Lifecycle

- (instancetype)initWithFile:(NSString *)filename {
    self = [super init];

    if (self) {
        NSDictionary *dictionary = [self p_loadJSON:filename];
        NSArray *tiles = dictionary[@"tiles"];

        // Loop through the rows
        [tiles enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {

            // Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {

                // NOTE: In SpriteKit (0, 0) is at the bottom of the screen.
                // so we need to read this file upside down.
                NSInteger tileRow = HRYLevelNumRows - row - 1;

                // If the value is 1, create a tile object.
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[HRYTile alloc] init];
                }
            }];
        }];
    }

    return self;
}

#pragma mark - Public

- (HRYTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < HRYLevelNumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < HRYLevelNumRows, @"Invalid row: %ld", (long)row);

    return _tiles[column][row];
}

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

            if (_tiles[column][row]) {

                // Picks a random cookie type
                NSUInteger cookieType = arc4random_uniform(HRYCookieNumCookieTypes) + 1;

                HRYCookie *cookie = [self p_createCookieAtColumn:column row:row withType:cookieType];
                [set addObject:cookie];
            }
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

- (NSDictionary *)p_loadJSON:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];

    if (!path) {
        NSLog(@"Could not find level file: %@", filename);
        return nil;
    }

    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];

    if (!data) {
        NSLog(@"Could not load level file: %@, error: %@", filename, error);
        return nil;
    }

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Level file '%@' is not valid JSON: %@", filename, error);
        return nil;
    }

    return dictionary;
}

@end
