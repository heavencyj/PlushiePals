//
//  HelloWorldLayer.m
//  Cocos2d Test
//
//  Created by Lan Li & Heaven Chen on 1/13/13.
//  Copyright 2013. All rights reserved.
//


// Interfaces for box2d and audio engine
#import "GameScene.h"
//#import "CCNode+SFGestureRecognizers.h"
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

@synthesize maze;
@synthesize hud;

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
    //NSLog(@"level is %d", level);
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
        [self loadMaze];
        
        // load in game objects
        [self loadBombFile];
        
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
        // show the tool tips and imgs
        // when swife, resume
    }
    
    //    NSLog(@"Plushy y location: %f", [[plushy ccNode] convertToWorldSpace:[plushy ccNode].position].y);
    
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
        [self loadMaze:2];
        plushy.showmap = NO;
    }
    
    if (pass) {
        if (level == 11) {
            //[self loadMaze];
            bridge = [TransitionObject objectSprite:@"bridge" spriteName:@"bridge.png"];
            bridge.ccNode.position = plushy.ccNode.position;
            [bridge setLinearVelocity:[maze linearVelocity]];
            [self addChild:bridge.ccNode];
            pass = false;
            [plushy reset];
            
        }
        else {
            [[GB2Engine sharedInstance] deleteAllObjects];
            //[plushy reset];
            [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:plushy.bananaScore]];
        }
    }
    
    // TODO: add some animations here
    else if (plushy.pass) {
        pass = true;
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
            [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:plushy.bananaScore]];
        }
        else
        {
            // destroy 1 life, move maze back and reset plushy
            [plushy destroyLive];
            [maze setSensor:TRUE];
            [maze moveTo:b2Vec2FromCC([maze ccNode].position.x+250, [maze ccNode].position.y)];
            [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
            [plushy resetPlushyPosition];
            [maze setSensor:FALSE];
        }
    }
}

- (double) getRandomDouble
{
    return ((double)arc4random() / ARC4RANDOM_MAX);
}

-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
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
                Object *obj1 = [Object randomObject:-1];
                [obj1 setPhysicsPosition:b2Vec2FromCC(initalX, initialY)];
                [obj1 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj1 ccNode] z:100];
                Object *obj2 = [Object randomObject:-1];
                [obj2 setPhysicsPosition:b2Vec2FromCC(initalX+30, initialY+30)];
                [obj2 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj2 ccNode] z:100];
                Object *obj3 = [Object randomObject:-1];
                [obj3 setPhysicsPosition:b2Vec2FromCC(initalX+80, initialY+30)];
                [obj3 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj3 ccNode] z:100];
                Object *obj4 = [Object randomObject:-1];
                [obj4 setPhysicsPosition:b2Vec2FromCC(initalX+110, initialY)];
                [obj4 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj4 ccNode] z:100];
            }
            nextObject = [self getRandomNumberBetweenMin:5 andMax:10];
        }
        if (p == 1) {
            int initalX = [[CCDirector sharedDirector] winSize].width;
            int initialY = [plushy ccNode].position.y+80;
            if (initialY < 280) {
                Object *obj1 = [Object randomObject:-1];
                [obj1 setPhysicsPosition:b2Vec2FromCC(initalX, initialY)];
                [obj1 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj1 ccNode] z:100];
                Object *obj2 = [Object randomObject:-1];
                [obj2 setPhysicsPosition:b2Vec2FromCC(initalX+40, initialY)];
                [obj2 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj2 ccNode] z:100];
                Object *obj3 = [Object randomObject:-1];
                [obj3 setPhysicsPosition:b2Vec2FromCC(initalX+80, initialY)];
                [obj3 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj3 ccNode] z:100];
                Object *obj4 = [Object randomObject:-1];
                [obj4 setPhysicsPosition:b2Vec2FromCC(initalX+120, initialY)];
                [obj4 setLinearVelocity:b2Vec2(-5, 0)];
                [self addChild:[obj4 ccNode] z:100];
            }
            nextObject = [self getRandomNumberBetweenMin:5 andMax:10];
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


-(void) loadMaze
{
    [self loadMaze:level];
}

-(void) loadMaze:(int)ofLevel {
    if (ofLevel == 11) {
        ofLevel = 1;
    }
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
            [pauseLayer pauseLayerVisible:YES];
        }
        if ((showingTip == 4 || showingTip == 5 || showingTip == 6)
            && [MainMenuScene showTips]) {
            [pauseLayer resumeGame];
            [self removeChild:tutorial cleanup:YES];
            showingTip = -1;
        }
        // Otherwise its' for jumping and we prevent double jumping
        else if (!plushy.jumping) {
            if ((showingTip == 3)
                && [MainMenuScene showTips]) {
                [pauseLayer resumeGame];
                [self removeChild:tutorial cleanup:YES];
                showingTip = -1;
            }
            [plushy jump];
        }
    }
    else
    {
        if ((showingTip == 1 || showingTip == 2 || showingTip == 10 || showingTip == 11)
            && [MainMenuScene showTips]) {
            [pauseLayer resumeGame];
            [self removeChild:tutorial cleanup:YES];
            showingTip = -1;
        }
        //Check if the swipe is a left swipe and long enough
        if (firstTouch.x > lastTouch.x && swipeLength > 60) //left swipe (90)
        {
            angle = -90;
            CGPoint p1 = [plushy ccNode].position;
            //        p1.y = p1.y+10;
            p1.y = p1.y-80;
            [plushy setFalling:true];
            
            // Rotate the map without animation
            CGPoint oldp = [maze ccNode].position;
            CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(-90) of:oldp around:p1];
            [maze transform:b2Vec2FromCGPoint(newp) withAngle:-90];
            //            [self animateRotation:angle];
        }
        else if(firstTouch.x < lastTouch.x && swipeLength > 60) // right swipe (-90)
        {
            angle = 90;
            CGPoint p1 = [plushy ccNode].position;
            //        p1.y = p1.y-80;
            p1.y = p1.y+10;
            [plushy setFalling:true];
            // Rotate the map without animation
            CGPoint oldp = [maze ccNode].position;
            CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(90) of:oldp around:p1];
            [maze transform:b2Vec2FromCGPoint(newp) withAngle:90];
            //            [self animateRotation:angle];
        }
    }
}

-(void)setPlushyIsDead:(BOOL)d
{
    plushy.dead = d;
}

-(void)animateRotation:(int)angle
{
    if ((showingTip == 1 || showingTip == 2 || showingTip == 10 || showingTip == 11)
        && [MainMenuScene showTips]) {
        [pauseLayer resumeGame];
        [self removeChild:tutorial cleanup:YES];
        showingTip = -1;
    }
    //cameraDelay = 10;
    [plushy setFalling:true];
    
    
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

-(CGPoint)rotate:(float)theta of:(CGPoint)pos around:(CGPoint)origin
{
    float newx = cos(theta) * (pos.x-origin.x) - sin(theta) * (pos.y-origin.y) + origin.x;
    float newy = sin(theta) * (pos.x-origin.x) + cos(theta) * (pos.y-origin.y) + origin.y;
    
    return CGPointMake(newx,newy);
}

///////////////////////// loading game objects
-(void)loadBombFile
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"GameObjects" ofType:@"plist" inDirectory:@""];
	
	NSAssert(nil!=path, @"Invalid GameObjects file.");
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	[self processLevelFileFromDictionary:dictionary];
}

-(void) processLevelFileFromDictionary:(NSDictionary*)dictionary
{
    if (nil==dictionary) {
        return;
    }
    
    NSDictionary* gameObjs = [dictionary objectForKey:@"cactus bomb 1"];
    NSNumber* pos_x = [gameObjs objectForKey:@"x"];
    NSNumber* pos_y = [gameObjs objectForKey:@"y"];
    CGPoint position = ccp([pos_x intValue],[pos_y intValue]);
    
    Object *cactus = [Object randomObject:CACTUS_BOMB];
    [self addChild:[cactus ccNode] z:30];
    [cactus setPhysicsPosition:b2Vec2FromCC(position.x, position.y)];
    //[cactus getBody]->SetGravityScale(0);
    
    //Create a distance joint between the body and the maze
//    b2DistanceJointDef distanceJointDef;
//    distanceJointDef.Initialize([maze getBody], [cactus getBody], [maze getBody]->GetWorldCenter(), [cactus getBody]->GetWorldCenter());
//    
//    [GB2Engine sharedInstance].world->CreateJoint(&distanceJointDef);
}

@end
