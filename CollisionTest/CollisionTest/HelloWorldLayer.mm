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
@synthesize objectLayer = _objectLayer;
@synthesize walkAction = _walking;
Monkey *plushy;
Floor *maze;
int level;
bool pass;

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
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"plushypals.plist"];
    
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
    
    // Adding object layer
    _objectLayer = [CCSpriteBatchNode batchNodeWithFile:@"plushypals.png" capacity:150];
    [self addChild:_objectLayer z:20];
  

    // Add monkey
    plushy = [[[Monkey alloc] initWithGameLayer:self] autorelease];
    [plushy setPhysicsPosition:b2Vec2FromCC(300,200)];
    [plushy setLinearVelocity:b2Vec2(2.0,0)];
    [_objectLayer addChild:[plushy ccNode] z:10000];
    
    // add maze
    [self loadMaze];
    
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
  
  if ([plushy passLevel] && pass == false) {
    pass = true;
    // drop something on the screen to show that u passed the level
    //NSLog(@"passsss!");
    CCSprite* star = [CCSprite spriteWithFile:@"Star.png"];
    star.position = ccp(winSize.width*0.8, winSize.height*0.8);
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
    [obj setPhysicsPosition:b2Vec2FromCC(400, MAZE_LOW+40)];
    [_objectLayer addChild:[obj ccNode]];
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
  
  NSString *shape = [@"map level " stringByAppendingFormat:@"%d", level];
  maze = [Floor floorSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
  [maze setPhysicsPosition:b2Vec2FromCC(200,140)];
  [maze setLinearVelocity:b2Vec2(-4.0,0)];
  //[_objectLayer addChild:[maze ccNode] z:50 tag:5]; //TODO: Do not keep adding maze objects into the
  [_objectLayer addChild:[maze ccNode] z:10];
}


- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  [plushy jump];
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
  CGPoint p = [plushy ccNode].position;
  
  p.y = (angle > 0) ? p.y+10:p.y-80;
  
  CGPoint oldp = [maze ccNode].position;
  CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(angle) of:oldp around:p];
  
  [maze transform:b2Vec2FromCGPoint(newp) withAngle:angle];

}

-(CGPoint)rotate:(float)theta of:(CGPoint)pos around:(CGPoint)origin
{
  float newx = cos(theta) * (pos.x-origin.x) - sin(theta) * (pos.y-origin.y) + origin.x;
  float newy = sin(theta) * (pos.x-origin.x) + cos(theta) * (pos.y-origin.y) + origin.y;

  return CGPointMake(newx,newy);
  
}

@end
