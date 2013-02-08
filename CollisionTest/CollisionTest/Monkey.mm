//
//  Monkey.m
//  CollisionTest
//
//  Created by Lan Li on 1/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Monkey.h"
#import "HelloWorldLayer.h"
#import "GB2Contact.h"

#define ANIM_SPEED 2.0f
#define ANIM_SPEED2 4.0f
#define ANIM_SPEED3 3.0f
#define ANIM_DELAY 0.25f
#define JUMP_IMPULSE 10.0f

@implementation Monkey

-(id) initWithGameLayer:(HelloWorldLayer*)gl
{
  self = [super initWithDynamicBody:@"Monkey"
                    spriteFrameName:@"Monkey run 1.png"];
  //    self = [super initWithKinematicBody:@"Monkey run 1"
  //                      spriteFrameName:@"Monkey run 1.png"];
  
  if(self)
  {
    // do not let the monkey rotate
    [self setFixedRotation:true];
    
    // monkey uses continuous collision detection
    // to avoid sticking him into fast falling objects
    [self setBullet:YES];
    
    // store the game layer
    gameLayer = gl;
  }
  return self;
}

-(id) initWithGameLayer:(HelloWorldLayer*)gl withShape:(NSString*)shape withSprite:(NSString*)sprite
{
  self = [super initWithDynamicBody:shape
                    spriteFrameName:sprite];
  
  if(self)
  {
    // do not let the monkey rotate
    [self setFixedRotation:true];
    
    // monkey uses continuous collision detection
    // to avoid sticking him into fast falling objects
    [self setBullet:YES];
    
    // store the game layer
    gameLayer = gl;
  }
  return self;
}

-(void) updateCCFromPhysics
{
  [super updateCCFromPhysics];
  
  // Continuously reset the monkey back to the same physics position each time.
  //[self setPhysicsPosition:b2Vec2FromCC(100, 90)];
  [self setPhysicsPosition:b2Vec2FromCC(200, [self ccNode].position.y)];
  
  // update animation phase
  if (running) {
    NSString *frameName;
    
    animDelay -= ANIM_DELAY;
    
    if(animDelay <= 0)
    {
      animDelay = ANIM_SPEED;
      animPhase++;
      if(animPhase > 4)
      {
        animPhase = 1;
      }
    }
    
    // running
    frameName = [NSString stringWithFormat:@"Monkey run %d.png", animPhase];
    [self setDisplayFrameNamed:frameName];
  }
  
  if (jumping) {
    NSString *frameName;
    
    animDelay -= ANIM_DELAY;
    
    if(animDelay <= 0)
    {
      animDelay = ANIM_SPEED;
      animPhase++;
      if(animPhase > 4)
      {
        animPhase = 1;
      }
    }
    
    // jumping
    frameName = [NSString stringWithFormat:@"Monkey jump %d.png", animPhase];
    [self setDisplayFrameNamed:frameName];
  }
  
  if (collide) {
    NSString *frameName;
    
    animDelay -= ANIM_DELAY;
    
    if(animDelay <= 0)
    {
      animDelay = ANIM_SPEED;
      animPhase++;
      if(animPhase > 3)
      {
        animPhase = 1;
        die = true;
        collide = false;
      }
    }
    
    if(animPhase > 3)
    {
      animPhase = 1;
    }
    
    // collide
    frameName = [NSString stringWithFormat:@"Monkey collision %d.png", animPhase];
    [self setDisplayFrameNamed:frameName];
  }
  
  if (die) {
    NSString *frameName;
    
    animDelay -= ANIM_DELAY;
    if(animDelay <= 0)
    {
      animDelay = ANIM_SPEED;
      animPhase++;
      if(animPhase > 4)
      {
        animPhase = 1;
        dead = true;
        die = false;
      }
    }
    
    // die
    [self setBodyShape:@"Monkey die"];
    frameName = [NSString stringWithFormat:@"Monkey die 0%d.png", animPhase];
    [self setDisplayFrameNamed:frameName];
  }
}

-(bool)isDead
{
  return dead;
}

-(void) jump
{
  float impulseFactor = 1;
  [self applyLinearImpulse:b2Vec2(0,[self mass]*JUMP_IMPULSE*impulseFactor)
                     point:[self worldCenter]];
  
  jumping = true;
  running = false;
  animPhase = 1;
}

-(bool)isJumping
{
  return jumping;
}

-(void) reset
{
  jumping = false;
  collide = false;
  dead = false;
  die = false;
  running = true;
  
}

-(void) beginContactWithFloor:(GB2Contact *)contact
{
  //NSLog(@"Something contacted monkey's %@", (NSString *)contact.ownFixture->GetUserData());
  NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
  if([fixtureId isEqualToString:@"feet"])
  {
    running = true;
    jumping = false;
    
  }
  if([fixtureId isEqualToString:@"collision"])
  {
    running = false;
    jumping = false;
    collide = true;
    animPhase = 1;
  }

}

-(void)moveTo:(b2Vec2)pos
{
  body->SetTransform(pos, body->GetAngle());
}

@end
