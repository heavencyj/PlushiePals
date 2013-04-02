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
#import "MyContactListener.h"
#import "SimpleAudioEngine.h"
#import "Maze.h"
#import "GameScene.h"

@class Hud;
@class Plushy;
@class Object;
@class PauseLayer;

// Game Scene
@interface RunningGameScene : GameScene
{
    
//    //Box2D
//    GLESDebugDraw *_debugDraw;
//    MyContactListener *_contactListener;
//    CCAction *_walking;
//    
//    Maze *maze;
//    Hud *hud;
//    PauseLayer *pauseLayer;
//    
//    // Plushy variables
//    Plushy *plushy;
//    CCSpriteBatchNode *plushyLayer;
//    
//    //int score;
//    float plushySpeed;
//    float mazeSpeed;
//    // Delay variables to delay certain actions
//    int speedDelay;
//    int scoreDelay;
//    int cameraDelay;
//    
//    // Variables for dropping objects on the screen
//    ccTime nextObject;
//    ccTime objDelay;
//    Object *obj;
//    
//    // touch input
//    CGPoint firstTouch;
//    CGPoint lastTouch;
//    
//    CCSprite *dummyMaze;
}
//
//@property (readonly) Maze *maze;
//@property (readonly) Hud *hud;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
@end
