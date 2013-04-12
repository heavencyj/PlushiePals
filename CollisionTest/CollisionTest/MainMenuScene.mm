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

#define DIST 25

@implementation MainMenuScene
bool mute;
bool tipsOn;
bool showTools;
bool testMode;
bool first;
CCMenuItemImage *sound;
CCMenuItemImage *tips;
CCMenuItemImage *tool;
CCMenuItemImage *test;
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
        
        //    CCSprite *centerImage = [CCSprite spriteWithFile:@"main menu image.png"];
        //    centerImage.position = ccp(winSize.width/2, winSize.height/1.7);
        //    [background addChild:centerImage];
        mute=YES;
        tipsOn=NO;
        //testMode = YES;
        first = YES;
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *play = [CCMenuItemImage
                                 itemWithNormalImage:@"Play word icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(hitPlay)];
        play.position = ccp(0,-winSize.height/2.8);
        
//        test = [CCMenuItemImage itemWithTarget:self selector:@selector(turnTest)];
//        [self turnTest];
//        test.position = ccp(-winSize.width/2.5,-winSize.width/5+3*DIST + test.contentSize.height*1.5);
//        test.visible = NO;
        
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
        
        plushies = [CCMenuItemImage
                itemWithNormalImage:@"Plushy icon.png"
                selectedImage:nil
                target:self
                selector:@selector(showPlushy)];
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
    
    if (testMode) {
        [[CCDirector sharedDirector] replaceScene:[LevelMenuScene scene]];
    }
    else {
        // start the infinite running game
        [[CCDirector sharedDirector] replaceScene:[RunningGameScene scene]];
        [[CCDirector sharedDirector] resume];
    }
}

-(void)showSetting
{
    if (tool.tag > 0) {
        sound.visible = YES;
        tips.visible = YES;
        test.visible = YES;
        settingLayer.visible = YES;
        tool.tag = -1;
    }
    else {
        sound.visible = NO;
        tips.visible = NO;
        test.visible = NO;
        settingLayer.visible = NO;
        tool.tag = 1;
    }
}

-(void)showPlushy
{
    [[CCDirector sharedDirector] replaceScene:[PlushyMenuScene scene]];
}

-(void)turnMute
{
    if (mute) {
        [sound setNormalImage:[CCSprite spriteWithFile:@"Mute icon.png"]];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
    else {
        [sound setNormalImage:[CCSprite spriteWithFile:@"Sound icon.png"]];
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Luscious Swirl 60.mp3" loop:true];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"PlushyParadiseTheme.mp3" loop:true];
    }
    mute = !mute;
}

-(void)turnTips
{
    if (tipsOn) {
        [tips setNormalImage:[CCSprite spriteWithFile:@"Question cancel icon.png"]];
    }
    else {
        [tips setNormalImage:[CCSprite spriteWithFile:@"Question icon.png"]];
    }
    tipsOn = !tipsOn;
}

-(void)turnTest
{
    if (testMode) {
        [test setNormalImage:[CCSprite spriteWithFile:@"Beta cancel icon.png"]];
    }
    else {
        [test setNormalImage:[CCSprite spriteWithFile:@"Beta icon.png"]];
    }
    testMode = !testMode;
}


+(bool)showTips{
    return tipsOn;
}

+(bool)isTestMode
{
    return testMode;
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