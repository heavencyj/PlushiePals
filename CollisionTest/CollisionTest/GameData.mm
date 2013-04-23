//
//  GameData.m
//  CollisionTest
//
//  Created by Heaven Chen on 4/12/13.
//
//

#import "GameData.h"

@implementation GameData

@synthesize mute;
@synthesize tips;
@synthesize highscore;
@synthesize bananaCount;
@synthesize mangosteenCount;
@synthesize pineappleCount;
@synthesize mapTheme;
@synthesize plushy;

static GameData *gamedata = nil;

+(GameData*)sharedGameData{
    
    if (gamedata == nil) {
        gamedata = [[GameData alloc] init];
        [self defaultValues];
    }

    return gamedata;
}

+(void)defaultValues{
    gamedata.mute = NO;
    gamedata.tips = NO;
    gamedata.bananaCount = 0;
    gamedata.mangosteenCount = 0;
    gamedata.pineappleCount = 0;
    gamedata.mapTheme = 1;
    gamedata.plushy = 1;
    gamedata.highscore = [NSMutableArray arrayWithObjects:
                          [NSNumber numberWithInt:0],
                          [NSNumber numberWithInt:0],
                          [NSNumber numberWithInt:0],
                          [NSNumber numberWithInt:0],
                          [NSNumber numberWithInt:0], nil];


}

@end
