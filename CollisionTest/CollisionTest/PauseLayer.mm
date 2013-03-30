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
#import "MainMenuScene.h"
#import "LevelMenuScene.h"

@implementation PauseLayer

-(id) initWithHud:(GameScene*)game
{
    if( (self=[super init]))
    {
        gameScene = game;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayer *colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 210) width:400 height:200];
        colorLayer.position = ccp(winSize.width/2-colorLayer.contentSize.width/2,
                                  winSize.height/2-colorLayer.contentSize.height/2);
        
        CCMenuItemImage *resume = [CCMenuItemImage
                                   itemWithNormalImage:@"Play icon large.png"
                                   selectedImage:nil
                                   target:self
                                   selector:@selector(resumeGame)];
        resume.position = ccp(0, winSize.height/10);
        
        CCMenuItemImage *restart = [CCMenuItemImage
                                    itemWithNormalImage:@"Return icon.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(restartGame)];
        restart.position = ccp(-winSize.width/5,-winSize.height/7);
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(0,-winSize.height/7);
        
        CCMenuItemImage *level = [CCMenuItemImage
                                  itemWithNormalImage:@"Levels icon.png"
                                  selectedImage:nil
                                  target:self
                                  selector:@selector(goLevels)];
        level.position = ccp(winSize.width/5,-winSize.height/7);
        
        
        CCMenu *menu =  [CCMenu menuWithItems: resume, restart, home, level, nil];
        [self addChild:colorLayer];
        [self addChild:menu];
        self.visible = NO;
    }
    return self;
}

-(void)pauseLayerVisible:(BOOL)visibility
{
    self.visible = visibility;
}

-(void)resumeGame
{
    self.visible = NO;
    gameScene.hud.pauseButton.visible = YES;
    [gameScene resumeSchedulerAndActions];
    [[CCDirector sharedDirector] resume];
}

-(void)pauseGame
{
    [gameScene pauseSchedulerAndActions];
    [[CCDirector sharedDirector] pause];
    gameScene.hud.pauseButton.visible = NO;
}

-(void)restartGame
{
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    [[CCDirector sharedDirector] resume];
}

- (void)goHome
{
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
}

-(void)goLevels
{
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[LevelMenuScene scene]];
}


@end
