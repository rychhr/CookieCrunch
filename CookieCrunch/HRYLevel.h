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

extern const NSInteger HRYLevelNumColumns;
extern const NSInteger HRYLevelNumRows;

@interface HRYLevel : NSObject

- (instancetype)initWithFile:(NSString *)filename;

- (HRYTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
- (HRYCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;

- (NSSet *)shuffle;
- (void)performSwap:(HRYSwap *)swap;

- (BOOL)isPossibleSwap:(HRYSwap *)swap;

@end
