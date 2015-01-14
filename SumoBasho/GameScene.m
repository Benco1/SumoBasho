//
//  GameScene.m
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "GameScene.h"
#import "ResultsScene.h"
#import "Hero.h"
#import "GameData.h"
#import "RankManager.h"
#import "OpponentGenerator.h"
#import "GameLabel.h"

@implementation GameScene
{
    Hero *_hero;
    Hero *_opponent;
    int _currentPointsTotal;
    BOOL _didChargeOpponent;
    BOOL _isStarted;
    BOOL _isGameOver;
    BOOL _isAnimationA;
    BOOL _isBoostOn;
    SKNode *_mainLayer;
    SKSpriteNode *_boostLayer;
    CGPoint _touchLocation;
    SKShapeNode *_ring;
    GameLabel *_heroPointsLabel;
    GameLabel *_opponentPointsLabel;
    NSMutableDictionary *_opponentPool;
}

CGFloat static const STRENGTH_BASE = 20.0;
CGFloat static const HERO_STRENGTH_DILUTION = 1.0; // 1 = no dilution, 0 = full dilution = 0 strength
CGFloat static const STRENGTH_MAX = 50;

static NSString *GAME_FONT = @"AmericanTypewriter-Bold";

static const uint32_t ringCategory = 0x1 << 0;
static const uint32_t heroCategory = 0x1 << 1;
static const uint32_t opponentCategory = 0x1 << 2;

static inline CGVector toUnitVector(CGVector vector) {
    vector.dx /= sqrtf(vector.dx * vector.dx + vector.dy * vector.dy);
    vector.dy /= sqrtf(vector.dx * vector.dx + vector.dy * vector.dy);
    return vector;
}

static inline CGFloat randomInRange(CGFloat low, CGFloat high)
{
    // Get random value between 0 and 1;
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    
    // Scale, translate and return random value
    return value * (high - low) + low;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    // Anchor at center, gravity off and set physics boundary around view
    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"ClayBackground"];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    background.xScale = 2.0;
    background.yScale = 2.0;
    background.position = self.anchorPoint;
    background.anchorPoint = self.anchorPoint;
    background.zPosition = 0;
    [self addChild:background];
    
    SKTexture *ringTexture = [SKTexture textureWithImageNamed:@"Ring"];
    SKSpriteNode *ring = [SKSpriteNode spriteNodeWithTexture:ringTexture];
    ring.position = self.anchorPoint;
    ring.anchorPoint = self.anchorPoint;
    ring.zPosition = 0;
    [self addChild:ring];
    
    // Add MAINLAYER
    _mainLayer = [[SKNode alloc] init];
    [self addChild:_mainLayer];
    
    // Add BOOSTLAYER
    _boostLayer = [SKSpriteNode spriteNodeWithColor:0 size:CGSizeMake(self.size.width * 0.8, self.size.height * 0.7)];
    _boostLayer.position = CGPointMake(0, -self.size.height/20);
    _boostLayer.zPosition = 1;
    [self addChild:_boostLayer];

    // Add HERO POINTS labels
    _heroPointsLabel = [GameLabel gameLabelWithFontSize:20.0];
    _heroPointsLabel.position = CGPointMake(0.95 * -self.size.width/2, 0.85 * self.size.height/2);
    _heroPointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _heroPointsLabel.text = @"HERO: 0";
    [self addChild:_heroPointsLabel];
    
    // Add OPPONENT POINTS labels
    _opponentPointsLabel = [GameLabel gameLabelWithFontSize:20.0];
    _opponentPointsLabel.position = CGPointMake(0.95 * self.size.width/2, 0.85 * self.size.height/2);
    _opponentPointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _opponentPointsLabel.text = @"CPU: 0";
    [self addChild:_opponentPointsLabel];
    
    // Add RING BOUNDARY
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, 0, 0, 0.9 * self.size.height/2, 0, M_PI * 2, YES);
    _ring = [SKShapeNode shapeNodeWithPath:circlePath];
    _ring.position = CGPointMake(0.0, 0.0);
    _ring.zPosition = 1.0;
    _ring.strokeColor = [UIColor redColor];
    _ring.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:circlePath];
    _ring.physicsBody.categoryBitMask = ringCategory;
    _ring.physicsBody.collisionBitMask = 0;
    _ring.physicsBody.contactTestBitMask = heroCategory | opponentCategory;
    _ring.physicsBody.dynamic = NO;
    [self addChild:_ring];

    
    // Generate full pool of opponents' rank levels and titles
    _opponentPool = [OpponentGenerator opponentPool];
    
    if ([[GameData sharedData] totalMatches] == 0) {
        [[GameData sharedData] reset];
    }
    [self newGame];
}

-(void)newGame
{

    [_mainLayer removeAllChildren];
    
    // Re-apply ring bit mask
    _ring.physicsBody.categoryBitMask = ringCategory;
    
    // Randomly select next opponent rank level and title from those remaining in pool
    OpponentGenerator *opponent = [OpponentGenerator opponentFromPool:_opponentPool];
    
    GameLabel *tapToBeginLabel = [GameLabel gameLabelWithFontSize:20.0];
    tapToBeginLabel.name = @"tapToBeginLabel";
    tapToBeginLabel.text = @"tap to begin";
    [self addChild:tapToBeginLabel];
    [self animateWithPulse: tapToBeginLabel];
    
    // Add HERO RANK title label
    GameLabel *heroTitleLabel = [GameLabel gameLabelWithFontSize:15.0];
    heroTitleLabel.position = CGPointMake(0.95 * -self.size.width/2, 0.75 * self.size.height/2);
    heroTitleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    heroTitleLabel.text = [[GameData sharedData] currentRankTitle];
    [_mainLayer addChild:heroTitleLabel];
    
    // Add OPPONENT RANK title label
    GameLabel *opponentTitleLabel = [GameLabel gameLabelWithFontSize:15.0];
    opponentTitleLabel.position = CGPointMake(0.95 * self.size.width/2, 0.75 * self.size.height/2);
    opponentTitleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    opponentTitleLabel.text = [opponent rankTitle];
    [_mainLayer addChild:opponentTitleLabel];
    
    // Add user-controlled hero
    _hero = [Hero heroWithImage:@"SumoSprite_2" name:@"Hero" position:CGPointMake(-45, 0)];
    _hero.strength = [self calculateStrength:[[GameData sharedData] currentRankLevel]] * HERO_STRENGTH_DILUTION;
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.collisionBitMask = opponentCategory;
    [_mainLayer addChild:_hero];
    
    // Add computer-controlled opponent
    _opponent = [Hero heroWithImage:@"SumoSprite_2_Red" name:@"Opponent" position:CGPointMake(45, 0)];
    _opponent.strength = [self calculateStrength:[opponent rankLevel]];
    _opponent.physicsBody.categoryBitMask = opponentCategory;
    _opponent.physicsBody.collisionBitMask = heroCategory;
    [_mainLayer addChild:_opponent];
    
    [_hero runAction:[SKAction rotateByAngle: 0 duration:0.0]];
    [_opponent runAction:[SKAction rotateByAngle: M_PI duration:0.0]];
}

- (void)start
{
    [[self childNodeWithName:@"tapToBeginLabel"] removeFromParent];
    
    _isStarted = YES;
    
    // Run chargeHero method forever in sequence with wait timer
    SKAction *chargeHeroSequence = [SKAction sequence:@[[SKAction waitForDuration:0.5 withRange:0.2],
                                                        [SKAction performSelector:@selector(chargeHero) onTarget:self]]];
    [_mainLayer runAction:[SKAction repeatActionForever: chargeHeroSequence]];
    
    // Run randomized boost label flash sequence
    [_mainLayer runAction:[SKAction performSelector:@selector(flashBoostLabel) onTarget:self]];
}

// Turn hero and opponent to face each other
-(void)rotateToFace
{
    CGFloat opponentDirection = atan2(_opponent.position.y - _hero.position.y, _opponent.position.x - _hero.position.x);
    CGFloat heroDirection = atan2(_hero.position.y - _opponent.position.y, _hero.position.x - _opponent.position.x);
    
    [_hero runAction:[SKAction rotateToAngle:opponentDirection duration:0.25 shortestUnitArc:TRUE]];
    [_opponent runAction:[SKAction rotateToAngle:heroDirection duration:0.25 shortestUnitArc:TRUE]];
}

// Experimental charge sequence using a 0.0 - 1.0 variability factor
-(void)chargeSequence:(SKSpriteNode *)node
         chargeVector:(CGVector)vector
         meanStrength:(CGFloat)meanStrength
          variability:(CGFloat)variability
{
    
    CGFloat trueStrength = randomInRange(meanStrength * (1 - variability), meanStrength * (1 + variability));
    
    SKAction *chargeAction = [SKAction customActionWithDuration:0.5 actionBlock:^(SKNode *node, CGFloat elapsedTime){
        node.physicsBody.velocity = CGVectorMake(vector.dx * trueStrength, vector.dy * trueStrength);
    }];
    
    [node runAction:chargeAction];

}

-(void)chargeOpponent
{
    // Animate hero during charging action
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"SumoSprite2"];
    
    SKTexture *f1 = [atlas textureNamed:@"SumoSprite_2_1"];
    SKTexture *f2 = [atlas textureNamed:@"SumoSprite_2_3"];
    SKTexture *f3 = [atlas textureNamed:@"SumoSprite_2_4"];
    
    NSArray *sumoChargingA = @[f2, f1, f3];
    NSArray *sumoChargingB = @[f3, f1, f2];
    
    if (_isAnimationA == YES) {
        SKAction *sumoCharging = [SKAction animateWithTextures:sumoChargingA timePerFrame:0.075];
        [_hero runAction:sumoCharging];
        _isAnimationA = NO;
    } else if (_isAnimationA == NO) {
        SKAction *sumoCharging = [SKAction animateWithTextures:sumoChargingB timePerFrame:0.075];
        [_hero runAction:sumoCharging];
        _isAnimationA = YES;
    }
    
    // Move hero * hero's strength
    CGVector chargeVector;
    chargeVector.dx = _touchLocation.x - _hero.position.x;
    chargeVector.dy = _touchLocation.y - _hero.position.y;
    chargeVector = toUnitVector(chargeVector);
    
 [_hero runAction:[SKAction moveBy:CGVectorMake(chargeVector.dx * _hero.strength, chargeVector.dy * _hero.strength) duration:0.5]];
}

-(void)chargeHero
{
    // Animate hero during charging action
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"SumoSprite2_Red"];
    
    SKTexture *f1 = [atlas textureNamed:@"SumoSprite_Red_2_1"];
    SKTexture *f2 = [atlas textureNamed:@"SumoSprite_Red_2_3"];
    SKTexture *f3 = [atlas textureNamed:@"SumoSprite_Red_2_4"];
    
    NSArray *sumoChargingA = @[f2, f1, f3];
    NSArray *sumoChargingB = @[f3, f1, f2];
    
    if (_isAnimationA == YES) {
        SKAction *sumoCharging = [SKAction animateWithTextures:sumoChargingA timePerFrame:0.075];
        [_opponent runAction:sumoCharging];
        _isAnimationA = NO;
    } else if (_isAnimationA == NO) {
        SKAction *sumoCharging = [SKAction animateWithTextures:sumoChargingB timePerFrame:0.075];
        [_opponent runAction:sumoCharging];
        _isAnimationA = YES;
    }

    // Move opponnent * opponent's strength
    CGVector chargeVector;
    chargeVector.dx = _hero.position.x - _opponent.position.x;
    chargeVector.dy = _hero.position.y - _opponent.position.y;
    chargeVector = toUnitVector(chargeVector);
    

    [self chargeSequence:_opponent chargeVector:chargeVector meanStrength:_opponent.strength variability:0.25];
}

-(void)flashBoostLabel
{
    SKLabelNode *boostButtonText = [SKLabelNode labelNodeWithText:@"Boost!"];
    boostButtonText.name = @"boostButton";
    boostButtonText.fontColor = [UIColor whiteColor];
    boostButtonText.fontSize = 15;
    boostButtonText.fontName = GAME_FONT;
    
    SKSpriteNode *boostButtonBacking = [SKSpriteNode
                                        spriteNodeWithColor:[UIColor orangeColor]
                                        size:CGSizeMake(self.size.width/7, self.size.width/20)];
    boostButtonBacking.name = @"boostButton";
    [boostButtonBacking addChild:boostButtonText];
    boostButtonText.position = CGPointMake(0, -boostButtonBacking.size.height/5);
    

    SKAction *waitLong = [SKAction waitForDuration:10.0 withRange:1.0];
    SKAction *position = [SKAction runBlock:^{
        CGFloat randomX = randomInRange(-_boostLayer.size.width/2, _boostLayer.size.width/2);
        CGFloat randomY = randomInRange(-_boostLayer.size.height/2, _boostLayer.size.height/2);
        
        boostButtonBacking.position = CGPointMake(randomX, randomY);
    }];
    SKAction *add = [SKAction runBlock:^{
        [_boostLayer addChild:boostButtonBacking];
    }];
    SKAction *appear = [SKAction runBlock:^{
        [boostButtonBacking runAction:[SKAction fadeAlphaTo:1.0 duration:1.0]];
    }];
    SKAction *waitShort = [SKAction waitForDuration:1.0];
    SKAction *disappear = [SKAction runBlock:^{
        [boostButtonBacking runAction:[SKAction fadeAlphaTo:0.0 duration:1.0]];
    }];
    SKAction *remove = [SKAction runBlock:^{
        [boostButtonBacking removeFromParent];
    }];
    
    SKAction *boostButtonSequence = [SKAction sequence:@[waitLong, position, add, appear, waitShort, disappear, remove]];
    [_mainLayer runAction:[SKAction repeatActionForever:boostButtonSequence]];
}

-(int)calculateStrength:(int)rankLevel
{
    return STRENGTH_BASE + rankLevel * (STRENGTH_MAX - STRENGTH_BASE) / [[RankManager sumoRanks] count];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        if (_isGameOver) {
            [self resetGame];
        } else if (!_isStarted) {
            [self start];
        } else {
            _touchLocation = [touch locationInNode:self];
            _didChargeOpponent = YES;
        }
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == ringCategory && secondBody.categoryBitMask == heroCategory) {
        
        // Opponent wins :(
        self.opponentPoints++;
        self.matchWinner = _opponent.name;
        _opponentPointsLabel.text = [NSString stringWithFormat:@"OPP: %d", self.opponentPoints];
        firstBody.node.physicsBody.categoryBitMask = FALSE;
        [self gameOver];
    }
    if (firstBody.categoryBitMask == ringCategory && secondBody.categoryBitMask == opponentCategory) {
        
        // Hero wins :)
        self.heroPoints++;
        self.matchWinner = _hero.name;
        _heroPointsLabel.text = [NSString stringWithFormat:@"HERO: %d", self.heroPoints];
        firstBody.node.physicsBody.categoryBitMask = FALSE;
        [self gameOver];
    }
    //    if (firstBody.categoryBitMask == heroCategory && secondBody.categoryBitMask == opponentCategory) {
    //        // Either do nothing or decrement stamina / health or something like that
    //    }
}

-(void)resetGame
{
    _isGameOver = FALSE;
    _isStarted = FALSE;
    
    [[self childNodeWithName:@"tapToResetLabel"] removeFromParent];
    [[self childNodeWithName:@"gameOverLabel"] removeFromParent];
    [self newGame];
    //[self performSelector:@selector(newGame) withObject:nil afterDelay:1.5];
}

-(void)gameOver
{
    // Game over label
    GameLabel *gameOverLabel = [GameLabel gameLabelWithFontSize:20.0];
    gameOverLabel.name = @"gameOverLabel";
    gameOverLabel.text = [NSString stringWithFormat:@"%@ Wins!", self.matchWinner];
    gameOverLabel.position = CGPointMake(0, 50);
    [self addChild:gameOverLabel];
    
    _currentPointsTotal = self.heroPoints + self.opponentPoints;
    
    if (_currentPointsTotal < 15) {
        
        [_mainLayer removeAllActions];
        
        GameLabel *tapToResetLabel = [GameLabel gameLabelWithFontSize:20.0];
        tapToResetLabel.name = @"tapToResetLabel";
        tapToResetLabel.text = @"tap to reset";
        [self addChild:tapToResetLabel];
        [self animateWithPulse:tapToResetLabel];
        
        _isGameOver = TRUE;
        
    } else if (_currentPointsTotal >= 15) {
        
//        [[[GameData sharedData] winHistory] addObject:[NSNumber numberWithInt:self.heroPoints]];
        [[[GameData sharedData] winHistory] addObject:[NSNumber numberWithInt:13]]; //              ** TEST SETTING **

        [[GameData sharedData] save];
        
        SKScene *resultsScene  = [[ResultsScene alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0 ],
                                             [SKAction runBlock:^{
            [self.view presentScene:resultsScene transition:doors];
        }]]]];
    }
}

-(void)didSimulatePhysics
{
    if (_didChargeOpponent == YES) {
        [self chargeOpponent];
        _didChargeOpponent = NO;
    }
    
    [self rotateToFace];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
//    if (_isBoostOn == YES) {
//        _isBoostOn = NO;
//    }
}

-(void)animateWithPulse:(SKNode *)node
{
    SKAction *disappear = [SKAction fadeAlphaTo:0.0 duration:0.6];
    SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:0.6];
    SKAction *pulse = [SKAction sequence:@[disappear, appear]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}

@end
