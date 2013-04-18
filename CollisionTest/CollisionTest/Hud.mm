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
#import "MainMenuScene.h"
#import "LevelMenuScene.h"

@implementation Hud

@synthesize pauseButton;
@synthesize pauseButtonRect;

-(id) init
{
    if( (self=[super init]))
    {
        // Pause button
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        pauseButton = [CCSprite spriteWithFile:@"Pause icon.png"];
        pauseButton.position = ccp(winSize.width - 30,winSize.height-30);
        pauseButtonRect = CGRectMake((pauseButton.position.x-(pauseButton.contentSize.width)/2), (pauseButton.position.y-(pauseButton.contentSize.height)/2), (pauseButton.contentSize.width), (pauseButton.contentSize.height));
        [self addChild:pauseButton z:5000];
        
//        // points
//        CCSprite *bananaPoints = [CCSprite spriteWithFile:@"banana single.png"];
//        bananaPoints.position = ccp(230, 290);
//        [self addChild:bananaPoints z:50];
    
        scoreCloud = [CCSprite spriteWithFile:@"cloud.png"];
        scoreCloud.position = ccp(280,294);
        [self addChild:scoreCloud z:5000];
        
        scoreLabel = [CCLabelTTF labelWithString:@"0"
                                        fontName:@"GROBOLD"
                                        fontSize:30];
        scoreLabel.color = ccc3(245, 148, 36);
        scoreLabel.position = ccp(280,290);
        [self addChild:scoreLabel z:5001];
    }
    
    return self;
}


-(void)updateScore:(int)score
{
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
}

@end
