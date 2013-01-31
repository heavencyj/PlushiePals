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

#define ANIM_SPEED 0.3f
#define ANIM_SPEED2 5.0f
#define JUMP_IMPULSE 6.0f

@implementation Monkey

bool jumping = false;
bool running = false;

-(id) initWithGameLayer:(HelloWorldLayer*)gl
{
    self = [super initWithDynamicBody:@"Monkey run 1"
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

-(void) updateCCFromPhysics
{
    [super updateCCFromPhysics];
    
    // update animation phase
    
    if (running) {
        NSString *frameName;
        
        animDelay -= 10.0f/60.0f;
        if(animDelay <= 0)
        {
            animDelay = ANIM_SPEED;
            animPhase++;
            if(animPhase > 3)
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
        
        animDelay -= 0.1f/60.0f;
        if(animDelay <= 2)
        {
            animDelay = ANIM_SPEED2;
            animPhase++;
            if(animPhase > 2)
            {
                animPhase = 1;
            }
        }
        
        // running
        frameName = [NSString stringWithFormat:@"Monkey jump %d.png", animPhase];
        [self setDisplayFrameNamed:frameName];
    }
}

-(void) jump
{
    float impulseFactor = 0.6;
    [self applyLinearImpulse:b2Vec2(0,[self mass]*JUMP_IMPULSE*impulseFactor)
                       point:[self worldCenter]];
    
    jumping = true;
    running = false;
}

-(void) beginContactWithFloor:(GB2Contact *)contact
{
    //NSLog(@"Something contacted monkey's %@", (NSString *)contact.ownFixture->GetUserData());
    
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    if([fixtureId isEqualToString:@"torso"])
    {
        running = true;
        jumping = false;
    }
}


@end
