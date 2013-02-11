//
//  MainMenuScene.m
//  Plushy
//
//  Created by Heaven Chen on 2/11/13.
//
//

#import "MainMenuScene.h"
#import "ActionLayer.h"

@implementation MainMenuScene

+(id) scene
{
  CCScene *scene = [CCScene node];
  
  MainMenuScene *layer = [MainMenuScene node];
  
  [scene addChild: layer];
  
  return scene;
}

-(id) init
{
  
  if( (self=[super init] )) {
    
//    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Main Menu" fontName:@"Courier" fontSize:64];
//    title.position =  ccp(240, 240);
//    [self addChild: title];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"Intro screen.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:background];
    
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *startButton = [CCMenuItemImage
                                    itemWithNormalImage:@"Play.png"
                                    selectedImage:@"Play selected.png"
                                    target:self
                                    selector:@selector(startGame:)];
    
    CCMenu *menu = [CCMenu menuWithItems: startButton, nil];
    [menuLayer addChild: menu];
    
    
  }
  return self;
}

- (void) startGame: (id) sender
{
  [[CCDirector sharedDirector] replaceScene:[ActionLayer scene]];
}

- (void) dealloc
{
  
  [super dealloc];
}
@end