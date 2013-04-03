//
//  Object.m
//  CollisionTest
//
//  Created by Lan Li on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Object.h"
#import "GB2Contact.h"
#import "Plushy.h"
#import "Maze.h"

#define ANIM_DELAY 0.25f
#define ANIM_SPEED 2.0f

@implementation Object

@synthesize objName;

-(id) initWithObject:(NSString*)theObjName
{
    if ([theObjName isEqualToString:@"cactus bomb"]) {
        self = [super initWithDynamicBody:theObjName
                          spriteFrameName:[NSString stringWithFormat:@"%@ 1.png", theObjName]];
    }
    else if ([theObjName isEqualToString:@"bridge"]) {
        self = [super initWithDynamicBody:theObjName
                          spriteFrameName:[NSString stringWithFormat:@"%@.png", theObjName]];
    }
    else{
        self = [super initWithKinematicBody:theObjName
                            spriteFrameName:[NSString stringWithFormat:@"%@.png", theObjName]];
    }
//    else{
//        self = [super initWithDynamicBody:theObjName
//                            spriteFrameName:[NSString stringWithFormat:@"%@.png", theObjName]];
//    }
    
    if(self)
    {
        self.objName = theObjName;
    }
    return self;
}

+(Object*) randomObject:(int)type
{
    NSString *objName;
    switch(type)
    {
        case BANANA_BOMB:
            objName = @"banana bomb";
            break;
            
        case BANANA_BUNCH:
            objName = @"banana bunch";
            break;
        case CACTUS_BOMB:
            objName = @"cactus bomb";
            break;
        case SPIDER:
            objName = @"spider";
            break;
        case BANANA_SINGLE:
            objName = @"banana single";
            break;
        case BRIDGE:
            objName = @"bridge";
        default:
            break;
    }
    return [[[self alloc] initWithObject:objName] autorelease];
}

-(void)changeType:(b2BodyType)type
{
    body->SetType(type);
}

-(void)setSensor:(BOOL)isSensor
{
    b2Fixture* f = body->GetFixtureList();
    f->SetSensor(isSensor);
}

-(void) updateCCFromPhysics
{
    [super updateCCFromPhysics];
    
//    if (bodyTypeChange) {
//        body->SetType(b2_kinematicBody);
//        //[self setBodyType:b2_kinematicBody];
//        [self setLinearVelocity:b2Vec2(-5, 0)];
//        bodyTypeChange = FALSE;
//    }
    
    // update animation phase
    if (animateBomb) {
        
        //    [self setPhysicsPosition:b2Vec2FromCC(200, 140)];
        //
        //    float dy = [self ccNode].position.y -140;
        
        NSString *frameName;
        
        animDelay -= ANIM_DELAY;
        
        if(animDelay <= 0)
        {
            animDelay = ANIM_SPEED;
            animPhase++;
            if(animPhase > 4)
            {
                animPhase = 1;
                animateBomb = FALSE;
                [[self ccNode] removeFromParentAndCleanup:YES];
            }
        }
        
        // running
        frameName = [NSString stringWithFormat:@"cactus bomb %d.png", animPhase];
        [self setDisplayFrameNamed:frameName];
    }
    
}

-(void) beginContactWithPlushy:(GB2Contact*)contact
{
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    if ([fixtureId isEqualToString:@"cactus bomb"]) {
        if (!contacted) {
            animateBomb = TRUE;
            ((Plushy*)contact.otherObject).dead = TRUE;
            [self setSensor:TRUE];
            contacted = TRUE;
        }
    }
    else
    {
        if (!contacted) {
            ((Plushy*)[contact otherObject]).bananaScore += 1;
            [[self ccNode] removeFromParentAndCleanup:YES];
            contacted = TRUE;
        }
    }
}

-(void) beginContactWithMaze:(GB2Contact*)contact
{
    //[[self ccNode] removeFromParentAndCleanup:YES];
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    if ([fixtureId isEqualToString:@"cactus bomb"]) {
//        self.ccNode.visible = YES;
//        bodyTypeChange = TRUE;
        //[self setSensor:NO];
    }
}

-(b2Body*)getBody
{
    return body;
}

@end
