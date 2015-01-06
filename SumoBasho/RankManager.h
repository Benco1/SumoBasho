//
//  RankManager.h
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RankManager : NSObject

@property (nonatomic) NSDictionary *outputRank;


+(id)rankManager:(NSMutableArray *)winHistory currentRankTitle:(NSString *)inputTitle currentRankValue:(int)inputValue;

@end
