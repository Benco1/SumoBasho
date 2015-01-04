//
//  GameScene.h
//  SumoBasho
//

//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) int heroPoints;
@property (nonatomic) int opponentPoints;
@property (nonatomic) NSString *matchWinner;

@end
