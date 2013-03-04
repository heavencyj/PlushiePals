//
//  HelloWorldLayer.m
//  Cocos2d Test
//
//  Created by Lan Li & Heaven Chen on 1/13/13.
//  Copyright 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCNode+SFGestureRecognizers.h"
#import "GB2Sprite.h"
#import "Monkey.h"
#import "Floor.h"
#import "Object.h"
#import "GB2DebugDrawLayer.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"

#define PTM_RATIO 32
#define WALKING_FRAMES 3
#define MAZE_LOW 30
#define ARC4RANDOM_MAX 0x100000000

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
CCSpriteBatchNode *plushyLayer;
Monkey *plushy;
Floor *maze;
int level;
bool pass;
int countDown;
float pv;
float mv;
CCLayer *pauseLayer;
//float newAngle;
CGRect pauseButtonRect;
CGRect resumeButtonRect;
CCSprite *pauseButton;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
    _background = [CCSprite spriteWithFile: @"Canyon background.png"];
    _background.anchorPoint = ccp(0,0);
    //_background.position = ccp(winSize.width/2, winSize.height/2);
    _background.position = ccp(0,0);
    [self addChild:_background];
    
    // Loading physics shapes
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"plushyshapes.plist"];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"monkeys_default.plist"];
    
    // 1) Create the CCParallaxNode
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode z:10];
    
    // Create the continuous scrolling background
    _cloud1 = [CCSprite spriteWithFile:@"Canyon cloud 1.png"];
    _cloud2 = [CCSprite spriteWithFile:@"Canyon cloud 2.png"];
    _canyons = [CCSprite spriteWithFile:@"Canyons looped.png"];
    _canyons.tag = 1;
    _canyons2 = [CCSprite spriteWithFile:@"Canyons looped.png"];
    _canyons2.tag = 2;
    
    // Speeds ratio for the objects in the parallax layer
    CGPoint cloudSpeed = ccp(0.5, 0);
    CGPoint bgSpeed = ccp(1.0, 1.0);
    
    // Add children to CCParallaxNode
    [_backgroundNode addChild:_canyons z:1 parallaxRatio:bgSpeed positionOffset:ccp(_canyons.contentSize.width/2, _canyons.contentSize.height/2)];
    [_backgroundNode addChild:_canyons2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_canyons2.contentSize.width+380, _canyons2.contentSize.height/2)];
    [_backgroundNode addChild:_cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
    [_backgroundNode addChild:_cloud2 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(_cloud1.contentSize.width+200,winSize.height/1.2)];

    //[self addChild:[[GB2DebugDrawLayer alloc] init] z:30];
    
    // Pause button
//    CCSprite* pause = [CCSprite spriteWithFile:@"Replay icon.png"];
//    CCSprite* pauseSel = [CCSprite spriteWithFile:@"Replay icon.png"];
//    pauseButton = [CCMenuItemImage itemWithNormalImage:@"Pause icon.png" selectedImage:@"Pause icon.png" target:self selector:@selector(pauseGame)];
    pauseButton = [CCSprite spriteWithFile:@"Pause icon.png"];
    pauseButton.position = ccp(450,250);
    pauseButtonRect = CGRectMake((pauseButton.position.x-(pauseButton.contentSize.width)/2), (pauseButton.position.y-(pauseButton.contentSize.height)/2), (pauseButton.contentSize.width), (pauseButton.contentSize.height));
    [self addChild:pauseButton z:50];
    
    
    
    // Adding object layer
    plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys_default.png" capacity:150];
    [self addChild:plushyLayer z:200];
  

    // Add monkey
    plushy = [[[Monkey alloc] initWithGameLayer:self] autorelease];
    [plushy setPhysicsPosition:b2Vec2FromCC(300,200)];
    pv = 2.0;
    [plushy setLinearVelocity:b2Vec2(pv,0)];
    [plushyLayer addChild:[plushy ccNode] z:10];
    
    // add maze
    [self loadMaze];
    countDown = 1000;
    
    // Initializing variables
    nextObject= 3.0f;  // first object to appear after 3s
    objDelay = 2.0f; // next object to appear after 1s
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGestureRecognizer.delegate = self;
    [swipeLeftGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
    [self addGestureRecognizer:swipeRightGestureRecognizer];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGestureRecognizer.delegate = self;
    [swipeRightGestureRecognizer release];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer release];
    
    self.isTouchEnabled = YES;
    
    //[[CDAudioManager sharedManager] setMode:kAMM_MediaPlayback];
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
  _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
  
  // Add continuous scroll for clouds
  NSArray *clouds = [NSArray arrayWithObjects:_cloud1, _cloud2, nil];
  for (CCSprite *cloud in clouds) {
    if ([_backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
      [_backgroundNode incrementOffset:ccp(2*cloud.contentSize.width-[_backgroundNode convertToWorldSpace:cloud.position].x,0) forChild:cloud];
    }
  }
  
  // Add continuous scroll for the canyon
  NSArray *backgrounds = [NSArray arrayWithObjects: _canyons, _canyons2, nil];
  for (CCSprite *background in backgrounds) {
    if ([_backgroundNode convertToWorldSpace:background.position].x < -500) {
      [_backgroundNode incrementOffset:ccp(100+background.contentSize.width-[_backgroundNode convertToWorldSpace:background.position].x,0) forChild:background];
    }
  }
  
  // Add objects to path
  //[self nextObject:dt];
  
    //Animate rotation
//  if (ABS([maze ccNode].rotation) > ABS(angle) ) {
//    [maze setAngularVelocity:0];
//    [plushy setBodyType:b2_dynamicBody];
//  }
  
  //Moving camera
  if (countDown > 0) {
    countDown --;
  }
//
//  if ([plushy isRunning] && countDown ==0 ) {
//    float dy = [plushy ccNode].position.y - 150;
//    [plushy setPhysicsPosition:b2Vec2FromCC(200, 150)];
//    CGPoint mp = [maze ccNode].position;
//    mp.y = mp.y+dy;
//    [maze setPhysicsPosition:b2Vec2FromCGPoint(mp)];
//    countDown = -1;
//  }

  if (countDown == 0) {
    pv += 1;
    mv -= 3;
    [plushy setLinearVelocity:b2Vec2(pv,0)];
    [maze setLinearVelocity:b2Vec2(mv, 0)];
    countDown = 1000;
  }
  
  if ([plushy passLevel] && pass == false) {
    pass = true;
    // drop something on the screen to show that u passed the level
    //NSLog(@"passsss!");
    CCSprite* star = [CCSprite spriteWithFile:@"Star.png"];
    star.position = ccp(winSize.width*0.9, winSize.height*0.8);
    [_background addChild:star];
  }

  if ([plushy ccNode].position.y < 0 || [plushy isDead])
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
  maze = [Floor floorSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
  [maze setPhysicsPosition:b2Vec2FromCC(200,120)];
  mv = -4;
  [maze setLinearVelocity:b2Vec2(mv,0)];
  [self addChild:[maze ccNode] z:100];
}


- (void)handleTapGestureRecognizer:(UITapGestureRecognizer*)aGestureRecognizer
{
  CGPoint locationt=[aGestureRecognizer locationInView:[aGestureRecognizer view]];
  locationt.y = [[CCDirector sharedDirector] winSize].height - locationt.y;
  if (CGRectContainsPoint(pauseButtonRect, locationt)){
    [self pauseGame];
  }
  else if (CGRectContainsPoint(resumeButtonRect, locationt)){
    [self resumeGame];
  }
  
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
  //countDown = 5;
  
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
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  pauseLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 225, 125) width:300 height:150];
  //pauseLayer.anchorPoint = ccp(0.5,0.5);
  pauseLayer.position = ccp(winSize.width/2-pauseLayer.contentSize.width/2,
                            winSize.height/2 - pauseLayer.contentSize.height/2);

  
//  CCSprite *resume = [CCSprite spriteWithFile:@"Replay icon.png"]; 
//  CCSprite* resumeSel = [CCSprite spriteWithFile:@"Replay icon.png"];
  // Three options: restart, resume, home
  CCMenuItemImage *resumeButton = [CCMenuItemImage itemWithNormalImage:@"Replay icon.png" selectedImage:@"Replay icon.png" target:self selector:@selector(resumeGame)];
  resumeButton.position = ccp(pauseLayer.contentSize.width/2,pauseLayer.contentSize.height/2);
  resumeButtonRect = CGRectMake((winSize.width/2-resumeButton.contentSize.width/2),
                                  (winSize.height/2 - resumeButton.contentSize.height/2),
                                  (resumeButton.contentSize.width),
                                  (resumeButton.contentSize.height));
  [pauseLayer addChild:resumeButton];
  [self addChild:pauseLayer z:500];
}


-(void)resumeGame
{
  [self removeChild:pauseLayer cleanup:YES];
  [self resumeSchedulerAndActions];
  pauseButton.visible = YES;
  [[CCDirector sharedDirector] resume];
}

@end
