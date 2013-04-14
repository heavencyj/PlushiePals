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
//@synthesize currentScore;
//@synthesize currentHeart;
@synthesize bananaCount;
@synthesize mangosteenCount;
@synthesize pineappleCount;

static GameData *gamedata = nil;

+(GameData*)sharedGameData{
    
    if (gamedata == nil) {
        gamedata = [[GameData alloc] init];
    }

    return gamedata;
}

+(void)defaultValues{
    gamedata.mute = NO;
    gamedata.tips = NO;
    gamedata.bananaCount = 0;
    gamedata.mangosteenCount = 0;
    gamedata.pineappleCount = 0;
    gamedata.highscore = [NSArray arrayWithObjects:0,0,0,0,0, nil];
}

@end
