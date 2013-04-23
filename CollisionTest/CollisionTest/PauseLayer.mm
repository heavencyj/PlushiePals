//
//  PauseLayer.m
//  CollisionTest
//
//  Created by Lan Li on 3/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PauseLayer.h"
#import "GB2Sprite.h"
#import "Hud.h"
#import "GameScene.h"
#import "RunningGameScene.h"
#import "MainMenuScene.h"
#import "LevelMenuScene.h"
#import "GameData.h"

#define WIDTH 400
#define HEIGHT 200

@implementation PauseLayer

-(id) initWithHud:(GameScene*)game
{
    if( (self=[super init]))
    {
        gameScene = game;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayer *colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 210) width:WIDTH height:HEIGHT];
        colorLayer.position = ccp(winSize.width/2-colorLayer.contentSize.width/2,
                                  winSize.height/2-colorLayer.contentSize.height/2);
        
        CCMenuItemImage *resume = [CCMenuItemImage
                                   itemWithNormalImage:@"Play icon large.png"
                                   selectedImage:nil
                                   target:self
                                   selector:@selector(resumeGame)];
        resume.position = ccp(0, 0);
        
        CCMenuItemImage *restart = [CCMenuItemImage
                                    itemWithNormalImage:@"Return icon.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(restartGame)];
        restart.position = ccp(-winSize.width/5,0);
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(winSize.width/5,0);
        
        CCMenu *menu =  [CCMenu menuWithItems: resume, restart, home, nil];
        [self addChild:colorLayer];
        [self addChild:menu];
        self.visible = NO;
    }
    return self;
}

-(void)setLayerPosition:(CGPoint)pos
{
    self.position = ccp(pos.x-WIDTH/1.5, pos.y-HEIGHT/1.5);
}

-(void)pauseLayerVisible:(BOOL)visibility
{
    self.visible = visibility;
}

-(void)resumeGame
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    self.visible = NO;
    gameScene.hud.pauseButton.visible = YES;
    [gameScene resumeSchedulerAndActions];
    [[CCDirector sharedDirector] resume];
}

-(void)pauseGame
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    [gameScene pauseSchedulerAndActions];
    [[CCDirector sharedDirector] pause];
    gameScene.hud.pauseButton.visible = NO;
}

-(void)restartGame
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[RunningGameScene scene]];
    [[CCDirector sharedDirector] resume];
}

- (void)goHome
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
}


@end
