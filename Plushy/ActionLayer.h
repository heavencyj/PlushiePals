//
//  ActionLayer.h
//  Plushy
//
//  Created by Heaven Chen on 2/10/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelHelperLoader.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface ActionLayer : CCLayer {
  
  LevelHelperLoader *lh;
  b2World *world;
  GLESDebugDraw *debugDraw;
}

+ (id)scene;

@end
