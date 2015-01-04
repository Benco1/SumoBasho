//
//  Hero.m
//  SumoTest
//
//  Created by BC on 12/27/14.
//  Copyright (c) 2014 BenCodes. All rights reserved.
//

#import "Hero.h"

@implementation Hero

+ (id)hero
{
    CGFloat static const HERO_LENGTH = 50.0;
    
    Hero *hero = [Hero spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(HERO_LENGTH, HERO_LENGTH)];
    hero.anchorPoint = CGPointMake(0.5, 0.5);
    hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hero.size center:CGPointMake(0, 0)];
    hero.physicsBody.density = 1.0;
    hero.physicsBody.friction = 1.0;
    hero.physicsBody.linearDamping = 1.0;
    hero.physicsBody.angularDamping = 1.0;
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
