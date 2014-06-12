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
#import "HRYSwap.h"

const NSInteger HRYLevelNumColumns = 9;
const NSInteger HRYLevelNumRows    = 9;

@interface HRYLevel ()

@property (nonatomic, strong) NSSet *possibleSwaps;

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
    NSSet *set;

    do {
        set = [self p_createInitialCookies];

        [self p_detectPossibleSwaps];

        NSLog(@"possible swaps: %@", self.possibleSwaps);
    }
    while ([self.possibleSwaps count] == 0);

    return set;
}

- (void)performSwap:(HRYSwap *)swap {
    NSInteger columnA = swap.cookieA.column;
    NSInteger rowA = swap.cookieA.row;
    NSInteger columnB = swap.cookieB.column;
    NSInteger rowB = swap.cookieB.row;

    _cookies[columnA][rowA] = swap.cookieB;
    swap.cookieB.column = columnA;
    swap.cookieB.row = rowA;

    _cookies[columnB][rowB] = swap.cookieA;
    swap.cookieA.column = columnB;
    swap.cookieA.row = rowB;
}

#pragma mark - Private

- (NSSet *)p_createInitialCookies {
    NSMutableSet *set = [NSMutableSet set];

    // NOTE: column 0, row 0 is in the bottom-left corner of the 2D grid.
    for (NSInteger row = 0; row < HRYLevelNumRows; row++) {

        for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {

            if (_tiles[column][row]) {

                // Picks a random cookie type
                NSUInteger cookieType;

                // Only look to the left or below because there are no cookies yet on the right or above
                do {
                    cookieType = arc4random_uniform(HRYCookieNumCookieTypes) + 1;
                }
                while ((column >= 2 &&
                        _cookies[column - 1][row].cookieType == cookieType &&
                        _cookies[column - 2][row].cookieType == cookieType)
                       ||
                       (row >= 2 &&
                        _cookies[column][row - 1].cookieType == cookieType &&
                        _cookies[column][row - 2].cookieType == cookieType));

                /*
                 * do {
                 *     generate a new random number between 1 and 6
                 * }
                 * while (there are already two cookies fo this type to the left
                 *     or there are already two cookies of this type below);
                 */

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

- (BOOL)p_hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
    NSUInteger cookieType = _cookies[column][row].cookieType;

    NSUInteger horzLength = 1;

    // Look left
    for (NSInteger i = column - 1;
         i >= 0 && _cookies[i][row].cookieType == cookieType; i--, horzLength++);

    // Look right
    for (NSInteger i = column + 1;
         i < HRYLevelNumColumns && _cookies[i][row].cookieType == cookieType; i++, horzLength++);

    if (horzLength >= 3) {
        return YES;
    }

    NSUInteger vertLength = 1;

    // Look below (row 0 is at the bottom)
    for (NSInteger i = row - 1;
         i >= 0 && _cookies[column][i].cookieType == cookieType; i--, vertLength++);

    // Look above
    for (NSInteger i = row + 1;
         i < HRYLevelNumRows && _cookies[column][i].cookieType == cookieType; i++, vertLength++);

    return (vertLength >= 3);
}

- (void)p_detectPossibleSwaps {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger row = 0; row < HRYLevelNumRows; row++) {

        for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {
            HRYCookie *cookie = _cookies[column][row];

            if (cookie) {

                // Is is possible to swap this cookie with the one on the right?
                if (column < HRYLevelNumColumns - 1) {

                    // Have a cookie in this spot? If there is no tile, there is no cookie.
                    HRYCookie *other = _cookies[column + 1][row];

                    if (other) {

                        // Swap them
                        _cookies[column][row] = other;
                        _cookies[column + 1][row] = cookie;

                        // Is either cookie now part of a chain?
                        if ([self p_hasChainAtColumn:column + 1 row:row] ||
                            [self p_hasChainAtColumn:column row:row]) {
                            HRYSwap *swap = [[HRYSwap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }

                        // Swap them back
                        _cookies[column][row] = cookie;
                        _cookies[column + 1][row] = other;
                    }
                }

                // Is is possible to swap this cookie with the one on the above?
                if (row < HRYLevelNumRows - 1) {
                    HRYCookie *other = _cookies[column][row + 1];

                    if (other) {
                        // Swap them
                        _cookies[column][row] = other;
                        _cookies[column][row + 1] = cookie;

                        if ([self p_hasChainAtColumn:column row:row + 1] ||
                            [self p_hasChainAtColumn:column row:row]) {
                            HRYSwap *swap = [[HRYSwap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }

                        _cookies[column][row] = cookie;
                        _cookies[column][row + 1] = other;
                    }
                }
            }
        }
    }

    self.possibleSwaps = set;
}

@end
