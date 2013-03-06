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

// Game Scene
@interface GameScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate,UIGestureRecognizerDelegate>
{
    
    //Box2D
    b2World *_world;
    GLESDebugDraw *_debugDraw;
    MyContactListener *_contactListener;
    CCAction *_walking;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// returns the scene with a specific level
+(CCScene *) scene:(int)withLevel;
@end
