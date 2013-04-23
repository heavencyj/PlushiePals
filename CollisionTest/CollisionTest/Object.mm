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
#import "RunningGameScene.h"
#import "Maze.h"
#import "GameData.h"

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
    else if([theObjName isEqualToString:@"rock bomb"]) {
        self = [super initWithDynamicBody:@"cactus bomb"
                          spriteFrameName:[NSString stringWithFormat:@"%@ 1.png", theObjName]];
    }
    else if([theObjName isEqualToString:@"mushroom bomb"]) {
        self = [super initWithDynamicBody:@"cactus bomb"
                          spriteFrameName:[NSString stringWithFormat:@"%@ 1.png", theObjName]];
    }
    else{
        self = [super initWithKinematicBody:theObjName
                            spriteFrameName:[NSString stringWithFormat:@"%@.png", theObjName]];
    }
    
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
            
        case MUSHROOM_BOMB:
            objName = @"mushroom bomb";
            break;
        case CACTUS_BOMB:
            objName = @"cactus bomb";
            break;
        case ROCK_BOMB:
            objName = @"rock bomb";
            break;
        case BANANA_SINGLE:
            objName = @"banana single";
            break;
        case MANGOSTEEN:
            objName = @"mangosteen";
            break;
        case PINEAPPLE:
            objName = @"pineapple";
            break;
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
    
    // update animation phase
    if (animateBomb) {
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
        frameName = [objName stringByAppendingString:[NSString stringWithFormat:@" %d.png", animPhase]];
        [self setDisplayFrameNamed:frameName];
    }
    
}

-(void) beginContactWithPlushy:(GB2Contact*)contact
{
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    if ([fixtureId isEqualToString:@"cactus bomb"]) {
        if (!contacted) {
            [self playSound:BOMB_EXPLOSION];
            animateBomb = TRUE;
//            ((Plushy*)contact.otherObject).dead = TRUE;
            ((Plushy*)contact.otherObject).collide = TRUE;
            [self setSensor:TRUE];
            contacted = TRUE;
        }
    }
    else if([fixtureId isEqualToString:@"banana"]) {
        if (!contacted) {
            [self playSound:BANANA_POINTS];
            ((Plushy*)[contact otherObject]).bananaScore += 1;
            [[self ccNode] removeFromParentAndCleanup:YES];
            contacted = TRUE;
        }
    }
    else if([fixtureId isEqualToString:@"mangosteen"]) {
        if (!contacted) {
            [self playSound:BANANA_POINTS];
            ((Plushy*)[contact otherObject]).mangosteenScore += 1;
            [[self ccNode] removeFromParentAndCleanup:YES];
            contacted = TRUE;
        }
    }
    else if([fixtureId isEqualToString:@"pineapple"]) {
        if (!contacted) {
            [self playSound:BANANA_POINTS];
            ((Plushy*)[contact otherObject]).pineappleScore += 1;
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

#define BOMB_EXPLOSION 0
#define BANANA_POINTS 1
#define SPECIAL_FRUIT 2

-(void)playSound:(int)type
{
    NSString *soundEffect;
    switch(type)
    {
        case BOMB_EXPLOSION:
            soundEffect = @"Cactus Bomb.caf";
            break;
        case BANANA_POINTS:
            soundEffect = @"Bananas.caf";
            break;
        case SPECIAL_FRUIT:
            soundEffect = @"Special Object.caf";
            break;
        default:
            break;
    }
    if (soundEffect != nil) {
        [[SimpleAudioEngine sharedEngine] playEffect:soundEffect];
    }
}

- (void) dealloc
{
	[super dealloc];
}

@end
