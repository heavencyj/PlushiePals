//
//  GameData.h
//  CollisionTest
//
//  Created by Heaven Chen on 4/12/13.
//
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject
{
   
}

@property (nonatomic, readwrite) bool mute;
@property (nonatomic, readwrite) bool tips;
@property (nonatomic, readwrite, retain) NSMutableArray *highscore;
@property (nonatomic, readwrite) unsigned int bananaCount;
@property (nonatomic, readwrite) unsigned int mangosteenCount;
@property (nonatomic, readwrite) unsigned int pineappleCount;
@property (nonatomic, readwrite) unsigned int mapTheme;
@property (nonatomic, readwrite) unsigned int plushy;

+(GameData*)sharedGameData;
+(void)defaultValues;
@end
