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

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate,UIGestureRecognizerDelegate>
{
  CCSprite *_plushy;
  CCParallaxNode *_backgroundNode;
  CCSprite *_cloud1;
  CCSprite *_cloud2;
  CCSprite *_canyons;
  
  CCArray *_mazes;
  int _nextMaze;
  double _nextMazeSpawn;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end