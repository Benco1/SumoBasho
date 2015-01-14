//
//  Hero.h
//  SumoTest
//
//  Created by BC on 12/27/14.
//  Copyright (c) 2014 BenCodes. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Hero : SKSpriteNode

@property CGFloat strength;

+ (id)heroWithImage:(NSString *)imageString name:(NSString *)name position:(CGPoint)position;

@end
