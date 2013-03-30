//
//  Monkey.m
//  CollisionTest
//
//  Created by Lan Li on 1/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Plushy.h"
#import "GameScene.h"
#import "GB2Contact.h"

#define ANIM_SPEED 2.0f
#define ANIM_SPEED2 4.0f
#define ANIM_SPEED3 3.0f
#define ANIM_DELAY 0.25f
#define JUMP_IMPULSE 10.0f
const float kMaxDistanceFromCenter = 120.0f;
const float kMinDistanceFromCenter = 100.0f;

@implementation Plushy

@synthesize bananaScore;
@synthesize lives;
@synthesize gameLayer;
@synthesize jumping;
@synthesize running;
@synthesize collide;
@synthesize pass;
@synthesize dead;
@synthesize die;
@synthesize falling;
@synthesize showbridge;
@synthesize tip;
@synthesize showmap;

//TODO: which initialization is being used here?
-(id) initWithGameLayer:(GameScene*)gl
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
        
        // store number of bananas collected
        bananaScore = 0;
        
        // initalize 3 lives for the monkey
        lives = 3;
        
        tip = -1;
        [self loadLives];
        
        // setting initial plushy position
        initialPosition = b2Vec2FromCC(150, 180);
        [self setPhysicsPosition:initialPosition];
    }
    return self;
}

-(id) initWithGameLayer:(GameScene*)gl withShape:(NSString*)shape withSprite:(NSString*)sprite
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
    [self setPhysicsPosition:b2Vec2FromCC(130, [self ccNode].position.y)];
    
    // update animation phase
    if (running && !collide && !die) {
        
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
                collide = false;
                die = true;
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

-(void)resetPlushyPosition
{
    [self reset];
    [self setBodyShape:@"Monkey"];
    [self setPhysicsPosition:initialPosition];
}

-(void) loadLives
{
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    int x_pos = 20;
    hearts = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i=0; i<3; i++) {
        CCSprite *aHeart = [CCSprite spriteWithFile:@"heart.png"]; //TODO: for now using the button
        aHeart.position = ccp(x_pos, 290);
        x_pos += 30;
        [hearts addObject:aHeart];
        [gameLayer.hud addChild:aHeart z:100];
    }
}

-(void) destroyLive
{
    lives-=1;
    if ([hearts count] != 0) {
        CCSprite *aHeart = [hearts objectAtIndex:lives];
        [aHeart removeFromParentAndCleanup:TRUE];
        [hearts removeObjectAtIndex:lives];
    }
}

-(void) jump
{
    float impulseFactor = 1;
    [self applyLinearImpulse:b2Vec2(0,[self mass]*JUMP_IMPULSE*impulseFactor)
                       point:[self worldCenter]];
    
    jumping = true;
    running = false;
    falling = true;
    animPhase = 1;
    
    // play the monkey jump sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"jumping.caf"];
}

-(void) reset
{
    jumping = false;
    collide = false;
    dead = false;
    die = false;
    running = true;
    pass = false;
    falling = false;
    tip = -1;
}

-(void) beginContactWithMaze:(GB2Contact *)contact
{
    //NSLog(@"Something contacted monkey's %@", (NSString *)contact.ownFixture->GetUserData());
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    NSString *otherfixtureId = (NSString *)contact.otherFixture->GetUserData();
    if([fixtureId isEqualToString:@"feet"])
    {
        running = true;
        jumping = false;
        falling = false;
    }
    
    if([fixtureId isEqualToString:@"collision"])
    {
        if ([otherfixtureId hasPrefix:@"tip"]) {
            tip = [[otherfixtureId substringFromIndex:3] intValue];
            CCLOG(@"tip is %d", tip);
        }
        else if ([otherfixtureId isEqualToString:@"bridgeend"]) {
            
            CCLOG(@"show new map");
            showmap = true;
        }
        
        else if ([otherfixtureId isEqualToString:@"start"]) {
            CCLOG(@"hit start point");
            // hide bridge
            //showbridge = true;
        }
        else if ([otherfixtureId isEqualToString:@"win"] && !showbridge) {
            pass = true;
            //show bridge
            showbridge = true;
        }
        else {
            running = false;
            jumping = false;
            collide = true;
            animPhase = 1;
        }
    }
    
}

-(void) beginContactWithTransitionObject:(GB2Contact *)contact {
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    NSString *otherfixtureId = (NSString *)contact.otherFixture->GetUserData();
    
    if([fixtureId isEqualToString:@"collision"])
    {
        if ([otherfixtureId isEqualToString:@"bridgeend"]) {
            
            CCLOG(@"show new map");
            showmap = true;
        }
    }

}


-(bool)isRunning {
    return running && !collide && !die && !falling;
}

-(void)moveTo:(b2Vec2)pos
{
    body->SetTransform(pos, body->GetAngle());
}

-(void)setTip{
    tip = -1;
}


@end
