//
//  HRYCookie.h
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import Foundation;

@class SKSpriteNode;

extern const NSUInteger HRYCookieNumCookieTypes;

@interface HRYCookie : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSUInteger cookieType;
@property (nonatomic, strong) SKSpriteNode *sprite;

- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end
