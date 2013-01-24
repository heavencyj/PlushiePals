//
//  HelloWorldLayer.m
//  Cocos2d Test
//
//  Created by Lan Li on 1/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCNode+SFGestureRecognizers.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"

#define kNumMazes   10

CCSprite *pig;
CCSprite *monkey;
CCSprite *bg;
int destpoint;

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

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

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    bg = [CCSprite spriteWithFile: @"Canyon_background.png"];
    bg.position = ccp(winSize.width/2, winSize.height/2);
    bg.scale = 1.5;
    [self addChild:bg];
    
    // create and initialize our seeker sprite, and add it to this layer
    pig = [CCSprite spriteWithFile: @"Monkey.png"];
    //pig.position = ccp(50, 100 );
    pig.position = ccp(winSize.width * 0.2, winSize.height * 0.5);
    pig.scale = 0.6;
    [self addChild:pig z:1];

    
    // do the same for our cocos2d guy, reusing the app icon as its image
    monkey = [CCSprite spriteWithFile: @"empty.png"];
    monkey.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:monkey z:1];
    destpoint = 0;
    
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
    //[self schedule:@selector(nextFrame:)];
    [self scheduleUpdate];
    
    self.isTouchEnabled = YES;
    
    // 1) Create the CCParallaxNode
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode z:0];
    
    // 2) Create the sprites we'll add to the CCParallaxNode
    _cloud1 = [CCSprite spriteWithFile:@"Canyon_cloud1.png"];
    _cloud2 = [CCSprite spriteWithFile:@"Canyon_cloud2.png"];
    _canyons = [CCSprite spriteWithFile:@"Canyons.png"];
    
    // 3) Determine relative movement speeds for space dust and background
    CGPoint cloudSpeed = ccp(0.1, 0.1);
    CGPoint bgSpeed = ccp(0.05, 0.05);
    //CGPoint mazeSpeed = ccp(0.1,0.1);
    
    // 4) Add children to CCParallaxNode
    [_backgroundNode addChild:_canyons z:1 parallaxRatio:cloudSpeed positionOffset:ccp(_canyons.contentSize.width/2,_canyons.contentSize.height/2)];
    [_backgroundNode addChild:_cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
    [_backgroundNode addChild:_cloud2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_cloud1.contentSize.width,winSize.height/1.2)];
    //[_backgroundNode addChild:monkey z:1 parallaxRatio:mazeSpeed positionOffset:ccp(winSize.width*0.25,0)];
    
    // Add to bottom of init
    _mazes = [[CCArray alloc] initWithCapacity:kNumMazes];
    for(int i = 0; i < kNumMazes; ++i) {
      int rand = [self getRandomNumberBetweenMin:1 andMax:5];
      CCSprite *maze = [CCSprite spriteWithFile:[@"unit_canyon" stringByAppendingFormat:@"%d.png",rand]];
      maze.visible = NO;
      //maze.position = ccp(monkey.contentSize.height, monkey.contentSize.width);
      //[self addChild:maze];
      [monkey addChild:maze];
      [_mazes addObject:maze];
    }
    
//    monkey.anchorPoint = CGPointMake(pig.position.x/monkey.contentSize.width,
//                                     pig.position.y/monkey.contentSize.height);
    
  }

	return self;
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

-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}

#pragma mark GameKit delegate
// Add new update method
- (void)update:(ccTime)dt {
  
  CGPoint backgroundScrollVel = ccp(-1000, 0);
  _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
  
  // Add at end of your update method
  NSArray *clouds = [NSArray arrayWithObjects:_cloud1, _cloud2, nil];
  for (CCSprite *cloud in clouds) {
    if ([_backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
      [_backgroundNode incrementOffset:ccp(2*cloud.contentSize.width,0) forChild:cloud];
    }
  }
  
  NSArray *backgrounds = [NSArray arrayWithObjects:_canyons, nil];
  for (CCSprite *background in backgrounds) {
    if ([_backgroundNode convertToWorldSpace:background.position].x < -background.contentSize.width) {
      [_backgroundNode incrementOffset:ccp(1000,0) forChild:background];
    }
  }
  
  if ([_backgroundNode convertToWorldSpace:monkey.position].x < -monkey.contentSize.width) {
    [_backgroundNode incrementOffset:ccp(1000,0) forChild:monkey];
  }
  
  // Add to bottom of update loop
  CGSize winSize = [CCDirector sharedDirector].winSize;
  double curTime = CACurrentMediaTime();
  if (curTime > _nextMazeSpawn) {
    
    //float randSecs = [self randomValueBetween:0.20 andValue:1.0];
    _nextMazeSpawn = 1 + curTime;
    
    //float randY = [self randomValueBetween:0.0 andValue:winSize.height];
    //float randDuration = [self randomValueBetween:2.0 andValue:10.0];
    float randDuration = 7;
    
    CCSprite *maze = [_mazes objectAtIndex:_nextMaze];
    _nextMaze++;
    if (_nextMaze >= _mazes.count) _nextMaze = 0;
    
    [maze stopAllActions];
    //maze.position = ccp(winSize.width, winSize.height);
    maze.visible = YES;
    
    switch (destpoint) {
      case 0:
        maze.position = ccp(winSize.width, winSize.height);
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-maze.contentSize.width, 0)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        
        break;
      
      case 1:
        maze.position = ccp(winSize.height, winSize.width);
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(0, -winSize.width-maze.contentSize.width)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        break;

      case 2:
        maze.position = ccp(monkey.contentSize.width-winSize.width, winSize.height);
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(winSize.width+maze.contentSize.width, 0)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        break;

      case 3:
        maze.position = ccp(monkey.contentSize.height-winSize.height, monkey.contentSize.width-winSize.width);
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(0, winSize.width+maze.contentSize.width)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        break;
        
      default:
        break;
    }
//    [maze runAction:[CCSequence actions:
//                         [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-maze.contentSize.width, 0)],
//                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
//                         nil]];
    
  }
}

// Add new method
- (void)setInvisible:(CCNode *)node {
  node.visible = NO;
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
  [monkey runAction:[CCRotateBy actionWithDuration:0.8 angle:angle]];
  
  //TODO do something to direction here!!!!
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
  
  //Move to another function
  CGSize winSize = [CCDirector sharedDirector].winSize;  
  for (CCSprite *maze in _mazes) {
    [maze stopAllActions];
//    [maze runAction:[CCSequence actions:
//                     [CCMoveBy actionWithDuration:7 position:ccp(0,winSize.width+maze.contentSize.width)],
//                     [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
//                     nil]];
    float randDuration = 7;

    switch (destpoint) {
      case 0:
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-maze.contentSize.width, 0)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        
        break;
        
      case 1:
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(0, -winSize.width-maze.contentSize.width)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        break;
        
      case 2:
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(winSize.width+maze.contentSize.width, 0)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        break;
        
      case 3:
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:randDuration position:ccp(0, winSize.width+maze.contentSize.width)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        break;
        
      default:
        break;
    }
  }
}

- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  [pig stopAllActions];
  [pig runAction: [CCJumpBy actionWithDuration:1 position:ccp(0,0) height:80 jumps:1]];
}
@end