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
    bool jumping;
    bool running;
    bool collide;
    bool pass;
    bool dead;
    bool die;
    bool falling;
    int bananaScore;
}

//@property (readonly) bool isDead;
@property (readwrite) int bananaScore;

/**
 * Inits the monkey with the given game layer
 * @param gl game layer
 */
-(id) initWithGameLayer:(GameScene*)gl;
-(void) jump;
-(bool) isDead;
-(void) reset;
-(bool)isJumping;
-(bool)isRunning;
-(void)moveTo:(b2Vec2)pos;
-(bool)passLevel;
-(void)setFalling:(bool)fall;
-(bool)isFalling;
@end
