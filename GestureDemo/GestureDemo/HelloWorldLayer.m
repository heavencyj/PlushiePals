//
//  HelloWorldLayer.m
//  Cocos2d Test
//
//  Created by Lan Li on 1/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "CCTouchDispatcher.h"

CCSprite *pig;
CCSprite *monkey;
CCSprite *bg;

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
    bg = [CCSprite spriteWithFile: @"Canyon.png"];
    bg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:bg];
    
    // create and initialize our seeker sprite, and add it to this layer
    pig = [CCSprite spriteWithFile: @"PigIcon.png"];
    pig.position = ccp(50, 100 );
    [self addChild:pig];
    
    // do the same for our cocos2d guy, reusing the app icon as its image
    monkey = [CCSprite spriteWithFile: @"MonkeyIcon.png"];
    monkey.position = ccp( 50, 60 );
    [self addChild:monkey];
    
    
    
    // schedule a repeating callback on every frame
    [self schedule:@selector(nextFrame:)];
    
    self.isTouchEnabled = YES;
  }
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void) nextFrame:(ccTime)dt {
  pig.position = ccp( pig.position.x + 100*dt, pig.position.y );
  if (pig.position.x > 480+32) {
    pig.position = ccp( -32, pig.position.y );
  }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	//CGPoint location = [self convertTouchToNodeSpace: touch];
	[pig stopAllActions];
	//[monkey runAction: [CCMoveTo actionWithDuration:1 position:location]];
  [pig runAction: [CCJumpBy actionWithDuration:1 position:ccp(0,0) height:80 jumps:1]];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  return YES;
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

#pragma mark GameKit delegate

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
@end
