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

@class HelloWorldLayer;

@interface Monkey : GB2Sprite
{
  //float direction;      //!< keeps monkey's direction (from accelerometer)
  int animPhase;        //!< the current animation phase
  ccTime animDelay;     //!< delay until the next animation phase is stated
  HelloWorldLayer *gameLayer; //!< weak reference
  bool jumping;
  bool running;
  bool collide;
  bool pass;
  bool dead;
  bool die;
}

//@property (readonly) bool isDead;

/**
 * Inits the monkey with the given game layer
 * @param gl game layer
 */
-(id) initWithGameLayer:(HelloWorldLayer*)gl;
-(void) jump;
-(bool) isDead;
-(void) reset;
-(bool)isJumping;
-(bool)isRunning;
-(void)moveTo:(b2Vec2)pos;
-(bool)passLevel;
@end
