//
//  RankManager.m
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import "RankManager.h"

@implementation RankManager


@synthesize outputRank;

+(id)rankManager:(NSMutableArray *)winHistory currentRankTitle:(NSString *)inputTitle currentRankValue:(int)inputValue
{
    RankManager *rankManager = [RankManager new];
    
    NSDictionary *sumoRanks = @{
                                @"Yokozuna" : [NSNumber numberWithInt:24],
                                @"Ozeki" : [NSNumber numberWithInt:23],
                                @"Ozeki" : [NSNumber numberWithInt:22],
                                @"Ozeki" : [NSNumber numberWithInt:21],
                                @"Sekiwake" : [NSNumber numberWithInt:20],
                                @"Sekiwake" : [NSNumber numberWithInt:19],
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
                                @"Maegashira 16" : [NSNumber numberWithInt:1]};
    
    
    if ([self isDueForPromotion:winHistory currentRankTitle:inputTitle currentRankValue:inputValue]) {
        
        NSNumber *outputValue = [NSNumber numberWithInt:(inputValue + 1)];
        
        NSLog(@"outputValue %@", outputValue);
        
        rankManager.outputRank = @{[[sumoRanks allKeysForObject:outputValue] objectAtIndex:0] : outputValue};
        
    } else if (![inputTitle isEqualToString:@"Maegashira 16"] && ![inputTitle isEqualToString:@"Yokozuna"]){
        
        NSNumber *outputValue = [NSNumber numberWithInt:(inputValue - 1)];
        
        rankManager.outputRank = @{[[sumoRanks allKeysForObject:outputValue] objectAtIndex:0] : outputValue};
    }
    return rankManager;
}

// Determine whether player is due for promotion based on recent (i.e., last 1 to 3) matches depending upon rank
+(BOOL)isDueForPromotion:(NSMutableArray *)winHistory
        currentRankTitle:(NSString *)inputTitle
        currentRankValue:(int)inputValue
{
    BOOL fate = FALSE;
    
    if ([inputTitle isEqualToString:@"Yokozuna"]) {
        return fate = FALSE;
    }
    
    if ([inputTitle isEqualToString:@"Ozeki"]) {
        
        if (inputValue == 23) {                                                         // ** Highest Ozeki Value **
        
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
        
        if (inputValue == 20) {                                                         // ** Highest Sekiwake Value **
        
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