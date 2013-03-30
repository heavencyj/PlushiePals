//
//  PauseLayer.h
//  CollisionTest
//
//  Created by Lan Li on 3/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Hud;
@class GameScene;
@interface PauseLayer : CCLayer {
    GameScene* gameScene;
}
-(id) initWithHud:(GameScene*)game;
-(void)pauseLayerVisible:(BOOL)visibility;
-(void)resumeGame; //TODO: is this even needed
-(void)pauseGame;
@end
