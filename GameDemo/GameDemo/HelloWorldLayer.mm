//
//  HelloWorldLayer.mm
//  GameDemo
//
//  Created by Heaven Chen on 1/23/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "PhysicsSprite.h"
#import "CCNode+SFGestureRecognizers.h"
#import "CCParallaxNode-Extras.h"

#define kNumMazes   10

// Globle variables for graphic elements
CCSprite *mazeHolder;
CCSprite *bg;
CCSprite *plushy;
CCParallaxNode *backgroundNode;
CCSprite *cloud1;
CCSprite *cloud2;
CCSprite *canyons1;
CCSprite *canyons2;
CCArray *mazes;

// Number variables for tracking
int destpoint;
int nextMaze;
double nextMazeSpawn;

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    // Initialize background
    bg = [CCSprite spriteWithFile: @"Canyon_background.png"];
    bg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:bg];    
    
    // Create the maze hodler for rotation later. add to this layer
    mazeHolder = [CCSprite spriteWithFile: @"empty.png"];
    mazeHolder.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:mazeHolder z:1];
    destpoint = 0;
    
    // Background scrolling and moving
    // 1) Create the CCParallaxNode
    backgroundNode = [CCParallaxNode node];
    [self addChild:backgroundNode z:0];
    
    // 2) Create the sprites we'll add to the CCParallaxNode
    cloud1 = [CCSprite spriteWithFile:@"Canyon_cloud1.png"];
    cloud2 = [CCSprite spriteWithFile:@"Canyon_cloud2.png"];
    canyons1 = [CCSprite spriteWithFile:@"Canyons_looped.png"];
    
    // 3) Determine relative movement speeds for space dust and background
    CGPoint cloudSpeed = ccp(0.1, 0.1);
    CGPoint bgSpeed = ccp(0.05, 0.05);
    
    // 4) Add children to CCParallaxNode
    [backgroundNode addChild:canyons1 z:1 parallaxRatio:bgSpeed positionOffset:ccp(winSize.width/2,canyons1.contentSize.height/2)];
    [backgroundNode addChild:cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(cloud1.contentSize.width/2,winSize.height/1.2)];
    [backgroundNode addChild:cloud2 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(2*cloud1.contentSize.width,winSize.height/1.2)];
    
    // Generate various of types of maze unit
    mazes = [[CCArray alloc] initWithCapacity:kNumMazes];
    for(int i = 0; i < kNumMazes; ++i) {
      int rand = [self getRandomNumberBetweenMin:1 andMax:5];
      CCSprite *maze = [CCSprite spriteWithFile:[@"unit_canyon" stringByAppendingFormat:@"%d.png",rand]];
      maze.visible = NO;
      [mazeHolder addChild:maze];
      [mazes addObject:maze];
    }
    
    // Create and initialize plushy sprite, and add it to this layer
    plushy = [CCSprite spriteWithFile: @"Monkey_run_1.png"];
    plushy.position = ccp(winSize.width * 0.2, winSize.height * 0.6);
    [self addChild:plushy z:1];
    
    // Add guesture recognizer to this layer
    self.isTouchEnabled = YES;
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
    
    // schedule a repeating callback on every frame
    [self scheduleUpdate];
  }
  
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

-(void) update: (ccTime) dt
{
	// Set background scrolling velocity
  CGPoint backgroundScrollVel = ccp(-1000, 0);
  backgroundNode.position = ccpAdd(backgroundNode.position, ccpMult(backgroundScrollVel, dt));
  
  // Add repeatitive scrolling for background elements
  NSArray *clouds = [NSArray arrayWithObjects:cloud1, cloud2, nil];
  for (CCSprite *cloud in clouds) {
    if ([backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
      [backgroundNode incrementOffset:ccp(5*cloud.contentSize.width,0) forChild:cloud];
    }
  }
  NSArray *backgrounds = [NSArray arrayWithObjects:canyons1, nil];
  for (CCSprite *background in backgrounds) {
    if ([backgroundNode convertToWorldSpace:background.position].x < -background.contentSize.width) {
      [backgroundNode incrementOffset:ccp(1000,0) forChild:background];
    }
  }  
  if ([backgroundNode convertToWorldSpace:mazeHolder.position].x < -mazeHolder.contentSize.width) {
    [backgroundNode incrementOffset:ccp(1000,0) forChild:mazeHolder];
  }
  
  // Generate mazes
  double curTime = CACurrentMediaTime();
  if (curTime > nextMazeSpawn) {
    nextMazeSpawn = 1 + curTime;
    //TODO: ADD algorithm to decide how to add mazes in order with same speed
    //float randY = [self randomValueBetween:0.0 andValue:winSize.height];
    
    CCSprite *maze = [mazes objectAtIndex:nextMaze];
    nextMaze++;
    if (nextMaze >= mazes.count) nextMaze = 0;
    
    [maze stopAllActions];
    maze.visible = YES;
    [self rotateDestPoint:maze];
  }
  
}

-(void)rotateDestPoint:(CCSprite *)maze {
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  float duration = 7;
  
  switch (destpoint) {
    case 0:
      maze.position = ccp(winSize.width, winSize.height);
      [maze runAction:[CCSequence actions:
                       [CCMoveBy actionWithDuration:duration position:ccp(-winSize.width-maze.contentSize.width, 0)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                       nil]];
      
      break;
      
    case 1:
      maze.position = ccp(winSize.height, winSize.width);
      [maze runAction:[CCSequence actions:
                       [CCMoveBy actionWithDuration:duration position:ccp(0, -winSize.width-maze.contentSize.width)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                       nil]];
      break;
      
    case 2:
      maze.position = ccp(mazeHolder.contentSize.width-winSize.width, winSize.height);
      [maze runAction:[CCSequence actions:
                       [CCMoveBy actionWithDuration:duration position:ccp(winSize.width+maze.contentSize.width, 0)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                       nil]];
      break;
      
    case 3:
      maze.position = ccp(mazeHolder.contentSize.height-winSize.height, mazeHolder.contentSize.width-winSize.width);
      [maze runAction:[CCSequence actions:
                       [CCMoveBy actionWithDuration:duration position:ccp(0, winSize.width+maze.contentSize.width)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                       nil]];
      break;
      
    default:
      break;
  }

}

-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}

- (void)setInvisible:(CCNode *)node {
  node.visible = NO;
}

// Swipe guesture handler: rotate the mazes
- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  // Turn the maze to the suggested direction
  float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
  [mazeHolder runAction:[CCRotateBy actionWithDuration:0.8 angle:angle]];
  
  // Keep track of current direction to determine the dest point
  switch (destpoint) {
    case 0:
      destpoint = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 1:3;
      break;
    case 1:
      destpoint = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 2:0;
      break;
    case 2:
      destpoint = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 3:1;
      break;
    case 3:
      destpoint = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 0:2;
      break;
      
    default:
      break;
  }
  
  for (CCSprite *maze in mazes) {
    [maze stopAllActions];
    [self rotateDestPoint:maze];
  }
}

// Tap guester handler: perform special move
- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  [plushy stopAllActions];
  [plushy runAction: [CCJumpBy actionWithDuration:1 position:ccp(0,0) height:80 jumps:1]];
}

@end
