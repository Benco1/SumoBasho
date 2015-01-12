//
//  GameLabel.m
//  SumoBasho
//
//  Created by BC on 1/11/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "GameLabel.h"

@implementation GameLabel

+(id)gameLabelWithFontSize:(CGFloat)fontSize
{
    GameLabel *gameLabel = [GameLabel labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    gameLabel.fontSize = fontSize;
    
    return gameLabel;
}

@end
