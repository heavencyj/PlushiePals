//
//  MainMenuScene.m
//  Plushy
//
//  Created by Heaven Chen on 2/11/13.
//
//

#import "MainMenuScene.h"
#import "GameScene.h"
#import "LevelMenuScene.h"
#import "TutorialScene.h"

#define DIST 25

@implementation MainMenuScene
bool mute;
bool tipsOn;
bool showTools;
CCMenuItemImage *sound;
CCMenuItemImage *tips;
CCMenuItemImage *tool;
CCLayer *settingLayer;

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
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"Plushy Run.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:background];
    
    //    CCSprite *centerImage = [CCSprite spriteWithFile:@"Plushy Run.png"];
    //    centerImage.position = ccp(winSize.width/2, winSize.height/2);
    //    [background addChild:centerImage];
    mute=NO;
    tipsOn=YES;
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [self addChild:menuLayer];
    
    CCMenuItemImage *play = [CCMenuItemImage
                             itemWithNormalImage:@"Play word icon.png"
                             selectedImage:nil
                             target:self
                             selector:@selector(goToLevel)];
    play.position = ccp(0,-winSize.width/4);
    
    
    sound = [CCMenuItemImage itemWithTarget:self selector:@selector(turnMute)];
    [self turnMute];
    sound.position = ccp(-winSize.width/2.5,-winSize.width/5+2*DIST+sound.contentSize.height);
    sound.visible = NO;
    
    tips = [CCMenuItemImage itemWithTarget:self selector:@selector(turnTips)];
    [self turnTips];
    tips.position = ccp(-winSize.width/2.5,-winSize.width/5+DIST + sound.contentSize.height/2);
    tips.visible = NO;
    
    tool = [CCMenuItemImage
            itemWithNormalImage:@"Tool icon.png"
            selectedImage:nil
            target:self
            selector:@selector(showSetting)];
    tool.position = ccp(-winSize.width/2.5,-winSize.width/5);
    tool.tag = 1;
    
    settingLayer = [CCLayerColor layerWithColor:ccc4(245, 148, 36, 100)
                                          width:tool.contentSize.width
                                         height:tool.contentSize.height+2*DIST];
    settingLayer.position = ccp(winSize.width/2-winSize.width/2.5-tool.contentSize.width/2,
                                winSize.height/2-winSize.width/5);
    settingLayer.visible = NO;
    
    CCMenu *menu = [CCMenu menuWithItems: play, sound, tips, tool, nil];
    [menuLayer addChild:settingLayer];
    [menuLayer addChild: menu];
  }
  return self;
}

- (void)goToLevel {
  
  [[CCDirector sharedDirector] replaceScene:[LevelMenuScene scene]];
  
}

-(void)showSetting
{
  if (tool.tag > 0) {
    sound.visible = YES;
    tips.visible = YES;
    settingLayer.visible = YES;
    tool.tag = -1;
  }
  else {
    sound.visible = NO;
    tips.visible = NO;
    settingLayer.visible = NO;
    tool.tag = 1;
  }
}

-(void)turnMute
{
  if (mute) {
    [sound setNormalImage:[CCSprite spriteWithFile:@"Mute icon.png"]];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
  }
  else {
    [sound setNormalImage:[CCSprite spriteWithFile:@"Sound icon.png"]];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Luscious Swirl 60.mp3" loop:true];
  }
  mute = !mute;
}

-(void)turnTips
{
  if (tipsOn) {
    [tips setNormalImage:[CCSprite spriteWithFile:@"Question icon.png"]];
  }
  else {
    [tips setNormalImage:[CCSprite spriteWithFile:@"Question cancel icon.png"]];
  }
  tipsOn = !tipsOn;
}

- (void) dealloc
{
  
  [super dealloc];
}
@end