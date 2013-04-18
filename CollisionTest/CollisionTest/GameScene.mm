//
//  GameScene.mm
//  Cocos2d Test
//
//  Created by Lan Li & Heaven Chen on 1/13/13.
//  Copyright 2013. All rights reserved.
//

#import "GameScene.h"
#import "Plushy.h"
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SimpleAudioEngine.h"

#import "GB2Sprite.h"
#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"
#import "CCCustomFollow.h"

// Interface for difference scenes
#import "GameOverScene.h"
#import "MainMenuScene.h"
#import "BackgroundScene.h"
#import "PauseLayer.h"
#import "MazeLayer.h"
#import "Hud.h"

// Interface for different objects
#import "Object.h"
#import "TransitionObject.h"

// Macros for constants
#define PTM_RATIO 32
#define WALKING_FRAMES 3
#define MAZE_LOW 30
#define ARC4RANDOM_MAX 0x100000000
#define ICON_DIST 60
#define round(x) ((x) < LONG_MIN-0.5 || (x) > LONG_MAX+0.5)

#pragma mark - GameScene

@implementation GameScene

// Level related variables
int level;
bool pass;
float angle;
int showingTip;
int rotating;
bool showBridge;
CCSprite *tutorial;
TransitionObject *bridge;

@synthesize hud;
@synthesize currMazeLayer;


// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    Hud *hud = [Hud node];
    BackgroundScene *bg = [BackgroundScene node];
    GameScene *game = [[[GameScene alloc] initWithHud:hud] autorelease];
	
	// add layer as a child to scene
    [scene addChild:bg z:0];
	[scene addChild:game z:10];
    [scene addChild:hud z:20];
    pass = false;
    rotating = 0;
	
	// return the scene
	return scene;
}

+(CCScene *)scene:(int)withLevel
{
    level = withLevel;
    pass = false;
    return [self scene];
}

// On "init" you need to initialize your instance
-(id) initWithHud:(Hud*)hudRef
{
    hud = hudRef;
	// always call "super" init
	if( (self=[super init]) ) {
        // Add pause layer
        pauseLayer = [[PauseLayer alloc] initWithHud:self];
        [hud addChild:pauseLayer z:300];
        
        // Adding object layer
        plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys.png" capacity:150];
        [self addChild:plushyLayer z:200];
        
        // Add monkey
        plushy = [[[Plushy alloc] initWithGameLayer:self] autorelease];
        plushySpeed = 3.0;
        [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
        [plushyLayer addChild:[plushy ccNode] z:10];
        
        // Add maze layer
//        mazeLayer = [[MazeLayer alloc] init];
//        [self addChild:mazeLayer z:10];
        
        self.isTouchEnabled = YES;
        
        // following the movements of the plushy
        [self runAction:[CCCustomFollow actionWithTarget:[plushy ccNode]]];
        
        // drawing the world boundary for debugging
//        [self addChild:[[GB2DebugDrawLayer alloc] init] z:500];
        
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark GameKit delegate
// Add new update method
- (void)update:(ccTime)dt {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //Delay variables decrementing
    if (speedDelay > 0) {
        speedDelay --;
    }
    if (scoreDelay > 0) {
        scoreDelay--;
    }
    
    // Update score with a little bit delay for performance concern
    if (scoreDelay ==0) {
        //[hud updateScore:plushy.bananaScore];
        scoreDelay = 10;
    }
    
    if (plushy.tip != -1 && [MainMenuScene showTips]) {
        showingTip = plushy.tip;
        switch (showingTip) {
            case 1: case 2: case 3: case 4: case 5: case 6:
                [pauseLayer pauseGame];
                tutorial = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip]];
                //tutorial = [CCSprite spriteWithFile:@"tutorial 1.png"];
                tutorial.position = ccp(winSize.width/3, winSize.height/2);
                [self addChild:tutorial z:500];
                [plushy setTip];
                break;
                
            case 10: case 11:
                [pauseLayer pauseGame];
                tutorial = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip]];
                tutorial.scale = 0.5;
                tutorial.position = ccp(winSize.width/2, winSize.height/3);
                [self addChild:tutorial z:500];
                [plushy setTip];
                break;
                
            default:
                break;
        }
    }
    
    if (pass) {
        [[GB2Engine sharedInstance] deleteAllObjects];
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:0]];
    }
    
    // TODO: add some animations here
    else if (plushy.pass) {
        pass = true;
    }
    
    // Plushy dies if it falls out of the screen or hit the wall
    //    else if ([plushy ccNode].position.y < -50 || [plushy isDead])
    else if (plushy.dead)
    {
        if (!plushy.lives) {
            [[GB2Engine sharedInstance] deleteAllObjects];
            // if pass, show one screen. otherwise show the other, modify gameover scene
            [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:0]];
        }
        else
        {
            // destroy 1 life, move maze back and reset plushy
            [plushy destroyLive];
//            [mazeLayer reset];
        }
    }
}

-(void)nextObject:(ccTime)dt pattern:(int)p
{
    if (pass) {
        return;
    }
    
    nextObject -= dt;
    if(nextObject <=0)
    {
        if (p == 2) {
            //arc pattern TODO:hard coded for now
            int initalX = [[CCDirector sharedDirector] winSize].width;
            int initialY = [plushy ccNode].position.y+50;
            if (initialY+30 < 280) { //TODO: ensure that the bananas don't go over the scoring HUD.
                Object *obj1 = [Object randomObject:BANANA_SINGLE];
                [obj1 setPhysicsPosition:b2Vec2FromCC(initalX, initialY)];
                [obj1 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj1 ccNode] z:38];
                Object *obj2 = [Object randomObject:BANANA_SINGLE];
                [obj2 setPhysicsPosition:b2Vec2FromCC(initalX+30, initialY+30)];
                [obj2 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj2 ccNode] z:38];
                Object *obj3 = [Object randomObject:BANANA_SINGLE];
                [obj3 setPhysicsPosition:b2Vec2FromCC(initalX+80, initialY+30)];
                [obj3 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj3 ccNode] z:38];
                Object *obj4 = [Object randomObject:BANANA_SINGLE];
                [obj4 setPhysicsPosition:b2Vec2FromCC(initalX+110, initialY)];
                [obj4 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj4 ccNode] z:38];
            }
            nextObject = [GameScene getRandomNumberBetweenMin:5 andMax:10];
        }
        if (p == 1) {
            int initalX = [[CCDirector sharedDirector] winSize].width;
            int initialY = [plushy ccNode].position.y+80;
            if (initialY < 280) {
                Object *obj1 = [Object randomObject:BANANA_SINGLE];
                [obj1 setPhysicsPosition:b2Vec2FromCC(initalX, initialY)];
                [obj1 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj1 ccNode] z:38];
                Object *obj2 = [Object randomObject:BANANA_SINGLE];
                [obj2 setPhysicsPosition:b2Vec2FromCC(initalX+40, initialY)];
                [obj2 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj2 ccNode] z:38];
                Object *obj3 = [Object randomObject:BANANA_SINGLE];
                [obj3 setPhysicsPosition:b2Vec2FromCC(initalX+80, initialY)];
                [obj3 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj3 ccNode] z:38];
                Object *obj4 = [Object randomObject:BANANA_SINGLE];
                [obj4 setPhysicsPosition:b2Vec2FromCC(initalX+120, initialY)];
                [obj4 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj4 ccNode] z:38];
            }
            nextObject = [GameScene getRandomNumberBetweenMin:5 andMax:10];
        }
        if (p == 0) {
            // drop a banana peel for speed up
            //            Object *obj1 = [Object randomObject:CACTUS_BOMB];
            //            int initialX = [self getRandomNumberBetweenMin:[plushy ccNode].position.x+50 andMax:[[CCDirector sharedDirector] winSize].width ];
            //            [obj1 setPhysicsPosition:b2Vec2FromCC(initialX, [[CCDirector sharedDirector] winSize].height)];
            //            [obj1 setLinearVelocity:b2Vec2(0, -40)];
            //            [obj1 ccNode].visible = NO;
            //            //[obj1 setSensor:YES];
            //            //TODO: make the body sensor body temporarily
            //            [self addChild:[obj1 ccNode] z:30];
            //            nextObject = [self getRandomNumberBetweenMin:5 andMax:8];
        }
    }
}

+ (double) getRandomDouble
{
    return ((double)arc4random() / ARC4RANDOM_MAX);
}

+(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}

// Add new method
- (void)setInvisible:(CCNode *)node {
    node.visible = NO;
    rotating = -1;
}
- (void)setNodeVisible:(CCNode *)node {
    node.visible = YES;
    rotating = 1;
}

-(void)setPlushyIsDead:(BOOL)d {
    plushy.dead = d;
}


@end
