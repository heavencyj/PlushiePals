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

@class GameScene;

@interface Plushy : GB2Sprite
{
    //float direction;      //!< keeps monkey's direction (from accelerometer)
    int animPhase;        //!< the current animation phase
    ccTime animDelay;     //!< delay until the next animation phase is stated
    GameScene *gameLayer; //!< weak reference
    
    NSMutableArray *hearts;
    b2Vec2 initialPosition;
   
}

//@property (readonly) bool isDead;
@property (readwrite) int bananaScore;
@property (readwrite) int lives;
@property (readonly) GameScene *gameLayer;
@property (readonly) bool jumping;
@property (readonly) bool running;
@property (readonly) bool collide;
@property (readonly) bool pass;
@property (readonly) bool die;
@property (readonly) int tip;
@property (readwrite) bool dead;
//@property (readwrite) bool falling;
@property (readwrite) bool showbridge;
@property (readwrite) bool showmap;

/**
 * Inits the monkey with the given game layer
 * @param gl game layer
 */
-(id) initWithGameLayer:(GameScene*)gl;
-(void) jump;
-(void) reset;
//-(bool)isJumping;
-(bool)isRunning;
-(void)moveTo:(b2Vec2)pos;
//-(bool)passLevel;
//-(void)setFalling:(bool)fall;
//-(bool)isFalling;
-(void)destroyLive;
-(void) regainLive;
-(void)resetPlushyPosition;
//-(bool)isColliding;
//-(int)showTip;
-(void)setTip;
//-(bool)showBridge;
@end
