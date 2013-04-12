//
//  IntroLayer.m
//  CollisionTest
//
//  Created by Lan Li on 1/23/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "GameScene.h"
#import "MainMenuScene.h"

#define ANIM_DELAY 0.25f

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"monkeys.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"monkeys.png"];
    [self addChild:spriteSheet z:50];

	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Loading screen.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        // add the label as a child to this Layer
        [self addChild: background z:10];
        
        NSMutableArray *runAnimFrames = [NSMutableArray array];
        for (int i=1; i<=4; i++) {
            [runAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Monkey run %d.png",i]]];
        }
        CCAnimation *runAnim = [CCAnimation
                                 animationWithSpriteFrames:runAnimFrames delay:0.2f];
        

        CCSprite *monkey = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
        monkey.position = ccp(winSize.width/2, winSize.height*0.6);
        CCAction *runAction = [CCRepeatForever actionWithAction:
                           [CCAnimate actionWithAnimation:runAnim]];
        [monkey runAction:runAction];
        [spriteSheet addChild:monkey];
        
	} else {
		//background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}

	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:2];
}

-(void) makeTransition:(ccTime)dt
{
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0 scene:[HelloWorldLayer scene]]];
  [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0 scene:[MainMenuScene scene]]];

}
@end
