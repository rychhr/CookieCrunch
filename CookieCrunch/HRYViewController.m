//
//  HRYViewController.m
//  CookieCrunch
//
//  Created by Ryoichi Hara on 2014/06/10.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HRYViewController.h"
#import "HRYMyScene.h"
#import "HRYLevel.h"

@interface HRYViewController ()

@property (nonatomic, strong) HRYLevel *level;
@property (nonatomic, strong) HRYMyScene *scene;

@end

@implementation HRYViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;

#ifdef DEBUG
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
#endif

    // Create and configure the scene.
    self.scene = [HRYMyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;

    // Load the level.
    self.level = [[HRYLevel alloc] initWithFile:@"Level_1"];
    self.scene.level = self.level;

    // Add tiles
    [self.scene addTiles];

    void (^swipeHandler)(HRYSwap *) = ^(HRYSwap *swap) {
        self.view.userInteractionEnabled = NO;

        if ([self.level isPossibleSwap:swap]) {
            [self.level performSwap:swap];
            [self.scene animateSwap:swap completion:^{
                [self p_handleMatches];
            }];
        }
        else {
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    };

    self.scene.swipeHandler = swipeHandler;

    // Present the scene.
    [skView presentScene:self.scene];

    // Let's start the game!
    [self p_beginGame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Orientations

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

#pragma mark - Private

- (void)p_beginGame {
    [self p_shuffle];
}

- (void)p_shuffle {
    NSSet *newCookies = [self.level shuffle];
    [self.scene addSpritesForCookies:newCookies];
}

- (void)p_handleMatches {
    NSSet *chains = [self.level removeMatches];

    [self.scene animateMatchedCookies:chains completion:^{
        NSArray *columns = [self.level fillHoles];

        [self.scene animateFallingCookies:columns completion:^{
            NSArray *columns = [self.level topUpCookies];

            [self.scene animateNewCookies:columns completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }];
    }];
}

@end
