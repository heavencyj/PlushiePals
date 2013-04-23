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
#import "PlushyMenuScene.h"
#import "RunningGameScene.h"
#import "GameData.h"
#import "MapMenuScene.h"

#define DIST 25

@implementation MainMenuScene
bool mute;
bool tipsOn;
bool showTools;
bool first;
CCMenuItemImage *sound;
CCMenuItemImage *tips;
CCMenuItemImage *tool;
CCMenuItemImage *plushies;
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
        CCSprite *background = [CCSprite spriteWithFile:@"Plushy Paradise.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        mute = [[GameData sharedGameData] mute];
        tipsOn = [[GameData sharedGameData] tips];
        first = YES;
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *play = [CCMenuItemImage
                                 itemWithNormalImage:@"Play word icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(hitPlay)];
        play.position = ccp(0,-winSize.height/2.8);
        
        sound = [CCMenuItemImage itemWithTarget:self selector:@selector(turnMute)];
        [self checkMute];
        sound.position = ccp(-winSize.width/2.5,-winSize.width/5+2*DIST+sound.contentSize.height);
        sound.visible = NO;
        
        tips = [CCMenuItemImage itemWithTarget:self selector:@selector(turnTips)];
        [self checkTips];
        tips.position = ccp(-winSize.width/2.5,-winSize.width/5+DIST + sound.contentSize.height/2);
        tips.visible = NO;
        
        tool = [CCMenuItemImage
                itemWithNormalImage:@"Tool icon.png"
                selectedImage:nil
                target:self
                selector:@selector(showSetting)];
        tool.position = ccp(-winSize.width/2.5,-winSize.width/5);
        tool.tag = 1;        
        
        plushies = [CCMenuItemImage
                itemWithNormalImage:@"Score icon.png"
                selectedImage:nil
                target:self
                selector:@selector(showScore)];
        plushies.position = ccp(winSize.width/2.5,-winSize.width/5);
        
        settingLayer = [CCLayerColor layerWithColor:ccc4(245, 148, 36, 100)
                                              width:tool.contentSize.width
                                             height:tool.contentSize.height+2*DIST];
        settingLayer.position = ccp(winSize.width/2-winSize.width/2.5-tool.contentSize.width/2,
                                    winSize.height/2-winSize.width/5);
        settingLayer.visible = NO;
        
        CCMenu *menu = [CCMenu menuWithItems: play, sound, tips, tool, plushies, nil];
        [menuLayer addChild:settingLayer];
        [menuLayer addChild: menu];
    }
    return self;
}

- (void)hitPlay {
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
//    // start the infinite running game
//    [[CCDirector sharedDirector] replaceScene:[RunningGameScene scene]];
//    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:[MapMenuScene scene]];
    
}

-(void)showSetting
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
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

-(void)showScore
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    [[CCDirector sharedDirector] replaceScene:[PlushyMenuScene scene]];
}

-(void)checkMute{
    if (mute) {
        [sound setNormalImage:[CCSprite spriteWithFile:@"Mute icon.png"]];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0]; //TODO: also can call StopEffect. Keep all effects in an array
    }
    else {
        [sound setNormalImage:[CCSprite spriteWithFile:@"Sound icon.png"]];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"PlushyParadiseTheme.mp3" loop:true];
    }
}

-(void)turnMute
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    mute = !mute;
    [[GameData sharedGameData] setMute:mute];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: [GameData sharedGameData].mute
               forKey:@"mute"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkMute];
}

-(void)checkTips
{
    
    if (tipsOn) {
        [tips setNormalImage:[CCSprite spriteWithFile:@"Question icon.png"]];
    }
    else {
        [tips setNormalImage:[CCSprite spriteWithFile:@"Question cancel icon.png"]];
    }
}

-(void)turnTips
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    tipsOn = !tipsOn;
    [[GameData sharedGameData] setTips:tipsOn];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: [GameData sharedGameData].tips
               forKey:@"tips"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkTips];
}


+(bool)showTips{
    return tipsOn;
}


+(bool)showFirst {
    return first;
}
+(void)setFirst:(bool)on {
    first  = on;
}

+(void)setTips:(bool)on {
    tipsOn = on;
}
- (void) dealloc
{
    
    [super dealloc];
}
@end