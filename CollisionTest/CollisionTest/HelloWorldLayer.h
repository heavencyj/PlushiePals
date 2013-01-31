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

@class Monkey;
@class Floor;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate,UIGestureRecognizerDelegate>
{
    CCSprite *_background;
    CCSprite *_cloud1;
    CCSprite *_cloud2;
    CCSprite *_canyons;
    CCSprite *_canyons2;
    CCSpriteBatchNode* _objectLayer;
    CCSprite *_canyonunit;
    
    CCParallaxNode *_backgroundNode;
    CCParallaxNode *_obstacleNode;
    
    Monkey *_monkey;
    //Floor *_mazeObj;
    
    CCArray *_mazes;
    int _nextMaze;
    double _nextMazeSpawn;
    
    //Box2D
    b2World *_world;
    GLESDebugDraw *_debugDraw;
    MyContactListener *_contactListener;
    CCAction *_walking;
}

@property (nonatomic, retain) CCSpriteBatchNode *objectLayer;
@property (nonatomic, retain) CCAction *walkAction;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
