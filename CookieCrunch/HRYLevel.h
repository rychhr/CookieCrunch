//
//  HRYLevel.h
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import Foundation;

@class HRYCookie;
@class HRYTile;
@class HRYSwap;
@class HRYChain;

extern const NSInteger HRYLevelNumColumns;
extern const NSInteger HRYLevelNumRows;

@interface HRYLevel : NSObject

- (instancetype)initWithFile:(NSString *)filename;

- (HRYTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
- (HRYCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;

- (NSSet *)shuffle;
- (void)performSwap:(HRYSwap *)swap;

- (BOOL)isPossibleSwap:(HRYSwap *)swap;

- (NSSet *)removeMatches;

/**
 *  This method detects where there are empty tiles and shifts any cookies down to fill up those tiles.
 *
 *  @return an array containing all the cookies that have been moved down, organized by column.
 */
- (NSArray *)fillHoles;

@end
