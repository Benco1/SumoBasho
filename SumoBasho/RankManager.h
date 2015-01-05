//
//  RankManager.h
//  SumoBasho
//
//  Created by BC on 1/4/15.
//  Copyright (c) 2015 BencoMakes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RankManager : NSObject

@property (nonatomic) NSString *outputRankTitle;

+(id)rankManagerWithWinHistory:(NSMutableArray *)winHistory currentRank:(NSString *)inputRankTitle;

@end
