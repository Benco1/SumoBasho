//
//  GameData.m
//  SumoTest
//
//  Created by BC on 1/1/15.
//  Copyright (c) 2015 BenCodes. All rights reserved.
//

#import "GameData.h"

@interface GameData ()

@property NSString *filePath;

@end


@implementation GameData

@synthesize currentRank;
@synthesize currentStrength;
@synthesize winHistory;

+(instancetype)sharedData
{
    static GameData *sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [self loadInstance];
    });
    return sharedData;
}

+(NSString*)filePath
{
    static NSString *filePath = nil;
    if (!filePath) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)
                          objectAtIndex:0];
        NSString *fileName = @"sharedData";
        filePath = [path stringByAppendingString:fileName];
    }
    return filePath;
}

-(void) encodeWithCoder:(NSCoder*)encoder {

    [encoder encodeObject:self.currentRank forKey:@"currentRank"];
    [encoder encodeObject:self.winHistory forKey:@"winHistory"];
}

-(instancetype) initWithCoder:(NSCoder*)decoder {
    self = [self init];
    if (self) {
        self.currentRank = [decoder decodeObjectForKey:@"currentRank"];
        self.winHistory = [decoder decodeObjectForKey:@"winHistory"];
    }
    return self;
}

-(void)save
{
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
}

-(void)reset
{
    self.currentRank = @{ @"1" : @"Maegashira 16" };
    self.currentStrength = 0;
    self.winHistory = [[NSMutableArray alloc] init];
}

+(instancetype)loadInstance
{
    NSData *decodedData = [NSData dataWithContentsOfFile:[GameData filePath]];
    if(decodedData) {
    GameData *sharedData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    return sharedData;
    }
    return [GameData new];
}

-(NSString *)currentRankTitle
{
    return [[self.currentRank allValues] objectAtIndex:0];
}

-(int)currentRankLevel
{
    return [[[self.currentRank allKeys] objectAtIndex:0] intValue];
}

-(int)latestResult
{
    return [[[self winHistory] lastObject] intValue];
}

-(int)totalMatches
{
    return (int)[[self winHistory] count] * 15;
}

-(int)totalWins
{
    int wins = 0;

    for (NSNumber *num in self.winHistory) {

        wins += [num intValue];
    }
    return wins;
}

-(int)totalLosses
{
    return [self totalMatches] - [self totalWins];
}

@end
