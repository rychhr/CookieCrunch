//
//  HRYMyScene.h
//  CookieCrunch
//

//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import SpriteKit;

@class HRYLevel;

@interface HRYMyScene : SKScene

@property (nonatomic, strong) HRYLevel *level;

/**
 *  Iterates through the set of cookies and adds a corresponding SKSpriteNode instance to the cookie layer.
 *
 *  @param cookies an array of HRYCookie instance
 */
- (void)addSpritesForCookies:(NSSet *)cookies;

/**
 *  Creates a new tile sprite and adds it to the tiles layer.
 */
- (void)addTiles;

@end
