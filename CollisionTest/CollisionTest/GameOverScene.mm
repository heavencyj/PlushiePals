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
@synthesize layer = _layer;
CCSprite *_background;

- (id)init {
  
  if ((self = [super init])) {
    self.layer = [GameOverLayer node];
    [self addChild:_layer];
  }
  return self;
}

- (void)dealloc {
  [_layer release];
  _layer = nil;
  [super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label = _label;

-(id) init
{
  if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _background = [CCSprite spriteWithFile: @"Game Over screen.png"];
    _background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:_background];
    
    self.label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
    _label.color = ccc3(0,0,0);
    _label.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:_label];

    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *home = [CCMenuItemImage
                                     itemWithNormalImage:@"Home button.png"
                                     selectedImage:@"Home button.png"
                                     target:self
                                     selector:@selector(goHome)];
    home.position = ccp(-winSize.width/5,-winSize.height/4);
    
    CCMenuItemImage *restart = [CCMenuItemImage
                                  itemWithNormalImage:@"Restart button.png"
                                  selectedImage:@"Restart button.png"
                                  target:self
                                  selector:@selector(restart)];
    restart.position = ccp(winSize.width/5,-winSize.height/4);
    
    CCMenu *menu = [CCMenu menuWithItems: home, restart, nil];
    [menuLayer addChild: menu];
  }
  return self;
}

-(void)restart
{
  [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}


- (void)goHome {
  
  [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
  
}

- (void)dealloc {
  [_label release];
  _label = nil;
  [super dealloc];
}

@end