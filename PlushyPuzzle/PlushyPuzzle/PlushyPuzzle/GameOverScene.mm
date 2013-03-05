//
//  GameOverScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 2/1/13.
//
//

#import "GameOverScene.h"
#import "GameLayer.h"

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


-(id) init
{
  if( (self=[super init] )) {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *blueBG = [CCSprite spriteWithFile:@"Canyon background blue.png"];
    blueBG.anchorPoint = ccp(0,0);
    blueBG.position = ccp(0,0);
    [self addChild:blueBG];
    gameoverbg = [CCSprite spriteWithFile: @"Oops screen.png"];
//    gameoverbg = congrats ? [CCSprite spriteWithFile: @"Congrats screen.png"] :
//                            [CCSprite spriteWithFile: @"Oops screen.png"];
    gameoverbg.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:gameoverbg];
//    
//    CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello World"
//                                           fontName:@"GROBOLD"
//                                           fontSize:16];
//    [self addChild:label];
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
//    CCMenuItemImage *home = [CCMenuItemImage
//                                     itemWithNormalImage:@"Home icon.png"
//                                     selectedImage:@"Home icon selected.png"
//                                     target:self
//                                     selector:@selector(goHome)];
//    home.position = ccp(-winSize.width*7/24, -winSize.height/7);
    
    CCMenuItemImage *restart = [CCMenuItemImage
                                  itemWithNormalImage:@"Replay icon.png"
                                  selectedImage:@"Replay icon selected.png"
                                  target:self
                                  selector:@selector(restart)];
    restart.position = ccp(-winSize.width*4/24,-winSize.height/7);
    
//    CCMenuItemImage *next = [CCMenuItemImage
//                                itemWithNormalImage:@"Next icon.png"
//                                selectedImage:@"Next icon selected.png"
//                                target:self
//                                selector:@selector(nextLevel)];
//    next.position = ccp(-winSize.width*1/24,-winSize.height/7);
    
//    CCMenu *menu = (congrats && (curLevel != 4)) ? [CCMenu menuWithItems: home, restart, next, nil]
//                            : [CCMenu menuWithItems: home, restart, nil];
    
    CCMenu *menu = [CCMenu menuWithItems: restart, nil];
      
    [menuLayer addChild: menu];
  }
  return self;
}

-(void)restart
{
  [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
}

//-(void)nextLevel
//{
//  [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene:curLevel+1]];
//}
//
//- (void)goHome {
//  
//  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
//  
//}

- (void)dealloc {
  [super dealloc];
}

@end