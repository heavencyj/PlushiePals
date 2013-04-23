//
//  HelloWorldLayer.h
//
//  Created by Lan Li on 1/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//
#import "GB2DebugDrawLayer.h"

@class Plushy;
@class Hud;
@class MazeLayer;
@class Object;
@class PauseLayer;

// Game Scene
@interface GameScene : CCLayer 
{
    
    //Box2D
    GLESDebugDraw *_debugDraw;
    CCAction *_walking;
    
    Plushy *plushy;
    Hud *hud;
    PauseLayer *pauseLayer;
    CCSpriteBatchNode *plushyLayer;
    
    //int score;
    int showingTip1;
    float plushySpeed;
    int speedDelay;
    int scoreDelay;
    int cameraDelay;
    int seconds;

    // Variables for dropping objects on the screen
    ccTime nextObject;
    ccTime objDelay;
    Object *obj;
    
    // touch input
    CGPoint firstTouch;
    CGPoint lastTouch;
    
    CCSprite *dummyMaze;
    MazeLayer *currMazeLayer;
}

@property (readonly) Hud *hud;
@property (readonly) MazeLayer *currMazeLayer;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// returns the scene with a specific level
+(CCScene *) scene:(int)withLevel;
+(int) getRandomNumberBetweenMin:(int)min andMax:(int)max;
+ (double) getRandomDouble;

-(void)setPlushyIsDead:(BOOL)d;
- (void)setInvisible:(CCNode *)node;
- (void)setNodeVisible:(CCNode *)node;
-(void)nextObject:(ccTime)dt pattern:(int)p;
@end
