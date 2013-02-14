//
//  ModeMenuScene.m
//  Plushy
//
//  Created by Heaven Chen on 2/13/13.
//

#import "ModeMenuScene.h"
#import "ActionLayer.h"

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
    
    CCMenuItemImage *startButton = [CCMenuItemImage
                                     itemWithNormalImage:@"Play.png"
                                     selectedImage:@"Plays selected.png"
                                     target:self
                                     selector:@selector(startGame:)];
    //puzzleButton.position = ccp(-winSize.width/5,-winSize.height/6);
    
    
    CCMenu *menu = [CCMenu menuWithItems: startButton, nil];
    [menuLayer addChild: menu];
    
    
  }
  return self;
}

- (void) startGame: (id) sender
{
  // Based on mode, the game is different
  [[CCDirector sharedDirector] replaceScene:[ActionLayer scene]];
}

- (void) dealloc
{
  
  [super dealloc];
}
@end