//
//  Monkey.h
//  CollisionTest
//
//  Created by Lan Li on 1/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GB2Sprite.h"
#import "GameScene.h"

#define RUNNING 0
#define JUMPING 1
#define SLIDING 2
#define COLLIDING 3
#define DYING 4

@class GameScene;
@class RunningGameScene;

@interface Plushy : GB2Sprite
{
    //float direction;      //!< keeps monkey's direction (from accelerometer)
    int animPhase;        //!< the current animation phase
    ccTime animDelay;     //!< delay until the next animation phase is stated
    RunningGameScene *gameLayer; //!< weak reference
    
    NSMutableArray *hearts;
    b2Vec2 initialPosition;
   
}

@property (readwrite) int bananaScore;
@property (readwrite) int lives;
@property (readonly) RunningGameScene *gameLayer;
@property (readonly) bool jumping;
@property (readonly) bool running;
@property (readonly) bool collide;
@property (readonly) bool pass;
@property (readonly) bool die;
@property (readonly) int tip;
@property (readwrite) bool dead;
@property (readwrite) bool sliding;
@property (readonly) bool swipeRange;
@property (readwrite) bool showmap;
@property (readwrite) bool loadmap;
@property (readonly) bool onBridge;

/**
 * Inits the monkey with the given game layer
 * @param gl game layer
 */
-(id) initWithGameLayer:(GameScene*)gl;
-(void) jump;
-(void) reset;
-(bool)isRunning;
-(void)moveTo:(b2Vec2)pos;
-(void)destroyLive;
-(void) regainLive;
-(void)resetPlushyPosition;
-(void)setTip;
-(void) loadLives;
-(void) destroyAllLives;
+(void) playSound:(int)type;
@end
