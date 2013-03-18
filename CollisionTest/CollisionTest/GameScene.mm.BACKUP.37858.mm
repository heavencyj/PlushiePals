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
// Interface for difference scenes
#import "GameOverScene.h"
#import "MainMenuScene.h"
#import "Hud.h"
#import "BackgroundScene.h"
//#import "PauseLayer.h"
// Interface for different objects
#import "Plushy.h"
#import "Object.h"

// Macros for constants
#define PTM_RATIO 32
#define WALKING_FRAMES 3
#define MAZE_LOW 30
#define ARC4RANDOM_MAX 0x100000000
#define ICON_DIST 60

#pragma mark - GameScene

// HelloWorldLayer implementation
@implementation GameScene

// Level related variables
int level;
bool pass;
<<<<<<< HEAD
float angle;

@synthesize maze;
@synthesize hud;
=======
int score;
float plushySpeed;
float mazeSpeed;
// Delay variables to delay certain actions
int speedDelay;
int scoreDelay;
int cameraDelay;
float angle;
// Pause layer variables
// TODO create a new class
CCLayer *pauseLayer;
CGRect pauseButtonRect;
CCSprite *pauseButton;
// Variables for dropping objects on the screen
ccTime nextObject;
ccTime objDelay;
Object *obj;
CCSprite *tutorial;
int showingTip;
CCSprite *dummyMaze;
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c

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
<<<<<<< HEAD
        // Adding object layer
        plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys_default.png" capacity:150];
        [self addChild:plushyLayer z:200];
        
        // Add monkey
        plushy = [[[Plushy alloc] initWithGameLayer:self] autorelease];
        plushySpeed = 3.0;
        [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
        [plushyLayer addChild:[plushy ccNode] z:10];
        
        // add maze
        [self loadMaze];
        speedDelay = 1000;
        
        // Initializing variables
        nextObject= 5.0f;  // first object to appear after 3s
        objDelay = 2.0f; // next object to appear after 1s
        
        // Set camera delay variable
        cameraDelay = -1;
        
//        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
//        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        swipeLeftGestureRecognizer.delegate = self;
//        [self addGestureRecognizer:swipeLeftGestureRecognizer];
//        [swipeLeftGestureRecognizer release];
//        
//        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
//        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//        swipeRightGestureRecognizer.delegate = self;
//        [self addGestureRecognizer:swipeRightGestureRecognizer];
//        [swipeRightGestureRecognizer release];
        
//        [self addTapRecognizer];
        
        self.isTouchEnabled = YES;
        
        // following the movements of the plushy
//        CGRect rect = CGRectMake(-525, -559, 4000, 4548);
        //[self runAction:[CCFollow actionWithTarget:[plushy ccNode] worldBoundary:rect]];
        [self runAction:[CCFollow actionWithTarget:[plushy ccNode]]];
        
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
    
    // Add objects to path
    int objectPattern = [self getRandomNumberBetweenMin:0 andMax:1];
    [self nextObject:dt pattern:objectPattern];
    
    //Animate rotation
//    if (ABS(dummyMaze.rotation - maze.ccNode.rotation) == ABS(angle) ) {
//        CGPoint p1 = [plushy ccNode].position;
//        p1.y = (angle > 0) ? p1.y+10:p1.y-80;
//        CGPoint oldp = [maze ccNode].position;
//        CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
//        [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
//        [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
//        maze.ccNode.visible = YES;
//    }
=======
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Adding solid background color
    background = [CCLayerColor layerWithColor:ccc4(253,250,180,255) width:winSize.width height:winSize.height];
    background.anchorPoint = ccp(0,0);
    background.position = ccp(0,0);
    [self addChild:background];
    
    // Loading physics shapes
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"plushyshapes.plist"];
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"canyon_levels.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"monkeys_default.plist"];
    
    // 1) Create the CCParallaxNode
    backgroundNode = [CCParallaxNode node];
    [self addChild:backgroundNode z:10];
    
    // Create the continuous scrolling background
    cloud1 = [CCSprite spriteWithFile:@"Canyon cloud 1.png"];
    cloud2 = [CCSprite spriteWithFile:@"Canyon cloud 2.png"];
    canyons = [CCSprite spriteWithFile:@"Canyons looped.png"];
    canyons.tag = 1;
    canyons2 = [CCSprite spriteWithFile:@"Canyons looped.png"];
    canyons2.tag = 2;
    
    // Speeds ratio for the objects in the parallax layer
    CGPoint cloudSpeed = ccp(0.5, 0);
    CGPoint bgSpeed = ccp(1.0, 1.0);
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c
    
    // Add children to CCParallaxNode
    [backgroundNode addChild:canyons z:1 parallaxRatio:bgSpeed positionOffset:ccp(canyons.contentSize.width/2, canyons.contentSize.height/2)];
    [backgroundNode addChild:canyons2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(canyons2.contentSize.width+380, canyons2.contentSize.height/2)];
    [backgroundNode addChild:cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
    [backgroundNode addChild:cloud2 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(cloud1.contentSize.width+100,winSize.height/1.2)];
    
    //[self addChild:[[GB2DebugDrawLayer alloc] init] z:800];
    
<<<<<<< HEAD
    // Update score with a little bit delay for performance concern
    if (scoreDelay ==0) {
        //score ++ ;
//        [scoreLabel setString:[NSString stringWithFormat:@"%d",plushy.bananaScore]];
        [hud updateBananaScore:plushy.bananaScore];
        scoreDelay = 10;
    }
    
//    float swipeLength = ccpDistance([maze ccNode].position, [plushy ccNode].position);
    //NSLog(@"Maze to plushy distance is: %f", swipeLength);
//    NSLog(@"Maze pos: (%f, %f)", [maze ccNode].position.x, [maze ccNode].position.y);
    
    // Speed up after a while
    //  if (speedDelay == 0) {
    //    plushySpeed += 1;
    //    mazeSpeed -= 3;
    //    [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
    //    [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
    //    speedDelay = 1000;
    //  }
    //
    if (pass) {
        [[GB2Engine sharedInstance] deleteAllObjects];
        [plushy reset];
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:plushy.bananaScore]];
    }
    // Show the star when the level is passed
    // TODO: add some animations here
    else if ([plushy passLevel]) {
        pass = true;
        // drop something on the screen to show that you passed the level
        //NSLog(@"passsss!");
        CCSprite* star = [CCSprite spriteWithFile:@"Star.png"];
        star.position = ccp(winSize.width*0.9, winSize.height*0.8);
//        [background addChild:star z:50];
        [self addChild:star z:50];
    }
    
    // Plushy dies if it falls out of the screen or hit the wall
//    else if ([plushy ccNode].position.y < -50 || [plushy isDead])
    else if ([plushy isDead])
    {
        if (!plushy.lives) {
            [[GB2Engine sharedInstance] deleteAllObjects];
            [plushy reset];
            
            // if pass, show one screen. otherwise show the other, modify gameover scene
            [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:plushy.bananaScore]];
        }
        else
        {
            // TOOD: Better handle with collisions
            // destroy 1 life, move maze back and reset plushy
            [plushy destroyLive];
            [maze setSensor:TRUE];
            [maze moveTo:b2Vec2FromCC([maze ccNode].position.x+250, [maze ccNode].position.y)];
            [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
            [plushy resetPlushyPosition];
            [maze setSensor:FALSE];
        }
=======
    // Pause button
    pauseButton = [CCSprite spriteWithFile:@"Pause icon.png"];
    pauseButton.position = ccp(440,290);
    pauseButtonRect = CGRectMake((pauseButton.position.x-(pauseButton.contentSize.width)/2), (pauseButton.position.y-(pauseButton.contentSize.height)/2), (pauseButton.contentSize.width), (pauseButton.contentSize.height));
    [self addChild:pauseButton z:50];
    
    
    // Adding object layer
    plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys_default.png" capacity:150];
    [self addChild:plushyLayer z:200];
    
    
    // Add monkey
    plushy = [[[Plushy alloc] initWithGameLayer:self] autorelease];
    [plushy setPhysicsPosition:b2Vec2FromCC(300,200)];
    plushySpeed = 3.0;
    [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
    [plushyLayer addChild:[plushy ccNode] z:10];
    
    // add maze
    [self loadMaze];
    speedDelay = 1000;
    
    // add score
    CCSprite *bananaPoints = [CCSprite spriteWithFile:@"banana single.png"];
    CCSprite *mult = [CCLabelTTF labelWithString:@"X"
                                        fontName:@"GROBOLD"
                                        fontSize:30];
    bananaPoints.position = ccp(20, 290);
    mult.position = ccp(55, 290);
    mult.color=ccc3(245, 148, 36);
    [self addChild:bananaPoints z:50];
    [self addChild:mult z:50];
    
    scoreDelay = 10;
    score = 0;
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",plushy.bananaScore]
                                    fontName:@"GROBOLD"
                                    fontSize:40];
    scoreLabel.color = ccc3(245, 148, 36);
    scoreLabel.position = ccp(95,290);
    [self addChild:scoreLabel z:50];
    
    // add pause layer
    [self addPauseLayer];
    
    // Initializing variables
    nextObject= 5.0f;  // first object to appear after 3s
    objDelay = 2.0f; // next object to appear after 1s
    
    // Set camera delay variable
    cameraDelay = -1;
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGestureRecognizer.delegate = self;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [swipeLeftGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGestureRecognizer.delegate = self;
    [self addGestureRecognizer:swipeRightGestureRecognizer];
    [swipeRightGestureRecognizer release];
    
    [self addTapRecognizer];
    
    self.isTouchEnabled = YES;
    
    //[[CDAudioManager sharedManager] setMode:kAMM_MediaPlayback];
    // Adding sound and music
    //TODO: add volume control
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Luscious Swirl 60.mp3" loop:true];
    //[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5];
    [self scheduleUpdate];
  }
  return self;
}

#pragma mark GameKit delegate
// Add new update method
- (void)update:(ccTime)dt {
  
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  
  // Incrementing the position of the background parallaxnode
  CGPoint backgroundScrollVel = ccp(-100, 0);
  backgroundNode.position = ccpAdd(backgroundNode.position, ccpMult(backgroundScrollVel, dt));
  
  // Add continuous scroll for clouds
  NSArray *clouds = [NSArray arrayWithObjects:cloud1, cloud2, nil];
  for (CCSprite *cloud in clouds) {
    if ([backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
      [backgroundNode incrementOffset:ccp(2*cloud.contentSize.width-[backgroundNode convertToWorldSpace:cloud.position].x,0) forChild:cloud];
    }
  }
  
  // Add continuous scroll for the canyon
  NSArray *backgrounds = [NSArray arrayWithObjects: canyons, canyons2, nil];
  for (CCSprite *background in backgrounds) {
    if ([backgroundNode convertToWorldSpace:background.position].x < -500) {
      [backgroundNode incrementOffset:ccp(100+background.contentSize.width-[backgroundNode convertToWorldSpace:background.position].x,0) forChild:background];
    }
  }
  
  // Add objects to path
  //TODO: dropping randomly added objects to the road.
  int objectPattern = [self getRandomNumberBetweenMin:0 andMax:1];
  [self nextObject:dt pattern:objectPattern];
  
  //Animate rotation
  if (ABS(dummyMaze.rotation - maze.ccNode.rotation) == ABS(angle) ) {
    CGPoint p1 = [plushy ccNode].position;
    p1.y = (angle > 0) ? p1.y+10:p1.y-80;
    CGPoint oldp = [maze ccNode].position;
    CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
    [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
    [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
    maze.ccNode.visible = YES;
  }
  
  //Delay variables decrementing
  if (speedDelay > 0) {
    speedDelay --;
  }
  if (scoreDelay > 0) {
    scoreDelay--;
  }
  if (cameraDelay > 0) {
    cameraDelay --;
  }
  
  if ([plushy isFalling] && cameraDelay <=0) {
    cameraDelay = 10;
  }
  
  // Moving camera when plushy is out of the center
  //if ([plushy isRunning]) {
  if ([plushy isRunning] && cameraDelay ==0 ) {
    float dy = - [plushy ccNode].position.y + 150;
    [plushy setPhysicsPosition:b2Vec2FromCC(200, 150)];
    CGPoint mp = [maze ccNode].position;
    mp.y = mp.y+dy;
    [maze setPhysicsPosition:b2Vec2FromCGPoint(mp)];
    cameraDelay = -1;
  }

  
  // Update score with a little bit delay for performance concern
  if (scoreDelay ==0) {
    //score ++ ;
    [scoreLabel setString:[NSString stringWithFormat:@"%d",plushy.bananaScore]];
    scoreDelay = 10;
  }
  
  // Speed up after a while
//  if (speedDelay == 0) {
//    plushySpeed += 1;
//    mazeSpeed -= 3;
//    [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
//    [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
//    speedDelay = 1000;
//  }
//  
  if ([plushy showTip] != -1 && [MainMenuScene showTips]) {
    showingTip = [plushy showTip];
    switch (showingTip) {
      case 0: case 2:
        [self pauseGame];
        tutorial = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Tutorial %d.png", showingTip]];
        tutorial.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:tutorial z:500];
        [plushy setTip];
        break;
        
      default:
        break;
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c
    }
    // show the tool tips and imgs
    // when swife, resume
  }
  
  if (pass) {
    [[GB2Engine sharedInstance] deleteAllObjects];
    [plushy reset];
    [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:plushy.bananaScore]];
  }
  // Show the star when the level is passed
  // TODO: add some animations here
  else if ([plushy passLevel]) {
    pass = true;
    // drop something on the screen to show that u passed the level
    //NSLog(@"passsss!");
    CCSprite* star = [CCSprite spriteWithFile:@"Star.png"];
    star.position = ccp(winSize.width*0.9, winSize.height*0.8);
    [background addChild:star z:50];
    
  }
  else if ([plushy isColliding]) {
    [maze setLinearVelocity:b2Vec2(0, 0)];
  }
  // Plushy dies if it falls out of the screen or hit the wall
  else if ([plushy ccNode].position.y < -50 || [plushy isDead])
  {
    [[GB2Engine sharedInstance] deleteAllObjects];
    [plushy reset];
    // if pass, show one screen. otherwise show the other, modify gameover scene
    [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level withScore:plushy.bananaScore]];
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
        if (p == 0) {
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
//        if (p == 2) {
//            // drop a banana peel for speed up
//            Object *obj = [Object randomObject:BANANA_BOMB];
////            [obj changeType:b2_dynamicBody];
////            [obj setPhysicsPosition:b2Vec2FromCC([plushy ccNode].position.x+30, [[CCDirector sharedDirector] winSize].width)];
//            [obj setPhysicsPosition:b2Vec2FromCC([plushy ccNode].position.x+100, [plushy ccNode].position.y-15)];
//            [obj setLinearVelocity:b2Vec2(-5, 0)];
//            [self addChild:[obj ccNode] z:100];
//            nextObject = [self getRandomNumberBetweenMin:8 andMax:15];
//        }
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
}
- (void)setNodeVisible:(CCNode *)node {
<<<<<<< HEAD
    node.visible = YES;
=======
  node.visible = YES;
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    //	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    //	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    //	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    //	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) loadMaze
{
<<<<<<< HEAD
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[@"canyon level " stringByAppendingFormat:@"%d.plist",level]];
    NSString *shape = [@"canyon level " stringByAppendingFormat:@"%d", level];
    maze = [Maze mazeSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
    [maze setPhysicsPosition:b2Vec2FromCC(200,120)];
    mazeSpeed = -5;
    [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
    dummyMaze = [CCSprite spriteWithFile:[@"canyon " stringByAppendingFormat:@"%d.png", level]]; //TODO:
    dummyMaze.visible = NO;
    [self addChild:dummyMaze z:40];
    [self addChild:[maze ccNode] z:40];
=======
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[@"canyon level " stringByAppendingFormat:@"%d.plist",level]];
  NSString *shape = [@"canyon level " stringByAppendingFormat:@"%d", level];
  maze = [Maze mazeSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
  [maze setPhysicsPosition:b2Vec2FromCC(200,120)];
  mazeSpeed = -5;
  [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
  dummyMaze = [CCSprite spriteWithFile:[@"canyon " stringByAppendingFormat:@"%d.png", level]];
  dummyMaze.visible = NO;
  [self addChild:dummyMaze z:40];
  [self addChild:[maze ccNode] z:40];
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c
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
    if (swipeLength < 10)
    {
        // If pause button is tapped
        if (CGRectContainsPoint(hud.pauseButtonRect, location)){
            [self pauseGame];
            [hud pauseLayerVisible:YES];
        }
        // Otherwise its' for jumping and we prevent double jumping
        else if (![plushy isJumping]) {
            [plushy jump];
        }
    }
    else
    {
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

-(void)animateRotation:(int)angle
{
<<<<<<< HEAD
    //  // To to animate
    CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
    CCLOG(@"dummymaze is at %f and %f", dummyMaze.position.x, dummyMaze.position.y);
    
//    angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    CGPoint p1 = [plushy ccNode].position;
    CGPoint p2 = [maze ccNode].position;
    float dy = (angle > 0) ? 15:-15;
    CGPoint tempAnchorPoint;
    int a = (int)dummyMaze.rotation/90 % 2;
    switch (ABS(a)) {
        case 0:
            tempAnchorPoint = ccp(ABS(p1.x-p2.x)/dummyMaze.contentSize.width, 1-ABS(p1.y-p2.y+dy)/dummyMaze.contentSize.height);
            break;
            
        case 1:
            tempAnchorPoint = ccp(ABS(p1.y-p2.y+dy)/dummyMaze.contentSize.width, 1-ABS(p1.x-p2.x)/dummyMaze.contentSize.height);
            break;
            
        default:
            break;
    }
    dummyMaze.anchorPoint = tempAnchorPoint;
    dummyMaze.position = ccp(160, 120);
    CCLOG(@"dummymaze anchor is at %f and %f",dummyMaze.anchorPoint.x, dummyMaze.anchorPoint.y);
    CCLOG(@"dummymaze pos is at %f and %f",dummyMaze.position.x, dummyMaze.position.y);
    [maze ccNode].visible = NO;
    [dummyMaze runAction:[CCSequence actions:
                          [CCCallFuncN actionWithTarget:self selector:@selector(setNodeVisible:)],
                          [CCRotateBy actionWithDuration:0.5 angle:angle],
                          [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
    [maze setLinearVelocity:b2Vec2(0,0)];
    
    // Rotate the map without animation
    //  angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    //  CGPoint p1 = [plushy ccNode].position;
    //  p1.y = (angle > 0) ? p1.y+10:p1.y-80;
    //  CGPoint oldp = [maze ccNode].position;
    //  CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
    //  [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
=======
  if ((showingTip == 0 || showingTip == 2) && [MainMenuScene showTips]) {
    [self resumeGame];
    [self removeChild:tutorial cleanup:YES];
    showingTip = -1;
  }
  //cameraDelay = 10;
  [plushy setFalling:true];
  
  
//  // To to animate
  CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
  CCLOG(@"dummymaze is at %f and %f", dummyMaze.position.x, dummyMaze.position.y);
  
  angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;  
  CGPoint p1 = [plushy ccNode].position;
  CGPoint p2 = [maze ccNode].position;
  float dy = (angle > 0) ? 15:-15;
  CGPoint tempAnchorPoint;
  int a = (int)dummyMaze.rotation/90 % 2;
  switch (ABS(a)) {
    case 0:
      tempAnchorPoint = ccp(ABS(p1.x-p2.x)/dummyMaze.contentSize.width, 1-ABS(p1.y-p2.y+dy)/dummyMaze.contentSize.height);
      break;
      
    case 1:
      tempAnchorPoint = ccp(ABS(p1.y-p2.y+dy)/dummyMaze.contentSize.width, 1-ABS(p1.x-p2.x)/dummyMaze.contentSize.height);
      break;
      
    default:
      break;
  }
  dummyMaze.anchorPoint = tempAnchorPoint;
  dummyMaze.position = ccp(160, 120);
  CCLOG(@"dummymaze anchor is at %f and %f",dummyMaze.anchorPoint.x, dummyMaze.anchorPoint.y);
  CCLOG(@"dummymaze pos is at %f and %f",dummyMaze.position.x, dummyMaze.position.y);
  [maze ccNode].visible = NO;
  [dummyMaze runAction:[CCSequence actions:
                        [CCCallFuncN actionWithTarget:self selector:@selector(setNodeVisible:)],
                        [CCRotateBy actionWithDuration:0.5 angle:angle],
                        [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
  [maze setLinearVelocity:b2Vec2(0,0)];
  
   // Rotate the map without animation
//  angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;  
//  CGPoint p1 = [plushy ccNode].position;
//  p1.y = (angle > 0) ? p1.y+10:p1.y-80;
//  CGPoint oldp = [maze ccNode].position;
//  CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
//  [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
  
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c
}

//- (void)handleTapGestureRecognizer:(UITapGestureRecognizer*)aGestureRecognizer
//{
//    // Calculate where is tapped
//    CGPoint location=[aGestureRecognizer locationInView:[aGestureRecognizer view]];
//    location.y = [[CCDirector sharedDirector] winSize].height - location.y;
//    // If pause button is tapped
//    if (CGRectContainsPoint(hud.pauseButtonRect, location)){
//        [self pauseGame];
//        [hud pauseLayerVisible:YES];
//        [self removeGestureRecognizer:aGestureRecognizer];
//    }
//    // Otherwise its' for jumping and we prevent double jumping
//    else if (![plushy isJumping]) {
//        [plushy jump];
//    }
//}

//- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
//{
//    //TODO: testing only. 
////    for (int i=0; i<10; i++) {
////        id action=[CCRotateBy actionWithDuration:1.5 angle:10];
////        [maze runAction:action];
////    }
//    float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
//    //newAngle = [maze ccNode].rotation + angle;
//    CGPoint p1 = [plushy ccNode].position;
//    p1.y = (angle > 0) ? p1.y+10:p1.y-80;
//    //cameraDelay = 10;
//    [plushy setFalling:true];
//    
//    // To to animate
//    //  CGPoint p2 = [maze ccNode].position;
//    //  p2.x = p1.x - p2.x;
//    //  float dy = (angle > 0) ? 10:-10;
//    //  p2.y += dy;
//    //  //CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
//    //  [[maze ccNode] setAnchorPoint:ccp(p2.x/[maze ccNode].contentSize.width, dy/[maze ccNode].contentSize.height + 1)];
//    //  //[[maze ccNode] setPosition:ccp(p1.x, p2.y)];
//    //  [maze setPhysicsPosition:b2Vec2FromCC(200,140)];
//    //  //[[maze ccNode] setAnchorPoint:ccp(1,1)];
//    //  CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
//    //  CCLOG(@"maze anchor is at %f and %f", [maze ccNode].anchorPoint.x, [maze ccNode].anchorPoint.y);
//    //  [maze setAngularVelocity:(angle > 0) ? -1:1];
//    //  [plushy setBodyType:b2_kinematicBody];
//    
//    // Rotate the map without animation
//    CGPoint oldp = [maze ccNode].position;
//    CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p1];
//    [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];
//}

-(CGPoint)rotate:(float)theta of:(CGPoint)pos around:(CGPoint)origin
{
    float newx = cos(theta) * (pos.x-origin.x) - sin(theta) * (pos.y-origin.y) + origin.x;
    float newy = sin(theta) * (pos.x-origin.x) + cos(theta) * (pos.y-origin.y) + origin.y;
    
    return CGPointMake(newx,newy);
    
}

-(void)pauseGame
{
    [self pauseSchedulerAndActions];
    [[CCDirector sharedDirector] pause];
//    pauseButton.visible = NO;
    hud.pauseButton.visible = NO;
}

<<<<<<< HEAD
//-(void)addTapRecognizer
//{
//    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
//    tapGestureRecognizer.numberOfTapsRequired = 1;
//    tapGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:tapGestureRecognizer];
//    [tapGestureRecognizer release];
//}
=======
-(void)resumeGame
{
  if (!((showingTip == 0 || showingTip == 2) && [MainMenuScene showTips])) {
    [self addTapRecognizer];
  }
  pauseLayer.visible = NO;
  pauseButton.visible = YES;
  [self resumeSchedulerAndActions];
  [[CCDirector sharedDirector] resume];
}

-(void)restartGame
{
    [self addTapRecognizer];
    pauseLayer.visible = NO;
    pauseButton.visible = YES;
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    [[CCDirector sharedDirector] resume];
}

-(void)addTapRecognizer
{
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

- (void)goHome {
    
    [[CCDirector sharedDirector] resume];
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}
>>>>>>> cb0c89ae43002b988405ca9e62c077442f193f7c

@end
