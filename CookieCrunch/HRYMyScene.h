//
//  HRYMyScene.h
//  CookieCrunch
//

//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import SpriteKit;

@class HRYLevel;
@class HRYSwap;

@interface HRYMyScene : SKScene

@property (nonatomic, strong) HRYLevel *level;
@property (nonatomic, copy) void (^swipeHandler)(HRYSwap *swap);

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

/**
 *  Move cookie A to the position of cookie B and vice versa.
 *
 *  @param swap
 *  @param completion simple shorthand for a block that returns void and takes no parameters
 */
- (void)animateSwap:(HRYSwap *)swap completion:(dispatch_block_t)completion;

- (void)animateInvalidSwap:(HRYSwap *)swap completion:(dispatch_block_t)completion;

- (void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion;

- (void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion;

@end
