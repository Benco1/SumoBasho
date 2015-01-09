//
//  RankManager.m
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "RankManager.h"
@interface RankManager ()

+(NSDictionary *)sumoRanks;

@end

@implementation RankManager

@synthesize outputRank;

+(NSDictionary *)sumoRanks
{
    return      @{ @"24" : @"Yokozuna",
                   @"23" : @"Ozeki",
                   @"22" : @"Ozeki",
                   @"21" : @"Ozeki",
                   @"20" : @"Sekiwake",
                   @"19" : @"Sekiwake",
                   @"18" : @"Sekiwake",
                   @"17" : @"Komusubi",
                   @"16" : @"Maegashira 1",
                   @"15" : @"Maegashira 2",
                   @"14" : @"Maegashira 3",
                   @"13" : @"Maegashira 4",
                   @"12" : @"Maegashira 5",
                   @"11" : @"Maegashira 6",
                   @"10" : @"Maegashira 7",
                   @"9"  : @"Maegashira 8",
                   @"8"  : @"Maegashira 9",
                   @"7"  : @"Maegashira 10",
                   @"6"  : @"Maegashira 11",
                   @"5"  : @"Maegashira 12",
                   @"4"  : @"Maegashira 13",
                   @"3"  : @"Maegashira 14",
                   @"2"  : @"Maegashira 15",
                   @"1"  : @"Maegashira 16"};
}

// Assign new rank level and title and output as single-entry value/key NSDictionary
+(id)rankManager:(NSMutableArray *)winHistory currentRankTitle:(NSString *)inputTitle currentRankLevel:(int)inputLevel
{
    RankManager *rankManager = [RankManager new];
    
    NSDictionary *sumoRanks = [self sumoRanks];
    
    NSString *outputLevel;
    
    if ([self isDueForPromotion:winHistory currentRankTitle:inputTitle currentRankLevel:inputLevel]) {
        
        outputLevel = [NSString stringWithFormat:@"%d", inputLevel + 1];
        
    } else if (![inputTitle isEqualToString:@"Maegashira 16"] && ![inputTitle isEqualToString:@"Yokozuna"]){
        
        outputLevel = [NSString stringWithFormat:@"%d", inputLevel - 1];
        
    } else {
        
        outputLevel = [NSString stringWithFormat:@"%d", inputLevel];
    }
    
    rankManager.outputRank = @{ outputLevel : sumoRanks[outputLevel] };

    return rankManager;
}

// Determine whether player is due for promotion based on recent (i.e., last 1 to 3) matches depending upon rank
+(BOOL)isDueForPromotion:(NSMutableArray *)winHistory
        currentRankTitle:(NSString *)inputTitle
        currentRankLevel:(int)inputLevel
{
    BOOL fate = FALSE;
    
    if ([inputTitle isEqualToString:@"Yokozuna"]) {
        return fate = FALSE;
    }
    
    if ([inputTitle isEqualToString:@"Ozeki"]) {
        
        if (inputLevel == 23) {                                                         // ** Highest Ozeki Rank Level **
        
            NSRange range = NSMakeRange([winHistory count] - 3, 3);
            NSArray *lastThreeMatches = [winHistory subarrayWithRange:range];
            
            // Check each of last three matches to see if match wins < 12; FALSE if yes to any
            for (NSNumber *wins in lastThreeMatches) {
                if ([wins intValue] < 12) {
                    fate = FALSE;
                    break;
                } else {
                    fate = TRUE;
                }
                return fate;
            }

        } else {
        
            if ([[winHistory lastObject] intValue] > 12) {
                fate = TRUE;
            }
            return fate;
        }
    }
    
    if ([inputTitle isEqualToString:@"Sekiwake"]) {
        
        if (inputLevel == 20) {                                                         // ** Highest Sekiwake Rank Level **
        
            NSRange range = NSMakeRange([winHistory count] - 3, 3);
            NSArray *lastThreeMatches = [winHistory subarrayWithRange:range];
            
            // Check each of last three matches to see if match wins < 11; FALSE if yes to any
            for (NSNumber *wins in lastThreeMatches) {
                if ([wins intValue] < 11) {
                    fate = FALSE;
                    break;
                } else {
                    fate = TRUE;
                }
                return fate;
            }

        } else {
            
            if ([[winHistory lastObject] intValue] > 11) {
                fate = TRUE;
            }
        }
        
            return fate;
    }
    
    if ([inputTitle isEqualToString:@"Komusubi"]) {
        
        if ([[winHistory lastObject] intValue] > 9) {
            fate = TRUE;
        }
        return fate;
    }
    
    if ([inputTitle containsString:@"Maegashira"]) {
        
        if ([[winHistory lastObject] intValue] > 7) {
            fate = TRUE;
        }
        return fate;
    }
    
    return fate;
}


@end