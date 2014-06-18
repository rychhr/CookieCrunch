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
#import "HRYChain.h"

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

        _targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        _maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
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

        [self detectPossibleSwaps];

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

- (BOOL)isPossibleSwap:(HRYSwap *)swap {
    return [self.possibleSwaps containsObject:swap];
}

- (void)detectPossibleSwaps {
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

- (NSSet *)removeMatches {
    NSSet *horizontalChains = [self p_detectHorizontalMatches];
    NSSet *verticalChains = [self p_detectVerticalMatches];

    [self p_removeCookies:horizontalChains];
    [self p_removeCookies:verticalChains];

    [self p_calculateScores:horizontalChains];
    [self p_calculateScores:verticalChains];

    // Combine results into a single set
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (NSArray *)fillHoles {
    NSMutableArray *columns = [@[] mutableCopy];

    for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {
        NSMutableArray *array;

        for (NSInteger row = 0; row < HRYLevelNumRows; row++) {

            if (_tiles[column][row] && !_cookies[column][row]) {

                for (NSInteger lookup = row + 1; lookup < HRYLevelNumRows; lookup++) {
                    HRYCookie *cookie = _cookies[column][lookup];

                    if (cookie) {
                        _cookies[column][lookup] = nil;
                        _cookies[column][row] = cookie;
                        cookie.row = row;

                        if (!array) {
                            array = [@[] mutableCopy];
                            [columns addObject:array];
                        }
                        [array addObject:cookie];

                        break;
                    }
                }
            }
        }
    }

    return [columns copy];
}

- (NSArray *)topUpCookies {
    NSMutableArray *columns = [@[] mutableCopy];

    NSUInteger cookieType = 0;

    for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {
        NSMutableArray *array;

        // Loop through the column from top to bottom
        for (NSInteger row = HRYLevelNumRows - 1; row >= 0 && !_cookies[column][row]; row--) {

            // Ignore gaps in the level
            if (_tiles[column][row]) {
                NSUInteger newCookieType;

                do {
                    newCookieType = arc4random_uniform(HRYCookieNumCookieTypes) + 1;
                } while (newCookieType == cookieType);

                cookieType = newCookieType;

                HRYCookie *cookie = [self p_createCookieAtColumn:column row:row withType:cookieType];

                if (!array) {
                    array = [@[] mutableCopy];
                    [columns addObject:array];
                }
                [array addObject:cookie];
            }
        }
    }

    return [columns copy];
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

- (NSSet *)p_detectHorizontalMatches {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger row = 0; row < HRYLevelNumRows; row++) {

        // 1. the cookies at the last two columns can never begin a new chain.
        // 2. the incrementing happens conditionally inside the loop body.
        for (NSInteger column = 0; column < HRYLevelNumColumns - 2;) {

            if (_cookies[column][row]) {
                NSUInteger matchType = _cookies[column][row].cookieType;

                if (_cookies[column + 1][row].cookieType == matchType &&
                    _cookies[column + 2][row].cookieType == matchType) {
                    HRYChain *chain = [[HRYChain alloc] init];
                    chain.chainType = HRYChainTypeHorizontal;

                    do {
                        [chain addCookie:_cookies[column][row]];
                        column += 1;
                    }
                    while (column < HRYLevelNumColumns && _cookies[column][row].cookieType == matchType);

                    [set addObject:chain];

                    continue;
                }
            }

            // There is no chain, so skip over the cookie.
            column += 1;
        }
    }

    return [set copy];
}

- (NSSet *)p_detectVerticalMatches {
    NSMutableSet *set = [NSMutableSet set];

    for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {

        for (NSInteger row = 0; row < HRYLevelNumRows - 2;) {

            if (_cookies[column][row]) {
                NSUInteger matchType = _cookies[column][row].cookieType;

                if (_cookies[column][row + 1].cookieType == matchType &&
                    _cookies[column][row + 2].cookieType == matchType) {
                    HRYChain *chain = [[HRYChain alloc] init];
                    chain.chainType = HRYChainTypeVertical;

                    do {
                        [chain addCookie:_cookies[column][row]];
                        row += 1;
                    }
                    while (row < HRYLevelNumRows && _cookies[column][row].cookieType == matchType);

                    [set addObject:chain];

                    continue;
                }
            }

            row += 1;
        }
    }

    return [set copy];
}

- (void)p_removeCookies:(NSSet *)chains {
    for (HRYChain *chain in chains) {
        for (HRYCookie *cookie in chain.cookies) {
            _cookies[cookie.column][cookie.row] = nil;
        }
    }
}

- (void)p_calculateScores:(NSSet *)chains {
    for (HRYChain *chain in chains) {
        chain.score = 60 * ([chain.cookies count] - 2);
    }
}

@end
