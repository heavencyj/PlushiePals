//
//  RunningGameScene.h
//  CollisionTest
//
//  Created by Heaven Chen on 4/1/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SimpleAudioEngine.h"
#import "Maze.h"
#import "GameScene.h"
#import "GB2Sprite.h"
#import "GB2DebugDrawLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"
#import "CCCustomFollow.h"

// Interface for difference scenes
#import "GameOverScene.h"
#import "MainMenuScene.h"
#import "Hud.h"
#import "BackgroundScene.h"
#import "MazeLayer.h"
#import "PauseLayer.h"

//#import "PauseLayer.h"
// Interface for different objects
#import "Plushy.h"
#import "Object.h"
#import "TransitionObject.h"

@class Hud;
@class Plushy;
@class Object;
@class PauseLayer;

// Game Scene
@interface RunningGameScene : GameScene
{
    TransitionObject *initialBridge;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(void)addScore:(int)points;
-(void)revealMazeLayer;
-(void)loadMazeLayer;
@end
