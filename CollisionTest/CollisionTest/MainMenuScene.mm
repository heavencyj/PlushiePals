//
//  MainMenuScene.m
//  Plushy
//
//  Created by Heaven Chen on 2/11/13.
//
//

#import "MainMenuScene.h"
#import "ModeMenuScene.h"

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
    
    CCMenuItemImage *puzzleButton = [CCMenuItemImage
                                    itemWithNormalImage:@"Plushy Puzzle button.png"
                                    selectedImage:@"Plushy Puzzle button.png"
                                    target:self
                                    selector:@selector(chooseMode:)];
    puzzleButton.position = ccp(-winSize.width/5,-winSize.height/10);
    puzzleButton.tag = 1;
    
    CCMenuItemImage *runButton = [CCMenuItemImage
                                    itemWithNormalImage:@"Plushy Run button.png"
                                    selectedImage:@"Plushy Run button.png"
                                    target:self
                                    selector:@selector(chooseMode:)];
    runButton.position = ccp(winSize.width/5,-winSize.height/10);
    runButton.tag = 2;
    
    CCMenu *menu = [CCMenu menuWithItems: puzzleButton, runButton, nil];
    [menuLayer addChild: menu];
    
    
  }
  return self;
}

- (void) chooseMode: (id) sender
{
  //CCMenuItemImage *button = (CCMenuItemImage *)sender;
  //NSLog(@"%d", button.tag);
  [[CCDirector sharedDirector] replaceScene:[ModeMenuScene scene]];
}

- (void) dealloc
{
  
  [super dealloc];
}
@end