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
#import "GB2DebugDrawLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"

#define kNumMazes 10
#define PTM_RATIO 32
#define WALKING_FRAMES 3
#define MAZE_LOW 30

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize objectLayer = _objectLayer;
@synthesize walkAction = _walking;
Monkey *plushy;
int newMaze;
int duration;
int verticalMazeObj;
double nextMazeSpawn;
int lastMazeNum;
int lastMazeType;
Floor *lastMaze;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
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

// On "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	if( (self=[super init]) ) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Adding solid background color
        _background = [CCSprite spriteWithFile: @"Canyon background.png"];
        _background.position = ccp(winSize.width/2, winSize.height/2);
        _background.scale = 1.5;
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
        [_backgroundNode addChild:_cloud2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_cloud1.contentSize.width+200,winSize.height/1.2)];
        
        // Adding object layer
        _objectLayer = [CCSpriteBatchNode batchNodeWithFile:@"plushypals.png" capacity:150];
        [self addChild:_objectLayer z:20];
      

    lastMazeNum = 0;
    //[self addMazeObject];
    _mazes = [[CCArray alloc] initWithCapacity:kNumMazes];
    [self generatePath];
    
    // Add monkey
    plushy = [[[Monkey alloc] initWithGameLayer:self] autorelease];
    [_objectLayer addChild:[plushy ccNode] z:10000];
    [plushy setPhysicsPosition:b2Vec2FromCC(240,90)];
    [plushy setLinearVelocity:b2Vec2(1.0,0)];
    
    // Initializing variables
    nextMazeSpawn = 0;
    duration = 4;
    verticalMazeObj = 0;
    
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
  
  //CGSize windowSize = [[CCDirector sharedDirector] winSize];
  
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
  
  // Add maze objects to screen
  //[self addMazeObject];
  //[self generatePath];
  
}

-(void)generatePath
{
 
  int straight = [self getRandomNumberBetweenMin:1 andMax:8];
  
  for (int i = 0; i < straight; i++) {
    Floor *_mazeObj = [Floor floorSprite:@"unit_canyon1" spriteName:@"unit_canyon1.png"];
    if ([_mazes lastObject] == nil){
      [_mazeObj setPhysicsPosition:b2Vec2FromCC(75, MAZE_LOW)];
    }
    else{
      [_mazeObj setPhysicsPosition:b2Vec2FromCC([[_mazes lastObject] ccNode].position.x+75, MAZE_LOW)];
    }
    [_mazeObj setLinearVelocity:b2Vec2(-0.8,0)];
    [_objectLayer addChild:[_mazeObj ccNode] z:50]; //TODO: Do not keep adding maze objects into the objectLayer!!!!
    [_mazes addObject:_mazeObj];
    //lastMaze = _mazeObj;
  }
  
  int lastmaze =[self getRandomNumberBetweenMin:3 andMax:4];
  NSString *endMaze = [NSString stringWithFormat:@"unit_canyon%d",lastmaze];
  Floor *_mazeObj = [Floor floorSprite:endMaze spriteName:[endMaze stringByAppendingString:@".png"]];
  [_mazeObj setPhysicsPosition:b2Vec2FromCC([[_mazes lastObject] ccNode].position.x+75, MAZE_LOW)];
  [_mazeObj setLinearVelocity:b2Vec2(-0.8,0)];
  [_objectLayer addChild:[_mazeObj ccNode] z:50]; //TODO: Do not keep adding maze objects into the objectLayer!!!!
  [_mazes addObject:_mazeObj];

}

-(void)addMazeObject
{
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  
  // Generate as many maze objects as can fit into the screen.
  Floor *lastMazeObj = [_mazes lastObject];
  NSString *mazeObjImage = @"unit_canyon1";
  //[[lastMazeObj ccNode] convertToWorldSpace:[lastMazeObj ccNode].position];
  while([lastMazeObj ccNode].position.x < winSize.width || [_mazes count] < 1)
  {
    //        NSLog(@"Last maze physics position: (%f, %f)", [lastMazeObj ccNode].position.x, [lastMazeObj ccNode].position.y);
    //        NSLog(@"Total %d mazes", [_mazes count]);
    Floor *_mazeObj = [Floor floorSprite:mazeObjImage spriteName:[mazeObjImage stringByAppendingString:@".png"]];
    if (lastMazeObj == nil) {
      [_mazeObj setPhysicsPosition:b2Vec2FromCC(75, MAZE_LOW)];
      //            NSLog(@"Added 1st maze at position: (%d, %d)", 75, MAZE_LOW);
    }
    else
    {
      if([mazeObjImage isEqualToString:@"unit_canyon4"]) // Clean up this logic here
      {
        [_mazeObj setPhysicsPosition:b2Vec2FromCC([lastMazeObj ccNode].position.x+80, MAZE_LOW)];
      }
      else
      {
        [_mazeObj setPhysicsPosition:b2Vec2FromCC([lastMazeObj ccNode].position.x+75, MAZE_LOW)];
        //            NSLog(@"Added new maze at position: (%f, %d)", [lastMazeObj ccNode].position.x+70, MAZE_LOW);
      }
    }
    
    [_mazeObj setLinearVelocity:b2Vec2(-0.8,0)];
    [_objectLayer addChild:[_mazeObj ccNode] z:50]; //TODO: Do not keep adding maze objects into the objectLayer!!!!
    [_mazes addObject:_mazeObj];
    lastMazeObj = _mazeObj;
    
    if (verticalMazeObj == 3) { //Crude code for testing collision detection.
      verticalMazeObj = 0;
      mazeObjImage = @"unit_canyon4";
    }
    verticalMazeObj++;
  }
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

// Add new method, above update loop
- (float)randomValueBetween:(float)low andValue:(float)high {
  return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (void)addBoxBodyForSprite:(CCSprite *)sprite {
  
  b2BodyDef spriteBodyDef;
  spriteBodyDef.type = b2_staticBody;
  spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
  spriteBodyDef.userData = sprite;
  b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
  
  b2PolygonShape spriteShape;
  spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
                       sprite.contentSize.height/PTM_RATIO/2);
  
  b2FixtureDef spriteShapeDef;
  spriteShapeDef.shape = &spriteShape;
  spriteShapeDef.density = 10.0;
  spriteShapeDef.isSensor = true;
  
  spriteBody->CreateFixture(&spriteShapeDef);
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

- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  [plushy jump];
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
  Floor *oldmaze;
  for (oldmaze in _mazes) {
    if (oldmaze != [_mazes lastObject])  [self setInvisible:[oldmaze ccNode]];
  }
  oldmaze = [_mazes lastObject];
  
//  [oldmaze runAction:[CCSequence actions: [CCRotateBy actionWithDuration:0.8 angle:angle], [CCCallFuncN actionWithTarget:self selector:@selector(generatePath)], nil]];
  [oldmaze turn:angle];
  [self generatePath];
}

@end
