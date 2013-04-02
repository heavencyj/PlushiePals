//
//  HelloWorldLayer.h
//  GestureDemo
//
//  Created by Lan Li on 1/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import "SimpleAudioEngine.h"
#import "Maze.h"

@class Hud;
@class Plushy;
@class Object;
@class PauseLayer;

// Game Scene
@interface GameScene : CCLayer 
{
    
    //Box2D
    GLESDebugDraw *_debugDraw;
    MyContactListener *_contactListener;
    CCAction *_walking;
    
    Maze *maze;
    Hud *hud;
    PauseLayer *pauseLayer;
    
    // Plushy variables
    Plushy *plushy;
    CCSpriteBatchNode *plushyLayer;
    
    //int score;
    float plushySpeed;
    float mazeSpeed;
    // Delay variables to delay certain actions
    int speedDelay;
    int scoreDelay;
    int cameraDelay;
    
    // Variables for dropping objects on the screen
    ccTime nextObject;
    ccTime objDelay;
    Object *obj;
    
    // touch input
    CGPoint firstTouch;
    CGPoint lastTouch;
    
    CCSprite *dummyMaze;
}

@property (readonly) Maze *maze;
@property (readonly) Hud *hud;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// returns the scene with a specific level
+(CCScene *) scene:(int)withLevel;
-(void)setPlushyIsDead:(BOOL)d;
-(void)nextObject:(ccTime)dt pattern:(int)p;
-(void)loadBombFile;
-(void) processLevelFileFromDictionary:(NSDictionary*)dictionary;
-(CGPoint)rotate:(float)theta of:(CGPoint)pos around:(CGPoint)origin;// Add new method
- (void)setInvisible:(CCNode *)node;
- (void)setNodeVisible:(CCNode *)node;
- (double) getRandomDouble;
-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max;

@end
