//
//  Hero.m
//  SumoTest
//
//  Created by BC on 12/27/14.
//  Copyright (c) 2014 BenCodes. All rights reserved.
//

#import "Hero.h"

@implementation Hero

+ (id)heroWithImage:(NSString *)imageString name:(NSString *)name position:(CGPoint)position
{
    Hero *hero = [Hero spriteNodeWithImageNamed:imageString];
    hero.anchorPoint = CGPointMake(0.5, 0.5);
    hero.name = name;
    hero.position = position;
    hero.zPosition = 1.0;
    hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(50, 50)];
    hero.physicsBody.mass = 200;
    hero.physicsBody.friction = 100;
    hero.physicsBody.linearDamping = 0.7;
    hero.physicsBody.angularDamping = 1e6;
    hero.physicsBody.angularVelocity = 0.1;
    hero.physicsBody.restitution = 0.9;
    
    SKSpriteNode *heroAnchor = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(5, 5)];
    heroAnchor.position = hero.anchorPoint;
    heroAnchor.name = @"heroAnchor";
    [hero addChild:heroAnchor];

    SKSpriteNode *face = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(5, 5)];
    face.position = CGPointMake(hero.size.width/2, 0);
    face.name = @"face";
    [hero addChild:face];
    
    return hero;
}
@end
