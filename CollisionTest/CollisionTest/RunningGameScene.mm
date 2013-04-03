//
//  RunningGameScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 4/1/13.
//
//

#import "RunningGameScene.h"
#import "GB2Sprite.h"
#import "GB2DebugDrawLayer.h"
#import "SimpleAudioEngine.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"
#import "CCCustomFollow.h"
// Interface for difference scenes
#import "GameOverScene.h"
#import "MainMenuScene.h"
#import "Hud.h"
#import "BackgroundScene.h"
#import "PauseLayer.h"
//#import "PauseLayer.h"
// Interface for different objects
#import "Plushy.h"
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

// HelloWorldLayer implementation
@implementation RunningGameScene

// Level related variables
int currentLevel;
int mapCount;
float diffFactor;
bool pass1;
float angle1;
int showingTip1;
int rotating1;
bool showBridge;
CCSprite *tutorial1;
TransitionObject *bridge1;
NSInteger easyMaps[3];
NSInteger midMaps[3];
NSInteger hardMaps[3];

//@synthesize maze;
//@synthesize hud;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    Hud *hud = [Hud node];
    BackgroundScene *bg = [BackgroundScene node];
    
    [self initMapLevels];
    diffFactor = 0.6;
    mapCount = 1;
    
    RunningGameScene *game = [[[RunningGameScene alloc] initWithHud:hud] autorelease];
	
	// add layer as a child to scene
    [scene addChild:bg z:0];
	[scene addChild:game z:10];
    [scene addChild:hud z:20];
    pass1 = false;
    rotating1 = 0;
    
	// return the scene
	return scene;
}

// On "init" you need to initialize your instance
-(id) initWithHud:(Hud*)hudRef
{
    hud = hudRef;
	// always call "super" init
	if( (self=[super init]) ) {
        // Add pause layer
        pauseLayer = [[PauseLayer alloc] initWithHud:self];
        [self addChild:pauseLayer z:300];
        
        // Adding object layer
        plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys.png" capacity:150];
        [self addChild:plushyLayer z:200];
        
        // Add monkey
        plushy = [[[Plushy alloc] initWithGameLayer:self] autorelease];
        plushySpeed = 3.0;
        [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
        [plushyLayer addChild:[plushy ccNode] z:10];
        
        // add maze
        if ([MainMenuScene showTips]) {
            currentLevel = 1;
        }
        else {
            // The first map should always be easy
            diffFactor = 1;
            currentLevel = [self levelChooser];
            diffFactor = 0.6;
        }
        
        [self loadMaze:currentLevel];
        
        // load in game objects
        //[self loadBombFile];
        
        // Initializing variables
        nextObject= 5.0f;  // first object to appear after 3s
        objDelay = 2.0f; // next object to appear after 1s
        
        self.isTouchEnabled = YES;
        
        // following the movements of the plushy
        [self runAction:[CCCustomFollow actionWithTarget:[plushy ccNode]]];
        
        // drawing the world boundary for debugging
        [self addChild:[[GB2DebugDrawLayer alloc] init] z:500];
        
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark GameKit delegate
// Add new update method
- (void)update:(ccTime)dt {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //Animate rotation
    //    if (rotating < 0) {
    //        CGPoint p1 = [plushy ccNode].position;
    //        p1.y = (angle > 0) ? p1.y+10:p1.y-80;
    //        CGPoint oldp = [maze ccNode].position;
    //        CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
    //        [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
    //        [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
    //        maze.ccNode.visible = YES;
    //        rotating = 0;
    //    }
    
    // Add objects to path
    //    int objectPattern = [self getRandomNumberBetweenMin:0 andMax:0];
    //    [self nextObject:dt pattern:objectPattern];
    
    //Delay variables decrementing
    if (speedDelay > 0) {
        speedDelay --;
    }
    if (scoreDelay > 0) {
        scoreDelay--;
    }
    
    // Update score with a little bit delay for performance concern
    if (scoreDelay ==0) {
        [hud updateBananaScore:plushy.bananaScore];
        scoreDelay = 10;
    }
    
    // Showing tips
    if (plushy.tip != -1 && [MainMenuScene showTips]) {
        showingTip1 = plushy.tip;
        switch (showingTip1) {
            case 1: case 2: case 3: case 4: case 5: case 6:
                [pauseLayer pauseGame];
                tutorial1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip1]];
                //tutorial = [CCSprite spriteWithFile:@"tutorial 1.png"];
                tutorial1.position = ccp(winSize.width/3, winSize.height/2);
                [self addChild:tutorial1 z:500];
                [plushy setTip];
                break;
                
            case 10: case 11:
                [pauseLayer pauseGame];
                tutorial1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip1]];
                tutorial1.scale = 0.5;
                tutorial1.position = ccp(winSize.width/2, winSize.height/3);
                [self addChild:tutorial1 z:500];
                [plushy setTip];
                break;
                
            default:
                break;
        }
        // show the tool tips and imgs
        // when swife, resume
    }
    
    // NSLog(@"Plushy y location: %f", [[plushy ccNode] convertToWorldSpace:[plushy ccNode].position].y);
    
    // Speed up after a while
    //  if (speedDelay == 0) {
    //    plushySpeed += 1;
    //    mazeSpeed -= 3;
    //    [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
    //    [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
    //    speedDelay = 1000;
    //  }
    //
    
    if (plushy.showmap) {
        currentLevel = [self levelChooser];
        mapCount ++;
        [self loadMaze:currentLevel];
        plushy.showmap = NO;
    }
    
    if (pass1) {
        //[self loadMaze];
        bridge1 = [TransitionObject objectSprite:@"bridge" spriteName:@"bridge.png"];
        [self addChild:bridge1.ccNode];
        CCLOG(@"plushy position is at (%f, %f)", plushy.ccPosition.x, plushy.ccPosition.y);
        bridge1.ccNode.position = ccp(plushy.ccPosition.x, plushy.ccPosition.y - 20);
        CCLOG(@"bridge position is at (%f, %f)", bridge1.ccNode.position.x, bridge1.ccNode.position.y);
        //bridge.ccNode.position = ccp(130, 100);
        [bridge1 setLinearVelocity:[maze linearVelocity]];
        //bridge.ccNode.visible = YES;
        pass1 = false;
        [plushy reset];
    }
    
    // TODO: add some animations here
    else if (plushy.showbridge) {
        pass1 = true;
        // drop something on the screen to show that you passed the level
        //NSLog(@"passsss!");
        //        CCSprite* star = [CCSprite spriteWithFile:@"Star.png"];
        //        star.position = ccp(winSize.width*0.9, winSize.height*0.8);
        //        //        [background addChild:star z:50];
        //        [self addChild:star z:50];
    }
    
    // Plushy dies if it falls out of the screen or hit the wall
    //    else if ([plushy ccNode].position.y < -50 || [plushy isDead])
    else if (plushy.dead)
    {
        if (!plushy.lives) {
            [[GB2Engine sharedInstance] deleteAllObjects];
            // if pass, show one screen. otherwise show the other, modify gameover scene
            [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass1 withLevel:currentLevel withScore:plushy.bananaScore]];
        }
        else
        {
            // destroy 1 life, move maze back and reset plushy
            [plushy destroyLive];
            [maze destroyBody];
//            [maze setSensor:TRUE];
//            [maze moveTo:b2Vec2FromCC([maze ccNode].position.x+250, [maze ccNode].position.y)];
//            [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
//            [plushy resetPlushyPosition];
//            [maze setSensor:FALSE];
            [plushy resetPlushyPosition];
            [self loadMaze:currentLevel];
        }
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}

// Initialize the map levels 
+(void)initMapLevels
{
    easyMaps[0] = 2;
    easyMaps[1] = 6;
    easyMaps[2] = 9;
    midMaps[0] = 4;
    midMaps[1] = 5;
    midMaps[2] = 7;
    hardMaps[0] = 3;
    hardMaps[1] = 8;
    hardMaps[2] = 10;
}

-(int)levelChooser
{
    if (mapCount < 5) {
        if ([self getRandomDouble] < diffFactor) {
            return easyMaps[[self getRandomNumberBetweenMin:0 andMax:2]];
        }
        else return midMaps[[self getRandomNumberBetweenMin:0 andMax:2]];
    }
    else {
        if ([self getRandomDouble] < diffFactor) {
            return hardMaps[[self getRandomNumberBetweenMin:0 andMax:2]];
        }
        else return midMaps[[self getRandomNumberBetweenMin:0 andMax:2]];
    }
}

-(void) loadMaze:(int)ofLevel {

    CCLOG(@"Current level is %d", ofLevel);
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[@"canyon level " stringByAppendingFormat:@"%d.plist", ofLevel]];
    NSString *shape = [@"canyon level " stringByAppendingFormat:@"%d", ofLevel];
    maze = [Maze mazeSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
    [maze setPhysicsPosition:b2Vec2FromCC(100,120)];
    mazeSpeed = -5;
    [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
    //    dummyMaze = [CCSprite spriteWithFile:[@"canyon " stringByAppendingFormat:@"%d.png", level]]; //TODO:
    //    dummyMaze.visible = NO;
    //    [self addChild:dummyMaze z:40];
    [self addChild:[maze ccNode] z:40];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 1
    firstTouch = location;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 2
    lastTouch = location;
    
    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    //    NSLog(@"SwipeLength is: %f", swipeLength);
    // tap gesture
    if (swipeLength < 20) //TODO: Make sure the taps are being registered correctly.
    {
        // If pause button is tapped
        if (CGRectContainsPoint(hud.pauseButtonRect, location)){
            [pauseLayer pauseGame];
            CCLOG(@"plushy position is at (%f, %f)", plushy.ccPosition.x, plushy.ccPosition.y);
            [pauseLayer setLayerPosition:plushy.ccPosition];
            CCLOG(@"pause layer position is at (%f, %f)", pauseLayer.position.x, pauseLayer.position.y);
            [pauseLayer pauseLayerVisible:YES];
        }
        else if ((showingTip1 == 4 || showingTip1 == 5 || showingTip1 == 6)
            && [MainMenuScene showTips]) {
            [pauseLayer resumeGame];
            [self removeChild:tutorial1 cleanup:YES];
            showingTip1 = -1;
        }
        // Otherwise its' for jumping and we prevent double jumping
        else if (!plushy.jumping) {
            if ((showingTip1 == 3)
                && [MainMenuScene showTips]) {
                [pauseLayer resumeGame];
                [self removeChild:tutorial1 cleanup:YES];
                showingTip1 = -1;
            }
            [plushy jump];
        }
    }
    else
    {
        if ((showingTip1 == 1 || showingTip1 == 2 || showingTip1 == 10 || showingTip1 == 11)
            && [MainMenuScene showTips]) {
            [pauseLayer resumeGame];
            [self removeChild:tutorial1 cleanup:YES];
            showingTip1 = -1;
        }
        //Check if the swipe is a left swipe and long enough
        if (firstTouch.x > lastTouch.x && swipeLength > 60) //left swipe (90)
        {
            angle1 = -90;
            CGPoint p1 = [plushy ccNode].position;
            //        p1.y = p1.y+10;
            p1.y = p1.y-80;
            //[plushy setFalling:true];
            
            // Rotate the map without animation
            CGPoint oldp = [maze ccNode].position;
            CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(-90) of:oldp around:p1];
            [maze transform:b2Vec2FromCGPoint(newp) withAngle:-90];
            //            [self animateRotation:angle];
        }
        else if(firstTouch.x < lastTouch.x && swipeLength > 60) // right swipe (-90)
        {
            angle1 = 90;
            CGPoint p1 = [plushy ccNode].position;
            //        p1.y = p1.y-80;
            p1.y = p1.y+10;
            //[plushy setFalling:true];
            // Rotate the map without animation
            CGPoint oldp = [maze ccNode].position;
            CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(90) of:oldp around:p1];
            [maze transform:b2Vec2FromCGPoint(newp) withAngle:90];
            //            [self animateRotation:angle];
        }
    }
}

-(void)animateRotation:(int)angle
{
    if ((showingTip1 == 1 || showingTip1 == 2 || showingTip1 == 10 || showingTip1 == 11)
        && [MainMenuScene showTips]) {
        [pauseLayer resumeGame];
        [self removeChild:tutorial1 cleanup:YES];
        showingTip1 = -1;
    }
    //cameraDelay = 10;
    //[plushy setFalling:true];
    
    
    //  // To to animate
    //    CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
    //    CCLOG(@"dummymaze is at %f and %f", dummyMaze.position.x, dummyMaze.position.y);
    //
    //    //  angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    //    CGPoint p1 = [plushy ccNode].position;
    //    CGPoint p2 = [maze ccNode].position;
    //    float dy = (angle > 0) ? 15:-40;
    //    CGPoint tempAnchorPoint;
    //    int a = (int)dummyMaze.rotation/90 % 2;
    //    switch (ABS(a)) {
    //        case 0:
    //            tempAnchorPoint = ccp(ABS(p1.x-p2.x)/dummyMaze.contentSize.width, 1-ABS(p1.y-p2.y+dy)/dummyMaze.contentSize.height);
    //            break;
    //
    //        case 1:
    //            tempAnchorPoint = ccp(ABS(p1.y-p2.y+dy)/dummyMaze.contentSize.width, 1-ABS(p1.x-p2.x)/dummyMaze.contentSize.height);
    //            break;
    //
    //        default:
    //            break;
    //    }
    //    dummyMaze.anchorPoint = tempAnchorPoint;
    //    dummyMaze.position = ccp(180, 120);
    //    CCLOG(@"dummymaze anchor is at %f and %f",dummyMaze.anchorPoint.x, dummyMaze.anchorPoint.y);
    //    CCLOG(@"dummymaze pos is at %f and %f",dummyMaze.position.x, dummyMaze.position.y);
    //    [maze ccNode].visible = NO;
    //    [dummyMaze runAction:[CCSequence actions:
    //                          [CCCallFuncN actionWithTarget:self selector:@selector(setNodeVisible:)],
    //                          [CCRotateBy actionWithDuration:0.5 angle:angle],
    //                          [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
    //    [maze setLinearVelocity:b2Vec2(0,0)];
    
    // Rotate the map without animation
    //angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    CGPoint p1 = [plushy ccNode].position;
    p1.y = (angle > 0) ? p1.y+10:p1.y-80;
    CGPoint oldp = [maze ccNode].position;
    CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
    [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
    
}

@end
