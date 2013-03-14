//
//  ModeMenuScene.m
//  Plushy
//
//  Created by Heaven Chen on 2/13/13.
//

#import "LevelMenuScene.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "TutorialScene.h"

#define ButtonOffset 20

@implementation LevelMenuScene
int gameMode;

+(id) scene
{
  CCScene *scene = [CCScene node];
  
  LevelMenuScene *layer = [LevelMenuScene node];
  
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
    CCSprite *background = [CCSprite spriteWithFile:@"Menu screen.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:background];
    
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *home = [CCMenuItemImage
                               itemWithNormalImage:@"Home icon.png"
                               selectedImage:nil
                               target:self
                               selector:@selector(goHome)];
    home.position = ccp(-winSize.width/7,-winSize.height/3);
    
    //quick tutorial tip
    CCMenuItemImage *tip = [CCMenuItemImage
                             itemWithNormalImage:@"Question icon.png"
                             selectedImage:nil
                             target:self
                             selector:@selector(loadTutorial)];
    tip.position = ccp(winSize.width/7,-winSize.height/3);
    
    CCMenuItemImage *level1 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 1.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(startGame:)];
    level1.position = ccp(-winSize.width/3,winSize.height/4.5+ButtonOffset);
    level1.tag = 1;
    
    CCMenuItemImage *level2 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 2.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(startGame:)];
    level2.position = ccp(-winSize.width/9,winSize.height/4.5+ButtonOffset);
    level2.tag = 2;
    
    CCMenuItemImage *level3 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 3.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(startGame:)];
    level3.position = ccp(winSize.width/9,winSize.height/4.5+ButtonOffset);
    level3.tag = 3;
    
    CCMenuItemImage *level4 = [CCMenuItemImage
                                    itemWithNormalImage:@"Level 4.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(startGame:)];
    level4.position = ccp(winSize.width/3,winSize.height/4.5+ButtonOffset);
    level4.tag = 4;
    
    CCMenuItemImage *level5 = [CCMenuItemImage
                               itemWithNormalImage:@"Level 5.png"
                               selectedImage:nil
                               target:self
                               selector:@selector(startGame:)];
    level5.position = ccp(-winSize.width/3,ButtonOffset);
    level5.tag = 5;
    
    CCMenuItemImage *level6 = [CCMenuItemImage
                               itemWithNormalImage:@"Level 6.png"
                               selectedImage:nil
                               target:self
                               selector:@selector(startGame:)];
    level6.position = ccp(-winSize.width/9,ButtonOffset);
    level6.tag = 6;
    
    CCMenuItemImage *level7 = [CCMenuItemImage
                               itemWithNormalImage:@"Level lock.png"
                               selectedImage:nil
                               target:self
                               selector:nil];
    level7.position = ccp(winSize.width/9,ButtonOffset);
    level7.tag = 7;
    
    CCMenuItemImage *level8 = [CCMenuItemImage
                               itemWithNormalImage:@"Level lock.png"
                               selectedImage:nil
                               target:self
                               selector:nil];
    level8.position = ccp(winSize.width/3,ButtonOffset);
    level8.tag = 8;
    
    CCMenuItemImage *level9 = [CCMenuItemImage
                               itemWithNormalImage:@"Level lock.png"
                               selectedImage:nil
                               target:self
                               selector:nil];
    level9.position = ccp(-winSize.width/3,-winSize.height/4.5+ButtonOffset);
    level9.tag = 9;
    
    CCMenuItemImage *level10 = [CCMenuItemImage
                               itemWithNormalImage:@"Level lock.png"
                               selectedImage:nil
                               target:self
                               selector:nil];
    level10.position = ccp(-winSize.width/9,-winSize.height/4.5+ButtonOffset);
    level10.tag = 10;
    
    CCMenuItemImage *level11 = [CCMenuItemImage
                               itemWithNormalImage:@"Level lock.png"
                               selectedImage:nil
                               target:self
                               selector:nil];
    level11.position = ccp(winSize.width/9,-winSize.height/4.5+ButtonOffset);
    level11.tag = 11;
    
    CCMenuItemImage *level12 = [CCMenuItemImage
                               itemWithNormalImage:@"Level lock.png"
                               selectedImage:nil
                               target:self
                               selector:nil];
    level12.position = ccp(winSize.width/3,-winSize.height/4.5+ButtonOffset);
    level12.tag = 12;
    
    
    CCMenu *menu = [CCMenu menuWithItems: home, tip,
                    level1, level2, level3, level4,
                    level5, level6, level7, level8,
                    level9, level10, level11, level12,nil];
    [menuLayer addChild: menu];    
  }
  return self;
}

- (void) startGame: (id) sender
{ 
  CCMenuItemImage *button = (CCMenuItemImage *)sender;
  [[CCDirector sharedDirector] replaceScene:[GameScene scene:button.tag]];
}

- (void)goHome {
  
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
  
}

-(void) loadTutorial
{
  [[CCDirector sharedDirector] replaceScene:[TutorialScene scene]];
}

- (void) dealloc
{
  
  [super dealloc];
}
@end