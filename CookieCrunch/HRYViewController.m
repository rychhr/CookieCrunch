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
#import "HRYChain.h"

@interface HRYViewController ()

@property (nonatomic, strong) HRYLevel *level;
@property (nonatomic, strong) HRYMyScene *scene;

@property (nonatomic, assign) NSUInteger movesLeft;
@property (nonatomic, assign) NSUInteger score;

@property (nonatomic, weak) IBOutlet UILabel *targetLabel;
@property (nonatomic, weak) IBOutlet UILabel *movesLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;

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
    self.movesLeft = self.level.maximumMoves;
    self.score = 0;
    [self p_updateLabels];

    [self p_shuffle];
}

- (void)p_shuffle {
    NSSet *newCookies = [self.level shuffle];
    [self.scene addSpritesForCookies:newCookies];
}

- (void)p_handleMatches {
    NSSet *chains = [self.level removeMatches];

    if ([chains count] == 0) {
        [self p_beginNextTurn];
        return;
    }

    [self.scene animateMatchedCookies:chains completion:^{

        // Add the new scores to the total.
        for (HRYChain *chain in chains) {
            self.score += chain.score;
        }
        [self p_updateLabels];

        NSArray *columns = [self.level fillHoles];

        [self.scene animateFallingCookies:columns completion:^{
            NSArray *columns = [self.level topUpCookies];

            [self.scene animateNewCookies:columns completion:^{
                [self p_handleMatches];
            }];
        }];
    }];
}

- (void)p_beginNextTurn {
    [self.level detectPossibleSwaps];
    self.view.userInteractionEnabled = YES;
}

- (void)p_updateLabels {
    self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
    self.movesLabel.text = [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)self.score];
}

@end
