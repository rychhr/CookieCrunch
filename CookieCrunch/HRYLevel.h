//
//  HRYLevel.h
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import Foundation;

@class HRYCookie;

extern const NSInteger HRYLevelNumColumns;
extern const NSInteger HRYLevelNumRows;

@interface HRYLevel : NSObject

- (NSSet *)shuffle;
- (HRYCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;

@end
