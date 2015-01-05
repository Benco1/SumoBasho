//
//  RankManager.m
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "RankManager.h"

@implementation RankManager

@synthesize outputRankTitle;

+(id)rankManagerWithWinHistory:(NSMutableArray *)winHistory currentRank:(NSString *)inputRankTitle
{
    RankManager *rankManager = [RankManager new];
    
    NSDictionary *sumoRanks = @{
                                @"Yokozuna" : [NSNumber numberWithInt:20],
                                @"Ozeki" : [NSNumber numberWithInt:19],
                                @"Sekiwake" : [NSNumber numberWithInt:18],
                                @"Komusubi" : [NSNumber numberWithInt:17],
                                @"Maegashira 1" : [NSNumber numberWithInt:16],
                                @"Maegashira 2" : [NSNumber numberWithInt:15],
                                @"Maegashira 3" : [NSNumber numberWithInt:14],
                                @"Maegashira 4" : [NSNumber numberWithInt:13],
                                @"Maegashira 5" : [NSNumber numberWithInt:12],
                                @"Maegashira 6" : [NSNumber numberWithInt:11],
                                @"Maegashira 7" : [NSNumber numberWithInt:10],
                                @"Maegashira 8" : [NSNumber numberWithInt:9],
                                @"Maegashira 9" : [NSNumber numberWithInt:8],
                                @"Maegashira 10" : [NSNumber numberWithInt:7],
                                @"Maegashira 11" : [NSNumber numberWithInt:6],
                                @"Maegashira 12" : [NSNumber numberWithInt:5],
                                @"Maegashira 13" : [NSNumber numberWithInt:4],
                                @"Maegashira 14" : [NSNumber numberWithInt:3],
                                @"Maegashira 15" : [NSNumber numberWithInt:2],
                                @"Maegashira 16" : [NSNumber numberWithInt:1]
                                };
    
    
    if ([self isDueForPromotion:winHistory currentRank:inputRankTitle]) {

        int inputRankValue = [[sumoRanks objectForKey:inputRankTitle] intValue];
        
        NSNumber *outputRankValue = [NSNumber numberWithInt:(inputRankValue + 1)];
        
        rankManager.outputRankTitle = [[sumoRanks allKeysForObject:outputRankValue] objectAtIndex:0];
        
    } else if (![inputRankTitle isEqualToString:@"Maegashira 16"] && ![inputRankTitle isEqualToString:@"Yokozuna"]){
        
        int inputRankValue = [[sumoRanks objectForKey:inputRankTitle] intValue];
        
        NSNumber *outputRankValue = [NSNumber numberWithInt:(inputRankValue - 1)];
        
        rankManager.outputRankTitle = [[sumoRanks allKeysForObject:outputRankValue] objectAtIndex:0];
    }
    return rankManager;
}

// Determine whether player is due for promotion based on recent (i.e., last 1 to 3) matches depending upon rank
+(BOOL)isDueForPromotion:(NSMutableArray *)winHistory currentRank:(NSString *)inputRankTitle
{
    BOOL fate = FALSE;
    
    if ([inputRankTitle isEqualToString:@"Yokozuna"]) {
        return fate = FALSE;
    }
    
    if ([inputRankTitle isEqualToString:@"Ozeki"] || [inputRankTitle isEqualToString:@"Sekiwake"]) {
        
        NSRange range = NSMakeRange([winHistory count] - 3, 3);
        NSArray *lastThreeMatches = [winHistory subarrayWithRange:range];
        
        // Check each of last three matches to see if match wins < 10; FALSE if yes to any
        for (NSNumber *wins in lastThreeMatches) {
            if ([wins intValue] < 12) {
                fate = FALSE;
                break;
            } else {
                fate = TRUE;
            }
            return fate;
        }
        return fate;
    }
    
    if ([inputRankTitle isEqualToString:@"Komusubi"]) {
        if ([[winHistory lastObject] intValue] > 9) {
            fate = TRUE;
        }
        return fate;
    }
    
    if ([inputRankTitle containsString:@"Maegashira"]) {
        if ([[winHistory lastObject] intValue] > 7) {
            fate = TRUE;
        }
        return fate;
    }
    
    return fate;
}

@end
