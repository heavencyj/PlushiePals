 //
//  Monkey.m
//  CollisionTest
//
//  Created by Lan Li on 1/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Plushy.h"
#import "RunningGameScene.h"
#import "GB2Contact.h"
#import "CCCustomFollow.h"
#import "SimpleAudioEngine.h"
#import "GameData.h"

#define ANIM_SPEED 2.0f
#define ANIM_SPEED2 4.0f
#define ANIM_SPEED3 3.0f
#define ANIM_DELAY 0.25f
#define JUMP_IMPULSE 10.0f
const float kMaxDistanceFromCenter = 120.0f;
const float kMinDistanceFromCenter = 100.0f;

@implementation Plushy

@synthesize gameLayer;
// State flag
@synthesize jumping;
@synthesize running;
@synthesize collide;
@synthesize pass;
@synthesize dead;
@synthesize die;
//@synthesize falling;
@synthesize sliding;
@synthesize swipeRange;
@synthesize showmap;
@synthesize loadmap;
@synthesize tip;
@synthesize bananaScore;
@synthesize onBridge;

NSString* plushyName;

bool shapechange;

//TODO: which initialization is being used here?
-(id) initWithGameLayer:(RunningGameScene*)gl
{
    switch ([GameData sharedGameData].plushy) {
        case 1:
            plushyName = @"Monkey";
            break;
            
        case 2:
            plushyName = @"Pig";
            break;
            
        case 3:
            plushyName = @"Bear";
            break;
            
        default:
            break;
    }
    
    self = [super initWithDynamicBody:@"Monkey"
                      spriteFrameName:[plushyName stringByAppendingString:@" run 1.png"]];
    
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
        //bananaScore = [[GameData sharedGameData] bananaCount];
        // initalize 3 lives for the monkey
        tip = -1;
        //[self loadLives];
        
        swipeRange = true;
        
        // setting initial plushy position
        //initialPosition = b2Vec2FromCC([[CCDirector sharedDirector] winSize].width/2-50, 180);
        initialPosition = b2Vec2FromCC(0, 180);
        [self setPhysicsPosition:initialPosition];
    }
    return self;
}

-(id) initWithGameLayer:(RunningGameScene*)gl withShape:(NSString*)shape withSprite:(NSString*)sprite
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
        // store number of bananas collected
        //bananaScore = [[GameData sharedGameData] bananaCount];
        // initalize 3 lives for the monkey
        tip = -1;
        //[self loadLives];
        
        // setting initial plushy position
        initialPosition = b2Vec2FromCC(150, 180);
        [self setPhysicsPosition:initialPosition];
    }
    return self;
}

-(void) updateCCFromPhysics
{
    [super updateCCFromPhysics];
    
    // Continuously reset the monkey back to the same physics position each time.
    [self setPhysicsPosition:b2Vec2FromCC([[CCDirector sharedDirector] winSize].width/2-50, [self ccNode].position.y)];
    
    // update animation phase
//    if (sliding) {
//        NSString *frameName;
//        animDelay -= ANIM_DELAY;
//        if(animDelay <= 0)
//        {
//            animDelay = ANIM_SPEED;
//            animPhase++;
//            if(animPhase > 3)
//            {
//                animPhase = 1;
//            }
//        }
//        // sliding
//        [self setBodyShape:@"Monkey slide"];
//        shapechange = true;
//        frameName = [NSString stringWithFormat:@"Monkey slide %d.png", animPhase];
//        [self setDisplayFrameNamed:frameName];
//        [Plushy playSound:SLIDING];
//    }
    
    if (running && !collide && !die) {
        
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
        if (shapechange){
            [self setBodyShape:@"Monkey"];
            shapechange = false;
        }
        frameName = [plushyName stringByAppendingFormat:@" run %d.png", animPhase];
        [self setDisplayFrameNamed:frameName];
        //[self playSound:RUNNING];
    }
    else if (onBridge) {
        if (!pass) {
            running = true;
        }
        else {
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
            // running and cheering
            if (shapechange){
                [self setBodyShape:@"Monkey"];
                shapechange = false;
            }
            frameName = [plushyName stringByAppendingFormat:@" win %d.png", animPhase];
            [self setDisplayFrameNamed:frameName];
        }
    }
    else if (jumping) {
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
        frameName = [plushyName stringByAppendingFormat:@" jump %d.png", animPhase];
        [self setDisplayFrameNamed:frameName];
    }
    
    else if (collide) {
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
        frameName = [plushyName stringByAppendingFormat:@" collide %d.png", animPhase];
        [self setDisplayFrameNamed:frameName];
        if (animPhase == 1) {
            [Plushy playSound:COLLIDING];
        }
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
        shapechange = true;
        frameName = [plushyName stringByAppendingFormat:@" die 0%d.png", animPhase];
        //frameName = [@"Monkey" stringByAppendingFormat:@" die 0%d.png", animPhase];
        [self setDisplayFrameNamed:frameName];
    }
}

-(void)resetPlushyPosition
{
    [self reset];
    [self setBodyShape:@"Monkey"];
    [self setPhysicsPosition:initialPosition];
    [gameLayer runAction:[CCCustomFollow actionWithTarget:[self ccNode]]];
}


-(void) destroyAllLives
{
    for (CCSprite* aHeart in hearts) {
        [aHeart removeFromParentAndCleanup:TRUE];
    }
}

-(void) jump
{
    if (onBridge) {
        return;
    }
    float impulseFactor = 1;
    [self applyLinearImpulse:b2Vec2(0,[self mass]*JUMP_IMPULSE*impulseFactor)
                       point:[self worldCenter]];
    
    jumping = true;
    running = false;
    onBridge = false;
    animPhase = 1;
    
    //[Plushy playSound:JUMPING];
    [[SimpleAudioEngine sharedEngine] playEffect:@"jump.caf"];
}

-(void) reset
{
    jumping = false;
    collide = false;
    dead = false;
    die = false;
    running = true;
    pass = false;
    showmap = false;
    loadmap = false;
    //swipeRange = false;
    swipeRange = true;
    onBridge = false;
    tip = -1;
}

-(void) beginContactWithMaze:(GB2Contact *)contact
{
    //NSLog(@"Something contacted monkey's %@", (NSString *)contact.ownFixture->GetUserData());
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    NSString *otherfixtureId = (NSString *)contact.otherFixture->GetUserData();
    onBridge = false;
    if([fixtureId isEqualToString:@"feet"])
    {
        running = true;
        jumping = false;
//        die = false;
//        collide = false;
    }
    else if([fixtureId isEqualToString:@"collision"])
    {
        if ([otherfixtureId hasPrefix:@"tip"]) {
            tip = [[otherfixtureId substringFromIndex:3] intValue];
            //CCLOG(@"tip is %d", tip);
        }
        else if ([otherfixtureId isEqualToString:@"turn"]) {
            swipeRange = true;
        }
        else if ([otherfixtureId isEqualToString:@"noturn"]) {
            //swipeRange = false;
        }
        else if ([otherfixtureId isEqualToString:@"start"]) {
            CCLOG(@"hit start point");
            // hide bridge
            [self reset];
        }
        else if ([otherfixtureId isEqualToString:@"win"]) {
            pass = true;
            [RunningGameScene resetSwipe];
            //show bridge
//            showmap = true;
        }
        else if([otherfixtureId isEqualToString:@"showbridge"]) {
            [self.gameLayer.currMazeLayer showBridge];
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
//    NSString *otherfixtureId = (NSString *)contact.otherFixture->GetUserData();
    if([fixtureId isEqualToString:@"feet"])
    {
        running = false;
        jumping = false;
        onBridge = true;
        //falling = false;
    }
    if([fixtureId isEqualToString:@"collision"])
    {
//        if ([otherfixtureId isEqualToString:@"bridgeend"]) {
//            CCLOG(@"show new map");
//            loadmap = true;
//        }
    }
}


-(bool)isRunning {
    return running && !collide && !die;
}

-(void)moveTo:(b2Vec2)pos
{
    body->SetTransform(pos, body->GetAngle());
}

-(void)setTip{
    tip = -1;
}

+(void) playSound:(int)type
{
    NSString *soundEffect = @"";
    switch(type)
    {
        case RUNNING:
//            if (animPhase == 2) {
//                soundEffect = @"Footstep.caf";
//            }
            break;
        case JUMPING:
            soundEffect = @"jump.caf";
            break;
        case SLIDING:
            soundEffect = @"Slide.caf";
            break;
        case COLLIDING:
            soundEffect = @"Collision.caf";
            break;
        case DYING:
            soundEffect = @"GameOver.caf";
            break;
        default:
            break;
    }
    
    /*
     pitch - [0.5 to 2.0] think of it as the "note" of the sound. Giving a higher pitch number makes the sound play at a "higher note".
     pan - [-1.0 to 1.0] stereo affect. Below zero plays your sound more on the left side. Above 0 plays to the right. 0.0 is dead-center.
     gain - [0.0 and up] volume. 1.0 is the volume of the original file
     */
    if (soundEffect.length != 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:soundEffect];
    }
}

@end
