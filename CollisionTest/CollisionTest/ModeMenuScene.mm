//
//  ModeMenuScene.m
//  Plushy
//
//  Created by Heaven Chen on 2/13/13.
//

#import "ModeMenuScene.h"
#import "HelloWorldLayer.h"
#import "MainMenuScene.h"

@implementation ModeMenuScene
int gameMode;

+(id) scene
{
  CCScene *scene = [CCScene node];
  
  ModeMenuScene *layer = [ModeMenuScene node];
  
  [scene addChild: layer];
  
  return scene;
}

+(id) scene:(int)withMode
{  
  gameMode = withMode;
  return [self scene];
}

-(id) init
{
  
  if( (self=[super init] )) {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"Intro screen.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:background];
    
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *home = [CCMenuItemImage
                               itemWithNormalImage:@"Level Home button.png"
                               selectedImage:@"Level Home button.png"
                               target:self
                               selector:@selector(goHome)];
    home.position = ccp(-winSize.width/7,0);
    
    CCMenuItemImage *level0 = [CCMenuItemImage
                                     itemWithNormalImage:@"Level 0 button.png"
                                     selectedImage:@"Level 0 button.png"
                                     target:self
                                     selector:@selector(loadTutorial)];
    level0.position = ccp(winSize.width/7,0);
    
    CCMenuItemImage *level1 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 1 button.png"
                                    selectedImage:@"Level 1 button.png"
                                    target:self
                                    selector:@selector(startGame:)];
    level1.position = ccp(-winSize.width/3,-winSize.height/3);
    level1.tag = 1;
    
    CCMenuItemImage *level2 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 2 button.png"
                                    selectedImage:@"Level 2 button.png"
                                    target:self
                                    selector:@selector(startGame:)];
    level2.position = ccp(-winSize.width/9,-winSize.height/3);
    level2.tag = 2;
    
    CCMenuItemImage *level3 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 3 button.png"
                                    selectedImage:@"Level 3 button.png"
                                    target:self
                                    selector:@selector(startGame:)];
    level3.position = ccp(winSize.width/9,-winSize.height/3);
    level3.tag = 3;
    
    CCMenuItemImage *level4 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 4 button.png"
                                    selectedImage:@"Level 4 button.png"
                                    target:self
                                    selector:@selector(startGame:)];
    level4.position = ccp(winSize.width/3,-winSize.height/3);
    level4.tag = 4;
    
    
    CCMenu *menu = [CCMenu menuWithItems: home, level0, level1, level2, level3, level4, nil];
    [menuLayer addChild: menu];    
  }
  return self;
}

- (void) startGame: (id) sender
{ 
  CCMenuItemImage *button = (CCMenuItemImage *)sender;
  [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene:button.tag]];
}

- (void)goHome {
  
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
  
}

-(void) loadTutorial
{
  
}

- (void) dealloc
{
  
  [super dealloc];
}
@end