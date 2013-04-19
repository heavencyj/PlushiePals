//
//  MazeLayer.m
//  CollisionTest
//
//  Created by Lan Li on 4/7/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MazeLayer.h"
#import "GameScene.h"
#import "MainMenuScene.h"

NSInteger easyMaps[8];
NSInteger midMaps[3];
NSInteger hardMaps[3];

@implementation MazeLayer

-(id)init
{
    if((self = [super init]))
    {
        path = [[NSBundle mainBundle] pathForResource:@"GameObjects" ofType:@"plist" inDirectory:@""];
        
        NSAssert(nil!=path, @"Invalid GameObjects file.");
        
        dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        gameObjects = [[NSMutableArray alloc] init];
        
        self.visible = NO;
    }
    return self;
}

// Initialize the map levels
+(void)initMapLevels
{
    //Maze 3 has issues
    easyMaps[0] = 1;
    easyMaps[1] = 2;
    easyMaps[2] = 4;
    easyMaps[3] = 5;
    easyMaps[4] = 5;
    easyMaps[5] = 6;
    easyMaps[6] = 7;
    easyMaps[7] = 8;
//    easyMaps[4] = 5
//    easyMaps[0] = 1;
//    easyMaps[1] = 2;
//    easyMaps[2] = 6;
//    easyMaps[3] = 9;
    midMaps[0] = 4;
    midMaps[1] = 5;
    midMaps[2] = 7;
    hardMaps[0] = 3;
    hardMaps[1] = 8;
    hardMaps[2] = 10;
}

-(int)levelChooser
{
    return easyMaps[[GameScene getRandomNumberBetweenMin:0 andMax:0]];
    //TODO: the first map has to be canyon level 1
    
//    if ([MainMenuScene showFirst]) {
//        [MainMenuScene setFirst:false];
//        return  1;
//    }
//    else {
//        [MainMenuScene setTips:false];
//        return easyMaps[[GameScene getRandomNumberBetweenMin:0 andMax:4]];
//    }
    
//    if (mapCount < 5) {
//        if ([self getRandomDouble] < diffFactor) {
//            return easyMaps[[GameScene getRandomNumberBetweenMin:0 andMax:2]];
//        }
//        else return midMaps[[GameScene getRandomNumberBetweenMin:0 andMax:2]];
//    }
//    else {
//        if ([GameScene getRandomDouble] < diffFactor) {
//            return hardMaps[[GameScene getRandomNumberBetweenMin:0 andMax:2]];
//        }
//        else return midMaps[[GameScene getRandomNumberBetweenMin:0 andMax:2]];
//    }
}

-(void) loadMaze:(int)ofLevel {
    CCLOG(@"Current level is %d", ofLevel);
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[@"canyon level " stringByAppendingFormat:@"%d.plist", ofLevel]];
    NSString *shape = [@"canyon level " stringByAppendingFormat:@"%d", ofLevel];
    maze = [Maze mazeSprite:shape spriteName:[shape stringByAppendingString:@".png"]];
    
    [maze setMazeBodySensor:YES];
    
    NSDictionary* transitionBridge = [[dictionary objectForKey:@"bridge"] objectForKey:[NSString stringWithFormat:@"%d", ofLevel]];
    NSNumber* load_x = [transitionBridge objectForKey:@"loadx"];
    NSNumber* load_y = [transitionBridge objectForKey:@"loady"];
    [maze setPhysicsPosition:b2Vec2FromCC([load_x intValue], [load_y intValue])]; //Fixed location.
    
    // load in game objects
    [self loadTransitionBridge:ofLevel];
    [self loadGameObjects:ofLevel];
    
    [self addChild:[maze ccNode] z:40];
}

///////////////////////// loading game objects
-(void)loadTransitionBridge:(int)level
{
    //TODO: bridge must be treated differently
	NSDictionary* transitionBridge = [[dictionary objectForKey:@"bridge"] objectForKey:[NSString stringWithFormat:@"%d", level]];
    NSNumber* pos_x = [transitionBridge objectForKey:@"x"];
    NSNumber* pos_y = [transitionBridge objectForKey:@"y"];
    CGPoint position = ccp([pos_x intValue],[pos_y intValue]);
    NSNumber* rot = [transitionBridge objectForKey:@"r"];
    
    bridge = [TransitionObject transitionObjectSprite];
    [self addChild:[bridge ccNode] z:30];
    [bridge getBody]->SetTransform(b2Vec2FromCC(position.x, position.y), CC_DEGREES_TO_RADIANS([rot intValue]));
    
    // create weld joint
    b2WeldJointDef weldJointDef;
    weldJointDef.Initialize([maze getBody], [bridge getBody], [bridge getBody]->GetWorldCenter());
    [GB2Engine sharedInstance].world->CreateJoint(&weldJointDef);
    
    [bridge setBridgeBodySensor:YES];
    [bridge setVisible:NO];
}

-(void)loadGameObjects:(int)level
{
	NSDictionary* cactus = [[dictionary objectForKey:@"cactus bombs"] objectForKey:[NSString stringWithFormat:@"%d", level]];
	[self processLevelFileFromDictionary:cactus withObjectType:CACTUS_BOMB];
}

-(void) processLevelFileFromDictionary:(NSDictionary*)dict withObjectType:(int)object
{
    if (nil==dict) {
        return;
    }
    
    //TODO: randomly select between 0-2 cactuses to select from each level 
    for (id key in dict) {
        NSDictionary* gameObj = [dict objectForKey:key];
        
        NSNumber* pos_x = [gameObj objectForKey:@"x"];
        NSNumber* pos_y = [gameObj objectForKey:@"y"];
        CGPoint position = ccp([pos_x intValue],[pos_y intValue]);
        NSNumber* rot = [gameObj objectForKey:@"r"];
        
        // create game object
        Object *item = [Object randomObject:object];
        [gameObjects addObject:item];
        [self addChild:[item ccNode] z:30];
        [item getBody]->SetTransform(b2Vec2FromCC(position.x, position.y), CC_DEGREES_TO_RADIANS([rot intValue]));
        
        // create weld joint
        b2WeldJointDef weldJointDef;
        weldJointDef.Initialize([maze getBody], [item getBody], [item getBody]->GetWorldCenter());
        [GB2Engine sharedInstance].world->CreateJoint(&weldJointDef);
        
//        [item setSensor:YES];
//        [item setVisible:NO];
    }
}

-(void)lineUpAround:(CGPoint)pos
{
    CCLOG(@"Placing new maze at: (%f, %f)", pos.x, pos.y);
    [maze setPhysicsPosition:b2Vec2FromCC(463, pos.y-30)]; //Numbers set
    [maze setMazeBodySensor:NO];
    [bridge setBridgeBodySensor:NO];
    [maze setLinearVelocity:b2Vec2(MAZESPEED,0)];
    self.visible = YES;
    
    //Set all game objects to be visible at this time and unsensor them
//    for (Object *obj in gameObjects) {
//        [obj setSensor:NO];
//        [obj setVisible:YES];
//    }
}

-(void)destroyBridgeJoint
{
    b2JointEdge *jointEdge = [bridge getBody]->GetJointList();
    [[GB2Engine sharedInstance] world]->DestroyJoint(jointEdge->joint);
}

-(void)stop{
    [maze setLinearVelocity:b2Vec2FromCC(0, 0)];
}

-(void)reset //TODO:
{
//            [maze setSensor:TRUE];
//            [plushy resetPlushyPosition];
//            [maze setSensor:FALSE];
    [maze setTransform:b2Vec2FromCC(100,120) angle:CC_DEGREES_TO_RADIANS(0)];
}

-(void) setBridgeBody:(b2BodyType)type
{
    b2JointEdge *jointEdge = [bridge getBody]->GetJointList();
    [[GB2Engine sharedInstance] world]->DestroyJoint(jointEdge->joint);
    [bridge getBody]->SetType(type);
    [bridge setLinearVelocity:b2Vec2(MAZESPEED, 0)];
}

-(void) showBridge
{
    [bridge setVisible:YES];
}

-(void)transformAround:(CGPoint)pos WithAngle:(float)theta
{
    CGPoint oldp = [maze ccNode].position;
    CGPoint newp = [self rotate:-1*CC_DEGREES_TO_RADIANS(theta) of:oldp around:pos];
    [maze transform:b2Vec2FromCGPoint(newp) withAngle:theta];
}

-(CGPoint)rotate:(float)theta of:(CGPoint)pos around:(CGPoint)origin
{
    float newx = cos(theta) * (pos.x-origin.x) - sin(theta) * (pos.y-origin.y) + origin.x;
    float newy = sin(theta) * (pos.x-origin.x) + cos(theta) * (pos.y-origin.y) + origin.y;
    
    return CGPointMake(newx,newy);
}

@end
