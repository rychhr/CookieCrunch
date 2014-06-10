//
//  HRYMyScene.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYMyScene.h"

@implementation HRYMyScene

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self) {
        self.anchorPoint = CGPointMake(0.5f, 0.5f);

        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        [self addChild:background];
    }

    return self;
}

@end
