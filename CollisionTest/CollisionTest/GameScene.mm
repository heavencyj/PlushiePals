//
//  HelloWorldLayer.m
//  Cocos2d Test
//
//  Created by Lan Li & Heaven Chen on 1/13/13.
//  Copyright 2013. All rights reserved.
//


// Interfaces for box2d and audio engine
#import "GameScene.h"
#import "CCNode+SFGestureRecognizers.h"
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
//#import "PauseLayer.h"
// Interface for different objects
#import "Maze.h"
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

// Background variables
CCSprite *background;
CCSprite *cloud1;
CCSprite *cloud2;
CCSprite *canyons;
CCSprite *canyons2;
CCParallaxNode *backgroundNode;
CCLabelTTF* scoreLabel;
// Plushy variables
Plushy *plushy;
CCSpriteBatchNode *plushyLayer;
// Maze variables
Maze *maze;
// Level related variables
int level;
bool pass;
int score;
float plushySpeed;
float mazeSpeed;
// Delay variables to delay certain actions
int speedDelay;
int scoreDelay;
int cameraDelay;
// Pause layer variables
// TODO create a new class
CCLayer *pauseLayer;
CGRect pauseButtonRect;
CCSprite *pauseButton;
// Variables for dropping objects on the screen
ccTime nextObject;
ccTime objDelay;
Object *obj;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    pass = false;
	
	// return the scene
	return scene;
}

+(CCScene *) scene:(int)withLevel
{
    level = withLevel;
    //NSLog(@"level is %d", level);
    pass = false;
    return [self scene];
    
}

// On "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	if( (self=[super init]) ) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Adding solid background color
        background = [CCLayerColor layerWithColor:ccc4(253,250,180,255) width:winSize.width height:winSize.height];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        [self addChild:background];
        
        // Loading physics shapes
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"plushyshapes.plist"];
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
        
        // Add children to CCParallaxNode
        [backgroundNode addChild:canyons z:1 parallaxRatio:bgSpeed positionOffset:ccp(canyons.contentSize.width/2, canyons.contentSize.height/2)];
        [backgroundNode addChild:canyons2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(canyons2.contentSize.width+380, canyons2.contentSize.height/2)];
        [backgroundNode addChild:cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
        [backgroundNode addChild:cloud2 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(cloud1.contentSize.width+100,winSize.height/1.2)];
        
        //[self addChild:[[GB2DebugDrawLayer alloc] init] z:30];
        
        // Pause button
        pauseButton = [CCSprite spriteWithFile:@"Pause icon.png"];
        pauseButton.position = ccp(50,250);
        pauseButtonRect = CGRectMake((pauseButton.position.x-(pauseButton.contentSize.width)/2), (pauseButton.position.y-(pauseButton.contentSize.height)/2), (pauseButton.contentSize.width), (pauseButton.contentSize.height));
        [self addChild:pauseButton z:50];
        
        
        // Adding object layer
        plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys_default.png" capacity:150];
        [self addChild:plushyLayer z:200];
        
        
        // Add monkey
        plushy = [[[Plushy alloc] initWithGameLayer:self] autorelease];
        [plushy setPhysicsPosition:b2Vec2FromCC(300,200)];
        plushySpeed = 2.0;
        [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
        [plushyLayer addChild:[plushy ccNode] z:10];
        
        // add maze
        [self loadMaze];
        speedDelay = 1000;
        
        // add score
        scoreDelay = 10;
        score = 0;
        scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score]
                                        fontName:@"GROBOLD"
                                        fontSize:60];
        scoreLabel.color = ccc3(245, 148, 36);
        scoreLabel.position = ccp(100,250);
        [self addChild:scoreLabel z:50];
        
        // add pause layer
        [self addPauseLayer];
        
        // Initializing variables
        nextObject= 3.0f;  // first object to appear after 3s
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
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Luscious Swirl 60.mp3" loop:true];
        
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
    //[self nextObject:dt];
    
    //Animate rotation
    //  if (ABS([maze ccNode].rotation) > ABS(angle) ) {
    //    [maze setAngularVelocity:0];
    //    [plushy setBodyType:b2_dynamicBody];
    //  }
    
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
    
    // Moving camera when plushy is out of the center
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
        score ++ ;
        [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
        scoreDelay = 10;
    }
    
    // Speed up after a while
    if (speedDelay == 0) {
        plushySpeed += 1;
        mazeSpeed -= 3;
        [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
        [maze setLinearVelocity:b2Vec2(mazeSpeed, 0)];
        speedDelay = 1000;
    }
    
    // Show the star when the level is passed
    // TODO: add some animations here
    if ([plushy passLevel] && pass == false) {
        pass = true;
        // drop something on the screen to show that u passed the level
        //NSLog(@"passsss!");
        CCSprite* star = [CCSprite spriteWithFile:@"Star.png"];
        star.position = ccp(winSize.width*0.9, winSize.height*0.8);
        [background addChild:star z:50];
    }
    
    // Plushy dies if it falls out of the screen or hit the wall
    if ([plushy ccNode].position.y < -50 || [plushy isDead])
    {
        [[GB2Engine sharedInstance] deleteAllObjects];
        [plushy reset];
        // if pass, show one screen. otherwise show the other, modify gameover scene
        
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass withLevel:level]];
    }
}

-(void)nextObject:(ccTime)dt
{
    nextObject -= dt;
    if(nextObject <=0)
    {
        obj = [Object randomObject];
        [obj setPhysicsPosition:b2Vec2FromCC(400, 200)];
        [plushyLayer addChild:[obj ccNode]];
        nextObject = objDelay;
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
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

// Add new method
- (void)setInvisible:(CCNode *)node {
    node.visible = NO;
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[@"map" stringByAppendingFormat:@"%d.plist",level]];
    NSString *shape = [@"map level " stringByAppendingFormat:@"%d", level];
    maze = [Maze mazeSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
    [maze setPhysicsPosition:b2Vec2FromCC(200,120)];
    mazeSpeed = -4;
    [maze setLinearVelocity:b2Vec2(mazeSpeed,0)];
    [self addChild:[maze ccNode] z:100];
}


- (void)handleTapGestureRecognizer:(UITapGestureRecognizer*)aGestureRecognizer
{
    // Calculate where is tapped
    CGPoint locationt=[aGestureRecognizer locationInView:[aGestureRecognizer view]];
    locationt.y = [[CCDirector sharedDirector] winSize].height - locationt.y;
    // If pause button is tapped
    if (CGRectContainsPoint(pauseButtonRect, locationt)){
        [self pauseGame];
        pauseLayer.visible = YES;
        [self removeGestureRecognizer:aGestureRecognizer];
    }
    // Otherwise its' for jumping and we prevent double jumping
    else if (![plushy isJumping]) {
        [plushy jump];
    }
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
    float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    //newAngle = [maze ccNode].rotation + angle;
    CGPoint p1 = [plushy ccNode].position;
    p1.y = (angle > 0) ? p1.y+10:p1.y-80;
    cameraDelay = 60;
    [plushy setFalling:true];
    
    // To to animate
    //  CGPoint p2 = [maze ccNode].position;
    //  p2.x = p1.x - p2.x;
    //  float dy = (angle > 0) ? 10:-10;
    //  p2.y += dy;
    //  //CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
    //  [[maze ccNode] setAnchorPoint:ccp(p2.x/[maze ccNode].contentSize.width, dy/[maze ccNode].contentSize.height + 1)];
    //  //[[maze ccNode] setPosition:ccp(p1.x, p2.y)];
    //  [maze setPhysicsPosition:b2Vec2FromCC(200,140)];
    //  //[[maze ccNode] setAnchorPoint:ccp(1,1)];
    //  CCLOG(@"maze is at %f and %f", [maze ccNode].position.x, [maze ccNode].position.y);
    //  CCLOG(@"maze anchor is at %f and %f", [maze ccNode].anchorPoint.x, [maze ccNode].anchorPoint.y);
    //  [maze setAngularVelocity:(angle > 0) ? -1:1];
    //  [plushy setBodyType:b2_kinematicBody];
    
    // Rotate the map without animation
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

-(void)pauseGame
{
    [self pauseSchedulerAndActions];
    [[CCDirector sharedDirector] pause];
    pauseButton.visible = NO;
    
}

-(void)addPauseLayer
{

  CGSize winSize = [[CCDirector sharedDirector] winSize];
  pauseLayer = [[[CCLayer alloc] init] autorelease];
  [self addChild:pauseLayer z:1000];
  
  CCLayer *colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 210) width:400 height:200];
  colorLayer.position = ccp(winSize.width/2-colorLayer.contentSize.width/2,
                            winSize.height/2-colorLayer.contentSize.height/2);
  
  
  //  CCSprite *resume = [CCSprite spriteWithFile:@"Replay icon.png"];
  //  CCSprite* resumeSel = [CCSprite spriteWithFile:@"Replay icon.png"];
  // Three options: restart, resume, home
  CCMenuItemImage *resume = [CCMenuItemImage
                                   itemWithNormalImage:@"Play icon.png"
                                   selectedImage:nil
                                   target:self
                                   selector:@selector(resumeGame)];
  resume.position = ccp(-winSize.width/5,0);
  
  CCMenuItemImage *restart = [CCMenuItemImage
                                   itemWithNormalImage:@"Return icon.png"
                                   selectedImage:nil
                                   target:self
                                   selector:@selector(resumeGame)];
  restart.position = ccp(0,0);
  
  CCMenuItemImage *home = [CCMenuItemImage
                                   itemWithNormalImage:@"Home icon.png"
                                   selectedImage:nil
                                   target:self
                                   selector:@selector(goHome)];
  home.position = ccp(winSize.width/5,0);
  
  
  CCMenu *menu =  [CCMenu menuWithItems: resume, restart, home, nil];
  [pauseLayer addChild:colorLayer];
  [pauseLayer addChild:menu];  
  pauseLayer.visible = NO;

}

-(void)resumeGame
{
    [self addTapRecognizer];
    pauseLayer.visible = NO;
    pauseButton.visible = YES;
    [self resumeSchedulerAndActions];
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
  
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
  
}

@end
