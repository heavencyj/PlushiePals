//
//  Monkey.m
//  CollisionTest
//
//  Created by Lan Li on 1/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Monkey.h"
#import "HelloWorldLayer.h"

#define ANIM_SPEED 0.3f 

@implementation Monkey

-(id) initWithGameLayer:(HelloWorldLayer*)gl
{
    self = [super initWithDynamicBody:@"Monkey run 1"
                      spriteFrameName:@"Monkey run 1.png"];
    
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
    
    animDelay -= 10.0f/60.0f;
    if(animDelay <= 0)
    {
        animDelay = ANIM_SPEED;
        animPhase++;
        if(animPhase > 2)
        {
            animPhase = 1;
        }
    }
    
    // update animation phase
    NSString *frameName;
    
    // running
    frameName = [NSString stringWithFormat:@"Monkey run %d.png", animPhase];
    [self setDisplayFrameNamed:frameName];
}


@end
