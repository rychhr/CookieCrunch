//
//  HRYMyScene.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYMyScene.h"
#import "HRYCookie.h"
#import "HRYLevel.h"

static const CGFloat kTileWidth  = 32.0f;
static const CGFloat kTileHeight = 36.0f;

@interface HRYMyScene ()

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *cookiesLayer;
@property (nonatomic, strong) SKNode *tilesLayer;

@end

@implementation HRYMyScene

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self) {
        self.anchorPoint = CGPointMake(0.5f, 0.5f);

        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        [self addChild:background];

        _gameLayer = [SKNode node];
        [self addChild:_gameLayer];

        CGPoint layerPosition = CGPointMake(
            -(kTileWidth * HRYLevelNumColumns) / 2,
            -(kTileHeight * HRYLevelNumRows) / 2
        );

        _tilesLayer = [SKNode node];
        _tilesLayer.position = layerPosition;
        [_gameLayer addChild:_tilesLayer];

        _cookiesLayer = [SKNode node];
        _cookiesLayer.position = layerPosition;

        [_gameLayer addChild:_cookiesLayer];
    }

    return self;
}

#pragma mark - Public

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (HRYCookie *cookie in cookies) {
        SKSpriteNode *sprite =[SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
        sprite.position = [self p_pointForColumn:cookie.column row:cookie.row];
        [self.cookiesLayer addChild:sprite];
        cookie.sprite = sprite;
    }
}

- (void)addTiles {
    for (NSInteger row = 0; row < HRYLevelNumRows; row++) {

        for (NSInteger column = 0; column < HRYLevelNumColumns; column++) {

            if ([self.level tileAtColumn:column row:row]) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
                tileNode.position = [self p_pointForColumn:column row:row];

                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}

#pragma mark - Private

/**
 *  Converts a column and row number into CGPoint that is relative to the cookieLayer
 *
 *  @param column
 *  @param row
 *
 *  @return the center of the cookie's SKSpriteNode
 */
- (CGPoint)p_pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column * kTileWidth + kTileWidth / 2, row * kTileHeight + kTileHeight / 2);
}

@end
