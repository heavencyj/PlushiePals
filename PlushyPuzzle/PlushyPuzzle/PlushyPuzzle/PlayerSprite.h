//
//  PlayerSprite.h
//  PlushyPuzzle
//
//  Created by Lan Li on 2/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LHSprite.h"

@interface PlayerSprite : LHSprite {
    
    
}

//------------------------------------------------------------------------------
//the following are required in order for the custom sprite to work properly
+(id)batchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch;//render by batch node
+(id)spriteWithDictionary:(NSDictionary*)dictionary;//self render

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch;

//called by LevelHelper after the sprite has been created - all info from LevelHelper will be available at this stage
-(void)postInit;

//------------------------------------------------------------------------------
//the following method will test if a sprite object is really of PuzzleSprite type
+(bool)isPlayerSprite:(id)object;

//------------------------------------------------------------------------------
//create your own custom methods here
-(void) jump;
-(void) move:(const b2Vec2)speed;
-(void)loadDieAnimation;
-(void)loadJumpAnimation;
-(void)loadRunAnimation;

@end
