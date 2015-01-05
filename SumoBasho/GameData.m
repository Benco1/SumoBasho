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

@synthesize currentRankTitle;
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

    [encoder encodeObject:self.currentRankTitle forKey:@"currentRankTitle"];
    [encoder encodeInt:self.currentStrength forKey:@"currentStrength"];
    [encoder encodeObject:self.winHistory forKey:@"winHistory"];
}

-(instancetype) initWithCoder:(NSCoder*)decoder {
    self = [self init];
    if (self) {
        self.currentRankTitle = [decoder decodeObjectForKey:@"currentRankTitle"];
        self.currentStrength = [decoder decodeIntForKey:@"currentStrength"];
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
    self.currentRankTitle = nil;
    self.currentStrength = 0;
    self.winHistory = [[NSMutableArray alloc] init];
}

+(instancetype)loadInstance
{
    NSData *decodedData = [NSData dataWithContentsOfFile:[GameData filePath]];
    NSLog(@"Decoded Data = %@", [GameData filePath]);
    if(decodedData) {
    GameData *sharedData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    return sharedData;
    }
    return [GameData new];
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
        NSLog(@"%d wins, num %d", wins, [num intValue]);
    }
    return wins;
}

-(int)totalLosses
{
    return [self totalMatches] - [self totalWins];
}

@end
