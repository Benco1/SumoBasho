//
//  OpponentGenerator.h
//  SumoBasho
//
//  Created by BC on 1/8/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpponentGenerator : NSObject

+(NSMutableDictionary *)opponentPool;
+(id)opponentFromPool:(NSMutableDictionary *)opponentPool;
-(int)rankLevel;
-(NSString *)rankTitle;

@end
