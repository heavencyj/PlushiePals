//
//  HelloWorldLayer.m
//  Cocos2d Test
//
//  Created by Lan Li & Heaven Chen on 1/13/13.
//  Copyright 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCNode+SFGestureRecognizers.h"
#import "GB2Sprite.h"
#import "Monkey.h"
#import "Floor.h"
#import "GB2DebugDrawLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"

#define kNumMazes 15
#define PTM_RATIO 32
#define WALKING_FRAMES 3
#define MAZE_LOW 30

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize objectLayer = _objectLayer;
@synthesize walkAction = _walking;
Monkey *plushy;
int newMaze;
int duration;
int verticalMazeObj;
double nextMazeSpawn;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
	
	// return the scene
	return scene;
}

// On "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	if( (self=[super init]) ) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Adding solid background color
        _background = [CCSprite spriteWithFile: @"Canyon background.png"];
        _background.position = ccp(winSize.width/2, winSize.height/2);
        _background.scale = 1.5;
        [self addChild:_background];
        
        // Loading physics shapes
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"plushyshapes.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"plushypals.plist"];
        
        // 1) Create the CCParallaxNode
        _backgroundNode = [CCParallaxNode node];
        [self addChild:_backgroundNode z:10];
        
        // Create the continuous scrolling background
        _cloud1 = [CCSprite spriteWithFile:@"Canyon cloud 1.png"];
        _cloud2 = [CCSprite spriteWithFile:@"Canyon cloud 2.png"];
        _canyons = [CCSprite spriteWithFile:@"Canyons looped.png"];
        _canyons.tag = 1;
        _canyons2 = [CCSprite spriteWithFile:@"Canyons looped.png"];
        _canyons2.tag = 2;
        
        // Speeds ratio for the objects in the parallax layer
        CGPoint cloudSpeed = ccp(0.5, 0);
        CGPoint bgSpeed = ccp(1.0, 1.0);
        
        // Add children to CCParallaxNode
        [_backgroundNode addChild:_canyons z:1 parallaxRatio:bgSpeed positionOffset:ccp(_canyons.contentSize.width/2, _canyons.contentSize.height/2)];
        [_backgroundNode addChild:_canyons2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_canyons2.contentSize.width+380, _canyons2.contentSize.height/2)];
        [_backgroundNode addChild:_cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
        [_backgroundNode addChild:_cloud2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_cloud1.contentSize.width+200,winSize.height/1.2)];
        
        // Adding object layer
        _objectLayer = [CCSpriteBatchNode batchNodeWithFile:@"plushypals.png" capacity:150];
        [self addChild:_objectLayer z:20];
        
        // First generate the maze then add the monkey
        _mazes = [[CCArray alloc] initWithCapacity:kNumMazes];
        [self addMazeObject];
        
        // Add monkey
        plushy = [[[Monkey alloc] initWithGameLayer:self] autorelease];
        [_objectLayer addChild:[plushy ccNode] z:10000];
        [plushy setPhysicsPosition:b2Vec2FromCC(240,90)];
        [plushy setLinearVelocity:b2Vec2(1.0,0)];
        
        // Initializing variables
        nextMazeSpawn = 0;
        duration = 4;
        verticalMazeObj = 0;
        
        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
        [self addGestureRecognizer:swipeLeftGestureRecognizer];
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        swipeLeftGestureRecognizer.delegate = self;
        [swipeLeftGestureRecognizer release];
        
        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
        [self addGestureRecognizer:swipeRightGestureRecognizer];
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        swipeRightGestureRecognizer.delegate = self;
        [swipeRightGestureRecognizer release];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer release];
        
        self.isTouchEnabled = YES;        
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark GameKit delegate
// Add new update method
- (void)update:(ccTime)dt {
    
    //CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    // Incrementing the position of the background parallaxnode
    CGPoint backgroundScrollVel = ccp(-100, 0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    
    // Add continuous scroll for clouds
    NSArray *clouds = [NSArray arrayWithObjects:_cloud1, _cloud2, nil];
    for (CCSprite *cloud in clouds) {
        if ([_backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2*cloud.contentSize.width-[_backgroundNode convertToWorldSpace:cloud.position].x,0) forChild:cloud];
        }
    }
    
    // Add continuous scroll for the canyon
    NSArray *backgrounds = [NSArray arrayWithObjects: _canyons, _canyons2, nil];
    for (CCSprite *background in backgrounds) {
        //NSLog(@"%d position is: (%f, %f)", background.tag, [_backgroundNode convertToWorldSpace:background.position].x, [_backgroundNode convertToWorldSpace:background.position].y);
        //NSLog(@"canyon.width, Windsize.width = (%f, %f)", background.contentSize.width, [[CCDirector sharedDirector] winSize].width);
        if ([_backgroundNode convertToWorldSpace:background.position].x < -500) {
            [_backgroundNode incrementOffset:ccp(100+background.contentSize.width-[_backgroundNode convertToWorldSpace:background.position].x,0) forChild:background];
        }
    }
    
    // Add maze objects to screen
    [self addMazeObject];
    
    //double curTime = CACurrentMediaTime();
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    
//    if (curTime > nextMazeSpawn) {
//        nextMazeSpawn = duration + curTime;
//        nextMazeSpawn = curTime;
//        //TODO: ADD algorithm to decide how to add mazes in order with same speed
//        //float randY = [self randomValueBetween:0.0 andValue:winSize.height];
//        
//        [self generateMaze:[plushy ccNode]];
//        //    newMaze = 1;
//        //    int preM = newMaze;
//        //    int i = 1;
//        //    while (preM == 1) {
//        //      CCSprite *maze = [CCSprite spriteWithFile:[@"unit_canyon" stringByAppendingFormat:@"%d.png",newMaze]];
//        //      [_mazes addObject:maze];
//        //      maze.position = ccp(winSize.width/2+i*maze.contentSize.width, winSize.height/2-plushy.contentSize.height);
//        //      [self addChild:maze z:50];
//        //      [maze runAction:[CCSequence actions:
//        //                       [CCMoveBy actionWithDuration:5 position:ccp(-2*winSize.width, 0)],
//        //                       [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
//        //                       nil]];
//        //      preM = newMaze;
//        //      newMaze = [self getRandomNumberBetweenMin:1 andMax:3];
//        //      i++;
//        
//        //    }
//        
//        //    nextMaze = [self getRandomNumberBetweenMin:1 andMax:3];
//        //    CCSprite *maze = [_mazes objectAtIndex:nextMaze];
//        //    nextMaze++;
//        //    if (nextMaze >= _mazes.count) nextMaze = 0;
//        
//        //    [maze stopAllActions];
//        //    //maze.visible = YES;
//        //    maze.position = ccp(winSize.width, winSize.height/2-plushy.contentSize.height);
//        //    [maze runAction:[CCSequence actions:
//        //                     [CCMoveBy actionWithDuration:7 position:ccp(-2*winSize.width, 0)],
//        //                     [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
//        //                     nil]];
//        
//    }
    
    
    // Add continous scrolling for the canyon unit(s)
    //    NSArray *canyonUnits = [NSArray arrayWithObjects:_floor, _floor2, nil];
    //    for (CCSprite *floor in canyonUnits) {
    //        NSLog(@"position is: (%f, %f)", [_obstacleNode convertToWorldSpace:floor.position].x, [_obstacleNode convertToWorldSpace:floor.position].y);
    //        if ([_obstacleNode convertToWorldSpace:floor.position].x < -floor.contentSize.width) {
    //            [_backgroundNode incrementOffset:ccp(cloud.contentSize.width-[_backgroundNode convertToWorldSpace:cloud.position].x,0) forChild:cloud];
    //        }
    //    }
    
    
    //    double offset = _canyons.contentSize.width-windowSize.width;
    //    if ([_backgroundNode convertToWorldSpace:_canyons.position].x < -offset) {
    //        [_backgroundNode incrementOffset:ccp(,0) forChild:_canyons];
    //    }
    
    //        if ([_backgroundNode convertToWorldSpace:monkey.position].x < -monkey.contentSize.width) {
    //            [_backgroundNode incrementOffset:ccp(1000,0) forChild:monkey];
    //        }
    
    //    // Add to bottom of update loop
    //    CGSize winSize = [CCDirector sharedDirector].winSize;
    //    double curTime = CACurrentMediaTime();
    //    if (curTime > _nextMazeSpawn) {
    //
    //        //float randSecs = [self randomValueBetween:0.20 andValue:1.0];
    //        _nextMazeSpawn = 1 + curTime;
    //
    //        float randY = [self randomValueBetween:0.0 andValue:winSize.height];
    //        //float randDuration = [self randomValueBetween:2.0 andValue:10.0];
    //        float randDuration = 7;
    //
    //        CCSprite *maze = [_mazes objectAtIndex:_nextMaze];
    //        _nextMaze++;
    //        if (_nextMaze >= _mazes.count) _nextMaze = 0;
    //
    //        [maze stopAllActions];
    //        maze.position = ccp(winSize.width+maze.contentSize.width/2, randY);
    //        maze.visible = YES;
    //        [maze runAction:[CCSequence actions:
    //                         [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-maze.contentSize.width, 0)],
    //                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
    //                         nil]];
    //
    //    }
}

-(void)addMazeObject
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    bool print = true;
    if (print) {
//        NSLog(@"Display size is: (%f, %f)", winSize.width, winSize.height);
        print = false;
    }

    // Generate as many maze objects as can fit into the screen.    
    Floor *lastMazeObj = [_mazes lastObject];
    NSString *mazeObjImage = @"unit_canyon1";
    //[[lastMazeObj ccNode] convertToWorldSpace:[lastMazeObj ccNode].position];
    while([lastMazeObj ccNode].position.x < winSize.width || [_mazes count] < 1)
    {
//        NSLog(@"Last maze physics position: (%f, %f)", [lastMazeObj ccNode].position.x, [lastMazeObj ccNode].position.y);
//        NSLog(@"Total %d mazes", [_mazes count]);
        Floor *_mazeObj = [Floor floorSprite:mazeObjImage spriteName:[mazeObjImage stringByAppendingString:@".png"]];
        if (lastMazeObj == nil) {
            [_mazeObj setPhysicsPosition:b2Vec2FromCC(75, MAZE_LOW)];
//            NSLog(@"Added 1st maze at position: (%d, %d)", 75, MAZE_LOW);
        }
        else
        {
            if([mazeObjImage isEqualToString:@"unit_canyon4"]) // Clean up this logic here
            {
                [_mazeObj setPhysicsPosition:b2Vec2FromCC([lastMazeObj ccNode].position.x+80, MAZE_LOW)];
            }
            else
            {
                [_mazeObj setPhysicsPosition:b2Vec2FromCC([lastMazeObj ccNode].position.x+75, MAZE_LOW)];
                //            NSLog(@"Added new maze at position: (%f, %d)", [lastMazeObj ccNode].position.x+70, MAZE_LOW);
            }
        }
        
        [_mazeObj setLinearVelocity:b2Vec2(-0.8,0)];
        [_objectLayer addChild:[_mazeObj ccNode] z:50]; //TODO: Do not keep adding maze objects into the objectLayer!!!!
        [_mazes addObject:_mazeObj];
        lastMazeObj = _mazeObj;
        
        if (verticalMazeObj == 3) { //Crude code for testing collision detection.
            verticalMazeObj = 0;
            mazeObjImage = @"unit_canyon4";
        }
        verticalMazeObj++;
    }
}

-(void)generateMaze:(CCNode*)node
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    newMaze = 1;
    //int preM = newMaze;
    int i = 1;
    while (i<2) {
        //CCSprite *maze = [CCSprite spriteWithFile:[@"unit_canyon" stringByAppendingFormat:@"%d.png",newMaze]];
        //NSString *mazeName = [@"unit_canyon" stringByAppendingFormat:@"%d.png",newMaze];
        NSString *mazeName = @"unit_canyon1.png";
        CCSprite *maze = [CCSprite spriteWithSpriteFrameName:mazeName];
        Floor *mazeObj = [Floor floorSprite:@"unit_canyon1" spriteName:mazeName];
        [_mazes addObject:maze];
        switch (newMaze) {
            case 4:
                //maze.position = ccp(node.position.x+i*maze.contentSize.width, winSize.height/2-plushy.contentSize.height/2+maze.contentSize.height/3);
                [mazeObj setPhysicsPosition:b2Vec2FromCC(node.position.x-50+i*maze.contentSize.width, winSize.height/2-125+maze.contentSize.height/3)]; //TODO:
                break;
                
            case 3:
                //maze.position = ccp(node.position.x+i*maze.contentSize.width, winSize.height/2-plushy.contentSize.height/2-maze.contentSize.height/3);
                [mazeObj setPhysicsPosition:b2Vec2FromCC(node.position.x-50+i*maze.contentSize.width, winSize.height/2-125-maze.contentSize.height/3)];
                break;
                
            default:
                //maze.position = ccp(node.position.x+i*maze.contentSize.width, winSize.height/2-plushy.contentSize.height/2);
                [mazeObj setPhysicsPosition:b2Vec2FromCC(node.position.x-50+i*maze.contentSize.width, winSize.height/2-125)];
                break;
        }
        
        [_objectLayer addChild:[mazeObj ccNode] z:50];
        [mazeObj setLinearVelocity:b2Vec2(-0.8,0)];
        //        [maze runAction:[CCSequence actions:
        //                         [CCMoveBy actionWithDuration:5 position:ccp(-2*winSize.width, 0)],
        //                         nil]];
        
        //preM = newMaze;
        //if (i > 4) newMaze = [self getRandomNumberBetweenMin:3 andMax:4];
        //newMaze = [self getRandomNumberBetweenMin:1 andMax:4];
        i++;
    }
    duration = 6;
    nextMazeSpawn += duration;
    NSLog(@"Finish generating maze: currTime is:%f nextMazeSpawn: %f", CACurrentMediaTime(), nextMazeSpawn);
}

-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

// Add new method, above update loop
- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (void)addBoxBodyForSprite:(CCSprite *)sprite {
    
    b2BodyDef spriteBodyDef;
    spriteBodyDef.type = b2_staticBody;
    spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
    spriteBodyDef.userData = sprite;
    b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
    
    b2PolygonShape spriteShape;
    spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
                         sprite.contentSize.height/PTM_RATIO/2);
    
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 10.0;
    spriteShapeDef.isSensor = true;
    
    spriteBody->CreateFixture(&spriteShapeDef);
}

// Add new method
- (void)setInvisible:(CCNode *)node {
    node.visible = NO;
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    //	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    //	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    //	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    //	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  [plushy jump];

//    [[plushy ccNode]  stopAllActions];
//    [[plushy ccNode] runAction: [CCJumpBy actionWithDuration:1 position:ccp(0,0) height:80 jumps:1]];
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
    float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    CCSprite *oldmaze;
    for (oldmaze in _mazes) {
        if (oldmaze != [_mazes lastObject])  [self setInvisible:oldmaze];
    }
    oldmaze = [_mazes lastObject];
    [oldmaze runAction:[CCSequence actions: [CCRotateBy actionWithDuration:0.8 angle:angle], [CCCallFuncN actionWithTarget:self selector:@selector(generateMaze:)], nil]];
}

@end
