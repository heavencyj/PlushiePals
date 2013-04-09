//
//  MazeLayer.h
//  CollisionTest
//
//  Created by Lan Li on 4/7/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TransitionObject.h"
#import "Maze.h"
#import "Object.h"

@interface MazeLayer : CCLayer {
    NSDictionary *dictionary;
    NSString *path;
    
    CCSprite *tutorial1;
    TransitionObject *bridge;
    Maze *maze;
}
+(void)initMapLevels;
-(id)init;
-(void)reset;
-(void)transformAround:(CGPoint)pos WithAngle:(float)theta;
-(void)stop;
-(void)lineUpAround:(CGPoint)pos;
-(int)levelChooser;
-(void) loadMaze:(int)ofLevel;
-(void) setBridgeBody:(b2BodyType)type;
-(void)destroyBridgeJoint;
-(void) showBridge;
@end
