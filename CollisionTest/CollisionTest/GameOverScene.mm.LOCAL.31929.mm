//
//  GameOverScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 2/1/13.
//
//

#import "GameOverScene.h"
#import "GameScene.h"
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
    CCSprite *blueBG = [CCSprite spriteWithFile:@"Canyon background.png"];
    blueBG.anchorPoint = ccp(0,0);
    blueBG.position = ccp(0,0);
    [self addChild:blueBG];
    gameoverbg = congrats ? [CCSprite spriteWithFile: @"Level pass screen.png"] :
                            [CCSprite spriteWithFile: @"Level fail screen.png"];
    gameoverbg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:gameoverbg];
//    
//    CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello World"
//                                           fontName:@"GROBOLD"
//                                           fontSize:16];
//    [self addChild:label];
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *home = [CCMenuItemImage
                                     itemWithNormalImage:@"Home icon.png"
                                     selectedImage:nil
                                     target:self
                                     selector:@selector(goHome)];
    home.position = ccp(-winSize.width*7/24, -winSize.height/7);
    
    CCMenuItemImage *restart = [CCMenuItemImage
                                  itemWithNormalImage:@"Return icon.png"
                                  selectedImage:nil
                                  target:self
                                  selector:@selector(restart)];
    restart.position = ccp(-winSize.width*4/24,-winSize.height/7);
    
    CCMenuItemImage *next = [CCMenuItemImage
                                itemWithNormalImage:@"Play icon.png"
                                selectedImage:@"Play icon.png"
                                target:self
                                selector:@selector(nextLevel)];
    next.position = ccp(-winSize.width*1/24,-winSize.height/7);
    
    CCMenu *menu = (congrats && (curLevel != 6)) ? [CCMenu menuWithItems: home, restart, next, nil]
                            : [CCMenu menuWithItems: home, restart, nil];

    [menuLayer addChild: menu];
  }
  return self;
}

-(void)restart
{
  [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
}

-(void)nextLevel
{
  [[CCDirector sharedDirector] replaceScene:[GameScene scene:curLevel+1]];
}

- (void)goHome {
  
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
  
}

- (void)dealloc {
  [super dealloc];
}

@end