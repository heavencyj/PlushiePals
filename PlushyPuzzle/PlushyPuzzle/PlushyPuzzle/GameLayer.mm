//
//  HelloWorldLayer.mm
//  PlushyPuzzle
//
//  Created by Lan Li on 2/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// Import the interfaces
#import "GameLayer.h"
#import "PuzzleButtonSprite.h"
#import "NavButton.h"
#import "LHAnimationNode.h"
#import "GameOverScene.h"
#import "Hud.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#define PTM_RATIO 32.0
#define DEGTORAD 0.0174532925199432957f
#define RADTODEG 57.295779513082320876f
#define LINEAR_VELOCITY 10

// Tags
#define PUZZLE 1
#define PLAYER 2
#define BUTTON 3

#pragma mark - GameLayer

@interface GameLayer()
-(void) initPhysics;
@end

@implementation GameLayer

@synthesize loader;

////////////////////////////////////////////////////////////////////////////////

//-(LevelHelperLoader*)loader
//{
//    if (!loader) {
//        loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"level04"];
//    }
//    return loader;
//}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    Hud *hud = [Hud node];
    GameLayer *gameLayer = [[[GameLayer alloc] initWithHud:hud] autorelease];
	
	// add layers as children to scene
	[scene addChild:gameLayer];
    [scene addChild:hud z:10];
    	
	// return the scene
	return scene;
}

-(id) initWithHud:(Hud*)hudRef
{
	if( (self=[super init])) {
        
        // hud reference
        hud = hudRef;
		
		// enable events
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		// init physics
        [self initPhysics];
        
        // registering custom LHSprite class.
        [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[PuzzleButtonSprite class] forTag:PUZZLE];
        [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[PlayerSprite class] forTag:PLAYER];
        
        [[LHTouchMgr sharedInstance] registerTouchBeganObserver:self selector:@selector(touchBegan:) forTag:PUZZLE];
//        [[LHTouchMgr sharedInstance] registerTouchMovedObserver:self selector:@selector(touchMoved:) forTag:PUZZLE];
        [[LHTouchMgr sharedInstance] registerTouchEndedObserver:self selector:@selector(touchEnded:) forTag:PUZZLE];
        
        [[LHTouchMgr sharedInstance] setPriority:0 forTouchesOfTag:PUZZLE];
        
        loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"level05"];
        [self.loader addObjectsToWorld:world cocos2dLayer:self];
        if ([self.loader hasPhysicBoundaries]) {
            [self.loader createPhysicBoundaries:world];
        }
        if (![self.loader isGravityZero]) {
            [self.loader createGravity:world];
        }
        
        // retrieving player sprite
        [self retrieveRequiredObjects];
        
        // following the movements of the playersprite
        [self runAction:[CCFollow actionWithTarget:playerSprite worldBoundary:[self.loader physicBoundariesRect]]];
        
//		[self startDebugDrawing];
		[self scheduleUpdate];
	}
	return self;
}

- (void)touchBegan:(LHTouchInfo*)info
{
    [(PuzzleButtonSprite*)info.sprite rotatePuzzlePiece];
}

- (void)touchEnded:(LHTouchInfo*)info
{
    [(PuzzleButtonSprite*)info.sprite stopRotatePuzzlePiece];
}

-(void) update: (ccTime) dt
{
    // Setting time step for the game. TODO: understand why the velocityIterations and positionIterations are 8 and 1 respectively.
    timeStep = 1.0f/60.0f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(timeStep, velocityIterations, positionIterations);
	
    //Iterate over the bodies in the physics world and update their positions. 
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            //Synchronize the AtlasSprites position and rotation with the corresponding body
            LHSprite *myActor = (LHSprite*)b->GetUserData();
            
            if(myActor != 0)
            {
                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
        }
    }
    
    if (playerSprite.position.y < 80)
    {
        [loader removeAllParallaxesAndChildSprites:TRUE];
        // if pass, show one screen. otherwise show the other, modify gameover scene
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene]];
    }
}

-(void) initPhysics
{    
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
    
	world->SetAllowSleeping(true);
	world->SetContinuousPhysics(true);
}

- (void) retrieveRequiredObjects
{
    playerSprite = (PlayerSprite*)[loader spriteWithUniqueName:@"Monkey"];
    NSAssert(playerSprite!=nil, @"Couldn't find the monkey");
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // update player position base on touch
    // TODO: make sure this method of checking for touch is accurate. 
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
//        NSLog(@"touches begin location: (%f, %f)", nodepos.x, nodepos.y);
        //TODO: Clean this up...
        if ([[hud leftButton]  containsTouchLocation:touch]) {
            [playerSprite move:b2Vec2(-LINEAR_VELOCITY, 0)];
            [playerSprite loadRunAnimation];
            [playerSprite playAnimation];
        }
        else if([[hud rightButton] containsTouchLocation:touch])
        {
            [playerSprite move:b2Vec2(LINEAR_VELOCITY, 0)];
            [playerSprite loadRunAnimation];
            [playerSprite playAnimation];
        }
        else if([[hud jumpButton] containsTouchLocation:touch])
        {
            [playerSprite loadJumpAnimation];
            [playerSprite jump];
        }
    }
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touches moves...");
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touches end...");
    for (UITouch *touch in touches) {
        // check for ending touches for linear movements of the playersprite.
        if ([[hud leftButton] containsTouchLocation:touch]) {
            [playerSprite body]->SetLinearVelocity(b2Vec2(0, 0));
            [playerSprite pauseAnimation];
        }
        else if([[hud rightButton] containsTouchLocation:touch])
        {
            [playerSprite body]->SetLinearVelocity(b2Vec2(0, 0));
            [playerSprite pauseAnimation];
        }
    }
}

//- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
//{
//    
//}
//
//- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
//{
//    
//}

-(void)startDebugDrawing
{
    m_debugDraw = new GLESDebugDraw( [LevelHelperLoader pointsToMeterRatio] );
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    //		flags += b2Draw::e_aabbBit;
    //		flags += b2Draw::e_pairBit;
    //		flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();
	
	kmGLPopMatrix();
}

-(void) dealloc
{
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    [self.loader release];
	
	[super dealloc];
}

@end
