//
//  ResultsScene.m
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "ResultsScene.h"
#import "GameScene.h"
#import "GameData.h"

@interface ResultsScene ()

@property BOOL contentCreated;

@end


@implementation ResultsScene

static NSString *GAME_FONT = @"AmericanTypewriter-Bold";
static NSString *GOOD_MESSAGE = @"Hmm. A future Yokozuna perhaps!";
static NSString *OK_MESSAGE = @"Fine performance, but not Yokozuna caliber ... yet.";
static NSString *BAD_MESSAGE = @"Ouch! Too much sake last night?";

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents

{
    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    int latestResult = [[GameData sharedData] latestResult];
    
    NSString *commentary;
    if (latestResult >= 10) {
        commentary = GOOD_MESSAGE;
    } else if (latestResult > 7 && latestResult < 10) {
        commentary = OK_MESSAGE;
    } else if (latestResult <= 7) {
        commentary = BAD_MESSAGE;
    }
    
    SKLabelNode *messageLabel = [SKLabelNode labelNodeWithText:
                                 [NSString stringWithFormat:@"%d wins out of 15. %@",[GameData sharedData].latestResult, commentary]];
    messageLabel.position = CGPointMake(self.anchorPoint.x, self.anchorPoint.y);
    messageLabel.fontColor = [UIColor whiteColor];
    messageLabel.fontSize = 20;
    messageLabel.fontName = GAME_FONT;
    [self addChild:messageLabel];
    
    SKLabelNode *rankLabel = [SKLabelNode labelNodeWithText:
                              [NSString stringWithFormat:@"Rank: %@", [GameData sharedData].currentRankTitle]];
    rankLabel.position = CGPointMake(self.anchorPoint.x, self.anchorPoint.y - 50);
    rankLabel.fontColor = [UIColor whiteColor];
    rankLabel.fontSize = 20;
    rankLabel.fontName = GAME_FONT;
    [self addChild:rankLabel];
    
    SKLabelNode *recordLabel = [SKLabelNode labelNodeWithText:
                                [NSString stringWithFormat:
                                 @"Career Record: %d - %d",
                                 [[GameData sharedData] totalWins],
                                 [[GameData sharedData] totalLosses]]];
    recordLabel.position = CGPointMake(self.anchorPoint.x, self.anchorPoint.y - 75);
    recordLabel.fontColor = [UIColor whiteColor];
    recordLabel.fontSize = 20;
    recordLabel.fontName = GAME_FONT;
    [self addChild:recordLabel];
}

@end
