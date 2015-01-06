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

@implementation GameScene
{
    Hero *_hero;
    Hero *_opponent;
    BOOL _didChargeOpponent;
    BOOL _isStarted;
    BOOL _isGameOver;
    SKNode *_mainLayer;
    CGPoint _touchLocation;
    SKShapeNode *_ring;
    SKSpriteNode *_ground;
    SKLabelNode *_heroPointsLabel;
    SKLabelNode *_opponentPointsLabel;
}

CGFloat static const HERO_STRENGTH = 20;
CGFloat static const OPPONENT_STRENGTH = 60;

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
    //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    // Add mainlayer
    _mainLayer = [[SKNode alloc] init];
    [self addChild:_mainLayer];
    
    _ground = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:CGSizeMake(self.size.width, self.size.width)];
    _ground.position = self.anchorPoint;
    [_mainLayer addChild:_ground];
    
    // Add points labels
    _heroPointsLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    _heroPointsLabel.position = CGPointMake(0.9 * -self.size.width/2, 0.9 * self.size.height/2);
    _heroPointsLabel.fontSize = 20.0;
    _heroPointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _heroPointsLabel.text = @"HERO: 0";
    [self addChild:_heroPointsLabel];
    
    // Add points labels
    _opponentPointsLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    _opponentPointsLabel.position = CGPointMake(0.9 * self.size.width/2, 0.9 * self.size.height/2);
    _opponentPointsLabel.fontSize = 20.0;
    _opponentPointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _opponentPointsLabel.text = @"CPU: 0";
    [self addChild:_opponentPointsLabel];
    
    // Add ring boundary
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, 0, 0, 0.9 * self.size.height/2, 0, M_PI * 2, YES);
    _ring = [SKShapeNode shapeNodeWithPath:circlePath];
    _ring.position = CGPointMake(0.0, 0.0);
    _ring.strokeColor = [UIColor redColor];
    _ring.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:circlePath];
    _ring.physicsBody.categoryBitMask = ringCategory;
    _ring.physicsBody.collisionBitMask = 0;
    _ring.physicsBody.contactTestBitMask = heroCategory | opponentCategory;
    _ring.physicsBody.dynamic = NO;
    [self addChild:_ring];
    
    // Setup data defaults
//    [[GameData sharedData] reset];

    if ([[GameData sharedData] totalMatches] == 0) {
        
        [[GameData sharedData] reset];
        [GameData sharedData].currentStrength = 50;
    }
    
    [self newGame];
}

-(void)newGame
{
    NSLog(@"winHistory %@", [[GameData sharedData] winHistory]);
    NSLog(@"current Title %@", [[GameData sharedData] currentRankTitle]);
    NSLog(@"current Rank Level %d", [[GameData sharedData] currentRankLevel]);
    
    [_mainLayer removeAllChildren];
    
    SKLabelNode *tapToBeginLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    tapToBeginLabel.name = @"tapToBeginLabel";
    tapToBeginLabel.text = @"tap to begin";
    tapToBeginLabel.fontSize = 20.0;
    [self addChild:tapToBeginLabel];
    [self animateWithPulse: tapToBeginLabel];
    
    // (Re-)Apply ring bit mask
    _ring.physicsBody.categoryBitMask = ringCategory;
    
    // Add user-controlled hero
    //_hero = [Hero hero];
    _hero = [Hero spriteNodeWithImageNamed:@"SumoSpriteTEST"];
    _hero.name = @"Hero";
    _hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.size];
    _hero.position = CGPointMake(0, 45);
    _hero.physicsBody.mass = 200;
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.collisionBitMask = opponentCategory;
    [_mainLayer addChild:_hero];
    
    // Add computer-controlled opponent
    _opponent = [Hero hero];
    _opponent.name = @"Opponent";
    _opponent.position = CGPointMake(0, -45);
    _opponent.physicsBody.mass = 200;
    _opponent.physicsBody.categoryBitMask = opponentCategory;
    _opponent.physicsBody.collisionBitMask = heroCategory;
    _opponent.color = [UIColor blackColor];
    [_mainLayer addChild:_opponent];
    
    [_hero runAction:[SKAction rotateByAngle: -M_PI_2 duration:0.0]];
    [_opponent runAction:[SKAction rotateByAngle: M_PI_2 duration:0.0]];
}

- (void)start
{
    [[self childNodeWithName:@"tapToBeginLabel"] removeFromParent];
    
    _isStarted = YES;
    
    // Run chargeHero method forever in sequence with wait timer
    SKAction *chargeHeroSequence = [SKAction sequence:@[[SKAction waitForDuration:0.5 withRange:0.2],
                                                        [SKAction performSelector:@selector(chargeHero) onTarget:self]]];
    [_mainLayer runAction:[SKAction repeatActionForever: chargeHeroSequence]];
}

// Turn hero and opponent to face each other
-(void)rotateToFace
{
    CGFloat opponentDirection = atan2(_opponent.position.y - _hero.position.y, _opponent.position.x - _hero.position.x);
    CGFloat heroDirection = atan2(_hero.position.y - _opponent.position.y, _hero.position.x - _opponent.position.x);
    
    SKAction *rotateToOpponent = [SKAction rotateToAngle:opponentDirection duration:0.5 shortestUnitArc:TRUE];
    SKAction *rotateToHero = [SKAction rotateToAngle:heroDirection duration:0.5 shortestUnitArc:TRUE];
    
    [_hero runAction:rotateToOpponent];
    [_opponent runAction:rotateToHero];
}

-(void)chargeOpponent
{
    CGVector chargeVector;
    chargeVector.dx = _touchLocation.x - _hero.position.x;
    chargeVector.dy = _touchLocation.y - _hero.position.y;
    chargeVector = toUnitVector(chargeVector);
    
    [_hero runAction:[SKAction moveBy:CGVectorMake(chargeVector.dx * HERO_STRENGTH, chargeVector.dy * HERO_STRENGTH) duration:0.5]];
}

-(void)chargeHero
{
    CGVector chargeVector;
    chargeVector.dx = _hero.position.x - _opponent.position.x;
    chargeVector.dy = _hero.position.y - _opponent.position.y;
    chargeVector = toUnitVector(chargeVector);
    
    [self chargeSequence:_opponent chargeVector:chargeVector meanStrength:OPPONENT_STRENGTH variability:0.5];
}

// Experimental charge sequence
-(void)chargeSequence:(SKSpriteNode *)node
         chargeVector:(CGVector)vector
         meanStrength:(CGFloat)meanStrength
          variability:(CGFloat)variability
{
    
    CGFloat trueStrength = randomInRange(meanStrength * (1 - variability), meanStrength * (1 + variability));
    
    [node runAction:[SKAction sequence:@[[SKAction moveBy:CGVectorMake(vector.dx * trueStrength,
                                                                       vector.dy * trueStrength) duration:0.5],
                                         [SKAction waitForDuration:0.5],
                                         [SKAction moveBy:CGVectorMake(-vector.dx * meanStrength / 2,
                                                                       -vector.dy * meanStrength / 2) duration:0.1]]]];
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
        _isGameOver = TRUE;
        self.opponentPoints++;
        self.matchWinner = _opponent.name;
        _opponentPointsLabel.text = [NSString stringWithFormat:@"OPP: %d", self.opponentPoints];
        firstBody.node.physicsBody.categoryBitMask = FALSE;
        [self gameOver];
    }
    if (firstBody.categoryBitMask == ringCategory && secondBody.categoryBitMask == opponentCategory) {
        
        // Hero wins :)
        _isGameOver = TRUE;
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
    //    [[GameData sharedData] save];
    
    // Game over label
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    gameOverLabel.name = @"gameOverLabel";
    gameOverLabel.text = [NSString stringWithFormat:@"%@ Wins!", self.matchWinner];
    gameOverLabel.position = CGPointMake(0, 50);
    [self addChild:gameOverLabel];
    
    CGFloat totalPoints = self.heroPoints + self.opponentPoints;
    
    if (totalPoints < 15) {
        
        [_mainLayer removeAllActions];
        
        SKLabelNode *tapToResetLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        tapToResetLabel.name = @"tapToResetLabel";
        tapToResetLabel.text = @"tap to reset";
        tapToResetLabel.fontSize = 20.0;
        [self addChild:tapToResetLabel];
        [self animateWithPulse:tapToResetLabel];
        
    } else if (totalPoints >= 15) {
        
        [[[GameData sharedData] winHistory] addObject:[NSNumber numberWithInt:self.heroPoints]];
//        [[[GameData sharedData] winHistory] addObject:[NSNumber numberWithInt:13]]; //              **CHANGE THIS**

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
    
}

-(void)animateWithPulse:(SKNode *)node
{
    SKAction *disappear = [SKAction fadeAlphaTo:0.0 duration:0.6];
    SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:0.6];
    SKAction *pulse = [SKAction sequence:@[disappear, appear]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}

@end
