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
#import "RunningGameScene.h"
#import "GameData.h"

NSDictionary *easyMapsDictionary;
NSDictionary *midMapsDictionary;
NSDictionary *midHardMapsDictionary;
NSDictionary *hardMapsDictionary;
NSDictionary *difficultyDictionary;

@implementation MazeLayer

@synthesize bridge;

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

+(void)initMapDictionaries
{
    easyMapsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSValue valueWithCGPoint:CGPointMake(1, 0)], [NSNumber numberWithDouble:0.40],
                          [NSValue valueWithCGPoint:CGPointMake(2, 0)], [NSNumber numberWithDouble:0.25],
                          [NSValue valueWithCGPoint:CGPointMake(4, 0)], [NSNumber numberWithDouble:0.27],
                          [NSValue valueWithCGPoint:CGPointMake(5, 0)], [NSNumber numberWithDouble:0.08],
                          nil];
    
    midMapsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSValue valueWithCGPoint:CGPointMake(1, 1)], [NSNumber numberWithDouble:0.35],
                         [NSValue valueWithCGPoint:CGPointMake(2, 1)], [NSNumber numberWithDouble:0.30],
                         [NSValue valueWithCGPoint:CGPointMake(7, 0)], [NSNumber numberWithDouble:0.15],
                         [NSValue valueWithCGPoint:CGPointMake(5, 1)], [NSNumber numberWithDouble:0.20],
                         nil];
    
    midHardMapsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSValue valueWithCGPoint:CGPointMake(8, 0)], [NSNumber numberWithDouble:0.34],
                             [NSValue valueWithCGPoint:CGPointMake(10, 0)], [NSNumber numberWithDouble:0.10],
                             [NSValue valueWithCGPoint:CGPointMake(4, 1)], [NSNumber numberWithDouble:0.36],
                             [NSValue valueWithCGPoint:CGPointMake(5, 1)], [NSNumber numberWithDouble:0.20], nil];
    
    hardMapsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSValue valueWithCGPoint:CGPointMake(8, 2)], [NSNumber numberWithDouble:0.20],
                          [NSValue valueWithCGPoint:CGPointMake(10, 2)], [NSNumber numberWithDouble:0.10],
                          [NSValue valueWithCGPoint:CGPointMake(5, 2)], [NSNumber numberWithDouble:0.33],
                          [NSValue valueWithCGPoint:CGPointMake(7, 1)], [NSNumber numberWithDouble:0.37], nil];
    
    difficultyDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                            easyMapsDictionary, [NSNumber numberWithDouble:0.40],
                            midMapsDictionary, [NSNumber numberWithDouble:0.35],
                            midHardMapsDictionary, [NSNumber numberWithDouble:0.23],
                            hardMapsDictionary, [NSNumber numberWithDouble:0.02], nil];
}

// Returns the level and the number of game objects to add
-(CGPoint)levelChooser:(int)mapCount
{
    
    //return easyMaps[[GameScene getRandomNumberBetweenMin:0 andMax:0]];
    CGPoint levelInfo;
    
    // For tutorial map
    if ([MainMenuScene showFirst]) {
        [MainMenuScene setFirst:false];
        return CGPointMake(1, 0);
    }
    else
        [MainMenuScene setTips:false];
    
    // Ensure that the first 4 maps are always easy
    if (mapCount < 6) {
        levelInfo = [(NSValue*)[MazeLayer selectDifficulty:[GameScene getRandomDouble] withDict:easyMapsDictionary] CGPointValue];
    }
    else{
        double dif = [GameScene getRandomDouble];
        NSDictionary *dict = (NSDictionary*)[MazeLayer selectDifficulty:dif withDict:difficultyDictionary];
        CCLOG(@"Selected difficulty dictionary %f", dif);
        dif = [GameScene getRandomDouble];
        levelInfo = [(NSValue*)[MazeLayer selectDifficulty:dif withDict:dict] CGPointValue];
        CCLOG(@"Selected map %f", dif);
    }
    
    return levelInfo;
}

+(id)selectDifficulty:(double)rand withDict:(NSDictionary*)dict
{
    double counter = 0;
    for (NSNumber *key in dict) {
        counter += [key doubleValue];
        if (rand <= counter) {
            return [dict objectForKey:key];
        }
    }
    return nil;
}

-(void) loadMaze:(int)level withObject:(int)ObjCount {
    CCLOG(@"Current level is %d", level);
    
    NSString *themeName;
    int gameObjectType;
    switch ([GameData sharedGameData].mapTheme) {
        case 1: {
            themeName = [@"canyon level " stringByAppendingFormat:@"%d", level];
            gameObjectType = CACTUS_BOMB;
            break;
        }
        case 2: {
            themeName =  [@"mt level " stringByAppendingFormat:@"%d", level];
            gameObjectType = ROCK_BOMB;
            break;
        }
        case 5: {
            themeName =  [@"jungle level " stringByAppendingFormat:@"%d", level];
            gameObjectType = MUSHROOM_BOMB;
            break;
        }  
        default:
            break;
    }
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[themeName stringByAppendingString:@".plist"]];
    NSString *shape = [NSString stringWithFormat:@"canyon level %d", level];
    maze = [Maze mazeSprite:shape spriteName:[themeName stringByAppendingString:@".png"]];
    
    [maze setMazeBodySensor:YES];
    
    NSDictionary* transitionBridge = [[dictionary objectForKey:@"bridge"] objectForKey:[NSString stringWithFormat:@"%d", level]];
    NSNumber* load_x = [transitionBridge objectForKey:@"loadx"];
    NSNumber* load_y = [transitionBridge objectForKey:@"loady"];
    [maze setPhysicsPosition:b2Vec2FromCC([load_x intValue], [load_y intValue])]; //Fixed location.
    
    // load in game objects
    [self loadTransitionBridge:level];
    [self loadGameObjects:level withType:gameObjectType withNumObjects:ObjCount];
    
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

-(void)loadGameObjects:(int)level withType:(int)objType withNumObjects:(int)objCount
{
	NSDictionary* cactus = [[dictionary objectForKey:@"cactus bombs"] objectForKey:[NSString stringWithFormat:@"%d", level]];
	[self processLevelFileFromDictionary:cactus withObjectType:objType withObjCount:objCount];
}

-(void) processLevelFileFromDictionary:(NSDictionary*)dict withObjectType:(int)object withObjCount:(int)objCount
{
    if (nil==dict) {
        return;
    }
    int counter = 0;
    //TODO: randomly select between 0-2 cactuses to select from each level 
    for (id key in dict) {
        if (counter >= objCount) {
            return;
        }
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
        
        counter += 1;
    }
}

-(void)lineUpAround:(CGPoint)pos
{
    CCLOG(@"Placing new maze at: (%f, %f)", pos.x, pos.y);
    [maze setPhysicsPosition:b2Vec2FromCC(594, pos.y-30)]; //Numbers set
    [maze setMazeBodySensor:NO];
    [bridge setBridgeBodySensor:NO];
    [maze setLinearVelocity:b2Vec2(MAZESPEED,0)];
    self.visible = YES;
}

-(void)destroyBridgeJoint
{
    b2JointEdge *jointEdge = [bridge getBody]->GetJointList();
    [[GB2Engine sharedInstance] world]->DestroyJoint(jointEdge->joint);
}

-(void)stop{
    [maze setLinearVelocity:b2Vec2FromCC(0, 0)];
}

-(void)reset 
{
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

- (void) dealloc
{
	[super dealloc];
}
@end
