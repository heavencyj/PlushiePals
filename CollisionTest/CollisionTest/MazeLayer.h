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
    NSMutableArray* gameObjects;
    
    CCSprite *tutorial1;
    TransitionObject *bridge;
    Maze *maze;
}

@property (readonly) TransitionObject *bridge;

-(id)init;
-(void)reset;
-(void)transformAround:(CGPoint)pos WithAngle:(float)theta;
-(void)stop;
-(void)lineUpAround:(CGPoint)pos;
-(CGPoint)levelChooser:(int)mapCount;
-(void) loadMaze:(int)level withObject:(int)ObjCount;
-(void) setBridgeBody:(b2BodyType)type;
-(void)destroyBridgeJoint;
-(void) showBridge;
+(void)initMapDictionaries;
@end
