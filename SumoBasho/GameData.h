//
//  GameData.h
//  SumoTest
//
//  Created by BC on 1/1/15.
//  Copyright (c) 2015 BenCodes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject <NSCoding>

@property (assign, nonatomic) int currentStrength;
@property (nonatomic) NSDictionary *currentRank;
@property (nonatomic) NSMutableArray *winHistory;

+ (instancetype)sharedData;
- (void)save;
- (void)reset;
- (int)latestResult;
- (int)totalMatches;
- (int)totalWins;
- (int)totalLosses;
-(NSString *)currentRankTitle;
-(int)currentRankValue;

@end
