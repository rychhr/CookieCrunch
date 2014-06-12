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
#import "HRYSwap.h"

static const CGFloat kTileWidth  = 32.0f;
static const CGFloat kTileHeight = 36.0f;

@interface HRYMyScene ()

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *cookiesLayer;
@property (nonatomic, strong) SKNode *tilesLayer;
@property (nonatomic, assign) NSInteger swipeFromColumn;
@property (nonatomic, assign) NSInteger swipeFromRow;
@property (nonatomic, strong) SKSpriteNode *selectionSprite;

@end

@implementation HRYMyScene

#pragma mark - Lifecycle

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

        _swipeFromColumn = _swipeFromRow = NSNotFound;

        _selectionSprite = [SKSpriteNode node];
    }

    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cookiesLayer];

    NSInteger column, row;

    // Check whether the touch is inside a square on the level grid, or not.
    if ([self p_convertPoint:location toColumn:&column row:&row]) {
        HRYCookie *cookie = [self.level cookieAtColumn:column row:row];

        // Verify that the touch is on a cookie rather than on an empty square
        if (cookie) {
            [self p_showSelectionIndicatorForCookie:cookie];

            // Record the start point of a swipe motion
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Either the swipe began outside the valid area or the game has already swapped the cookies
    if (self.swipeFromColumn == NSNotFound) return;

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cookiesLayer];

    NSInteger column, row;

    if ([self p_convertPoint:location toColumn:&column row:&row]) {
        NSInteger horzDelta = 0, vertDelta = 0;

        if (column < self.swipeFromColumn) {       // Swiping left
            horzDelta = -1;
        }
        else if (column > self.swipeFromColumn) {  // Swiping right
            horzDelta = 1;
        }
        else if (row < self.swipeFromRow) {        // Swiping down
            vertDelta = -1;
        }
        else if (row > self.swipeFromRow) {        // Swiping up
            vertDelta = 1;
        }

        if (horzDelta != 0 || vertDelta != 0) {
            // Perform the swap if the player swiped out of the old square
            [self p_trySwapHorizontal:horzDelta vertical:vertDelta];

            [self p_hideSelectionIndicator];

            // The game will ignore the rest of this swipe motion
            self.swipeFromColumn = NSNotFound;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;

    if (self.selectionSprite.parent && self.swipeFromColumn != NSNotFound) {
        [self p_hideSelectionIndicator];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
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

- (void)animateSwap:(HRYSwap *)swap completion:(dispatch_block_t)completion {
    // Put the cookie you started with on top.
    swap.cookieA.sprite.zPosition = 100.0f;
    swap.cookieB.sprite.zPosition = 90.0f;

    const NSTimeInterval duration = 0.3;

    SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:duration];
    moveA.timingMode = SKActionTimingEaseOut;

    [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];

    SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:duration];
    moveB.timingMode = SKActionTimingEaseOut;

    [swap.cookieB.sprite runAction:moveB];
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

- (BOOL)p_convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);

    // Is this a valid location within the cookies layer?
    // If yes, calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < HRYLevelNumColumns * kTileWidth &&
        point.y >= 0 && point.y < HRYLevelNumRows * kTileHeight) {
        *column = point.x / kTileWidth;
        *row = point.y / kTileHeight;

        return YES;
    }
    else {
        *column = NSNotFound;  // Invalid location
        *row = NSNotFound;

        return NO;
    }
}

- (void)p_trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;

    // Outside the 9x9 grid
    if (toColumn < 0 || toColumn >= HRYLevelNumColumns) return;
    if (toRow < 0 || toRow >= HRYLevelNumRows) return;

    HRYCookie *toCookie = [self.level cookieAtColumn:toColumn row:toRow];
    if (!toCookie) return;

    HRYCookie *fromCookie = [self.level cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];

    if (self.swipeHandler) {
        HRYSwap *swap = [[HRYSwap alloc] init];
        swap.cookieA = fromCookie;
        swap.cookieB = toCookie;

        self.swipeHandler(swap);
    }
}

- (void)p_showSelectionIndicatorForCookie:(HRYCookie *)cookie {
    // If the selection is still visible, then first remove it.
    if (self.selectionSprite.parent) {
        [self.selectionSprite removeFromParent];
    }

    SKTexture *texture = [SKTexture textureWithImageNamed:[cookie highlightedSpriteName]];
    self.selectionSprite.size = texture.size;
    [self.selectionSprite runAction:[SKAction setTexture:texture]];

    [cookie.sprite addChild:self.selectionSprite];
    self.selectionSprite.alpha = 1.0f;
}

- (void)p_hideSelectionIndicator {
    [self.selectionSprite runAction:[SKAction sequence:@[
        [SKAction fadeOutWithDuration:0.3],
        [SKAction removeFromParent]
    ]]];
}

@end
