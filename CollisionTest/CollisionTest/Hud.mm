//
//  Hud.m
//  CollisionTest
//
//  Created by Lan Li on 3/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Hud.h"
#import "CCNode+SFGestureRecognizers.h"
#import "GB2Sprite.h"
#import "GameScene.h"
#import "MainMenuScene.h"

@implementation Hud

@synthesize pauseButton;
@synthesize pauseButtonRect;
-(id) init
{
    if( (self=[super init]))
    {
        // Pause button
        pauseButton = [CCSprite spriteWithFile:@"Pause icon.png"];
        pauseButton.position = ccp(30,30);
        pauseButtonRect = CGRectMake((pauseButton.position.x-(pauseButton.contentSize.width)/2), (pauseButton.position.y-(pauseButton.contentSize.height)/2), (pauseButton.contentSize.width), (pauseButton.contentSize.height));
        [self addChild:pauseButton z:5000];
        [self addPauseLayer];
        
        // points
        CCSprite *bananaPoints = [CCSprite spriteWithFile:@"banana single.png"];
        CCSprite *mult = [CCLabelTTF labelWithString:@"X"
                                            fontName:@"GROBOLD"
                                            fontSize:30];
        bananaPoints.position = ccp(20, 290);
        mult.position = ccp(55, 290);
        mult.color=ccc3(245, 148, 36);
        [self addChild:bananaPoints z:50];
        [self addChild:mult z:50];
        
        scoreDelay = 10;
        scoreLabel = [CCLabelTTF labelWithString:@"0"
                                        fontName:@"GROBOLD"
                                        fontSize:40];
        scoreLabel.color = ccc3(245, 148, 36);
        scoreLabel.position = ccp(95,290);
        [self addChild:scoreLabel z:50];
    }
    
    return self;
}

-(void)addPauseLayer
{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    pauseLayer = [[[CCLayer alloc] init] autorelease];
    [self addChild:pauseLayer z:1000];
    
    CCLayer *colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 210) width:400 height:200];
    colorLayer.position = ccp(winSize.width/2-colorLayer.contentSize.width/2,
                              winSize.height/2-colorLayer.contentSize.height/2);
    
    CCMenuItemImage *resume = [CCMenuItemImage
                               itemWithNormalImage:@"Play icon.png"
                               selectedImage:nil
                               target:self
                               selector:@selector(resumeGame)];
    resume.position = ccp(-winSize.width/5,0);
    
    CCMenuItemImage *restart = [CCMenuItemImage
                                itemWithNormalImage:@"Return icon.png"
                                selectedImage:nil
                                target:self
                                selector:@selector(restartGame)];
    restart.position = ccp(0,0);
    
    CCMenuItemImage *home = [CCMenuItemImage
                             itemWithNormalImage:@"Home icon.png"
                             selectedImage:nil
                             target:self
                             selector:@selector(goHome)];
    home.position = ccp(winSize.width/5,0);
    
    
    CCMenu *menu =  [CCMenu menuWithItems: resume, restart, home, nil];
    [pauseLayer addChild:colorLayer];
    [pauseLayer addChild:menu];
    pauseLayer.visible = NO;
    
}

-(void)pauseLayerVisible:(BOOL)visibility
{
    pauseLayer.visible = visibility;
}

-(void)resumeGame
{
    pauseLayer.visible = NO;
    pauseButton.visible = YES;
    [self resumeSchedulerAndActions];
    [[CCDirector sharedDirector] resume];
}

-(void)updateBananaScore:(int)score
{
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
}

-(void)pauseGame
{
    [self pauseSchedulerAndActions];
    [[CCDirector sharedDirector] pause];
    pauseButton.visible = NO;
}

-(void)restartGame
{
//    [self addTapRecognizer];
    pauseLayer.visible = NO;
    pauseButton.visible = YES;
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    [[CCDirector sharedDirector] resume];
}

- (void)goHome {
    
    [[CCDirector sharedDirector] resume];
    [[GB2Engine sharedInstance] deleteAllObjects];
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
}

@end
