//
//  OpponentGenerator.m
//  SumoBasho
//
//  Created by BC on 1/8/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "OpponentGenerator.h"
#import "RankManager.h"

@interface OpponentGenerator ()

@property (nonatomic) NSDictionary *stats;

@end


@implementation OpponentGenerator

+(NSMutableDictionary *)opponentPool
{
    NSMutableDictionary *pool = [NSMutableDictionary dictionaryWithDictionary:[RankManager sumoRanks]];
    return pool;
}

+(NSString *)randomKey
{
    int rand = arc4random_uniform((int)[[RankManager sumoRanks] count] + 1);
    return [NSString stringWithFormat:@"%d", (int)rand];
}

+(id)opponentFromPool:(NSMutableDictionary *)opponentPool
{
    OpponentGenerator *opponent = [OpponentGenerator new];

    while (1 > 0) {
        
        NSString *randKey = [self randomKey];
        
        if([opponentPool objectForKey:randKey]) {
            opponent.stats = @{ randKey : [opponentPool objectForKey:randKey] };
            [opponentPool removeObjectForKey:randKey];
            break;
        }
    }
    return opponent;
}

-(int)rankLevel
{
    return [[[[self stats] allKeys] objectAtIndex:0] intValue];
}

-(NSString *)rankTitle
{
    return [[[self stats] allValues] objectAtIndex:0];
}


@end
