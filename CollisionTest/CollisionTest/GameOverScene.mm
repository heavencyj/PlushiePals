//
//  GameOverScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 2/1/13.
//
//

#import "GameOverScene.h"
#import "HelloWorldLayer.h"
#import "MainMenuScene.h"

@implementation GameOverScene
CCSprite *gameoverbg;
bool congrats;
int curLevel;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOverScene *layer = [GameOverScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(CCScene *) scene:(bool)didpass withLevel:(int)level
{
  congrats = didpass;
  curLevel = level;
  return [self scene];
  
}


-(id) init
{
  if( (self=[super init] )) {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *blueBG = [CCSprite spriteWithFile:@"Canyon background blue.png"];
    blueBG.anchorPoint = ccp(0,0);
    blueBG.position = ccp(0,0);
    [self addChild:blueBG];
    gameoverbg = congrats ? [CCSprite spriteWithFile: @"Congrats screen.png"] :
                            [CCSprite spriteWithFile: @"Oops screen.png"];
    gameoverbg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:gameoverbg];
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *home = [CCMenuItemImage
                                     itemWithNormalImage:@"Home button.png"
                                     selectedImage:@"Home button.png"
                                     target:self
                                     selector:@selector(goHome)];
    home.position = ccp(-winSize.width/5, 0);
    
    CCMenuItemImage *restart = [CCMenuItemImage
                                  itemWithNormalImage:@"Restart button.png"
                                  selectedImage:@"Restart button.png"
                                  target:self
                                  selector:@selector(restart)];
    restart.position = ccp(-winSize.width/5,-winSize.height/8);
    
    CCMenuItemImage *next = [CCMenuItemImage
                                itemWithNormalImage:@"Next button.png"
                                selectedImage:@"Next button.png"
                                target:self
                                selector:@selector(nextLevel)];
    next.position = ccp(-winSize.width/5,-winSize.height/4);
    
    CCMenu *menu = (congrats && (curLevel != 4)) ? [CCMenu menuWithItems: home, restart, next, nil]
                            : [CCMenu menuWithItems: home, restart, nil];

    [menuLayer addChild: menu];
  }
  return self;
}

-(void)restart
{
  [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

-(void)nextLevel
{
  [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene:curLevel+1]];
}

- (void)goHome {
  
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
  
}

- (void)dealloc {
  [super dealloc];
}

@end