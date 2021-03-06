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
#import "RankManager.h"

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
    
    RankManager *rankManager = [RankManager rankManager:[[GameData sharedData] winHistory]
                                       currentRankTitle:[[GameData sharedData] currentRankTitle]
                                       currentRankLevel:[[GameData sharedData] currentRankLevel]];
    
    // Assing new currentRank (NSDictionary) to GameData
    [GameData sharedData].currentRank = rankManager.outputRank;
    
    NSLog(@"New rank title: %@", rankManager.outputRank);
    
    // NSString *previousRankTitle = [GameData sharedData].currentRankTitle copy];
    // [GameData sharedData].currentRankTitle = [rank determineNewRank];
    // NSString *newRankMessage;
    // if ([rank determineNewRank] isNotEqual: previousRankTitle && BOOL TRUE) {
    //      newRankMessage = @"Congratulations! Moving on up!
    // } else {
    //      newRankMessage = @"Don't get discouraged. You've got talent, kid!
    // }
    
    SKLabelNode *messageLabel = [SKLabelNode labelNodeWithText:
                                 [NSString stringWithFormat:@"%d wins out of 15. %@",[[GameData sharedData] latestResult], commentary]];
    messageLabel.position = CGPointMake(self.anchorPoint.x, self.anchorPoint.y);
    messageLabel.fontColor = [UIColor whiteColor];
    messageLabel.fontSize = 20;
    messageLabel.fontName = GAME_FONT;
    [self addChild:messageLabel];
    
    SKLabelNode *rankLabel = [SKLabelNode labelNodeWithText:
                              [NSString stringWithFormat:@"Rank: %@", [[GameData sharedData] currentRankTitle]]];
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
    
    SKLabelNode *playAgainButtonText = [SKLabelNode labelNodeWithText:@"Play Again"];
    playAgainButtonText.name = @"playAgainButton";
    playAgainButtonText.fontColor = [UIColor whiteColor];
    playAgainButtonText.fontSize = 20;
    playAgainButtonText.fontName = GAME_FONT;
    
    SKSpriteNode *playAgainButtonBacking = [SKSpriteNode
                                            spriteNodeWithColor:[UIColor blueColor]
                                            size:CGSizeMake(self.size.width/4, self.size.height/9)];
    playAgainButtonBacking.name = @"playAgainButton";
    playAgainButtonBacking.position = CGPointMake(0, -self.size.height/3);
    [playAgainButtonBacking addChild:playAgainButtonText];
    playAgainButtonText.position = CGPointMake(0, -playAgainButtonBacking.size.height/5);
    [self addChild:playAgainButtonBacking];
    
    SKLabelNode *resetButtonText = [SKLabelNode labelNodeWithText:@"reset stats"];
    resetButtonText.name = @"resetButton";
    resetButtonText.fontColor = [UIColor whiteColor];
    resetButtonText.fontSize = 15;
    resetButtonText.fontName = GAME_FONT;
    
    SKSpriteNode *resetButtonBacking = [SKSpriteNode
                                            spriteNodeWithColor:[UIColor redColor]
                                            size:CGSizeMake(self.size.width/7, self.size.width/20)];
    resetButtonBacking.name = @"resetButton";
    resetButtonBacking.position = CGPointMake(0.8 * -self.size.width/2, 0.85 * -self.size.height/2);
    [resetButtonBacking addChild:resetButtonText];
    resetButtonText.position = CGPointMake(0, -resetButtonBacking.size.height/5);
    [self addChild:resetButtonBacking];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
        
    if ([node.name isEqualToString:@"playAgainButton"]) {
        [self newGameScene];
    }
    
    if ([node.name isEqualToString:@"resetButton"]) {
        [[GameData sharedData] reset];
        [[GameData sharedData] save];
    }
}

-(void)newGameScene
{
    SKScene *newGameScene  = [[GameScene alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0 ],
                                         [SKAction runBlock:^{
        [self.view presentScene:newGameScene transition:doors];
    }]]]];
}

@end
