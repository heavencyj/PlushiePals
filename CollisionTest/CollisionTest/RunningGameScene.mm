//
//  RunningGameScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 4/1/13.
//
//
#import "RunningGameScene.h"
#import "Maze.h"

// Macros for constants
#define PTM_RATIO 32
#define WALKING_FRAMES 3
#define MAZE_LOW 30
#define ARC4RANDOM_MAX 0x100000000
#define ICON_DIST 60
#define round(x) ((x) < LONG_MIN-0.5 || (x) > LONG_MAX+0.5)
#define SCORE_DELAY 20

// Level related variables
int currentLevel;
int mapCount;
float diffFactor;
bool pass1;
float angle1;
int rotating1;
int score;
CCSprite *hand;
CCSprite *handOnly;
bool isSwipable;

#pragma mark - GameScene

// HelloWorldLayer implementation
@implementation RunningGameScene

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    Hud *hud = [Hud node];
    BackgroundScene *bg = [BackgroundScene node];
    
    diffFactor = 0.6;
    mapCount = 1;
    
    RunningGameScene *game = [[[RunningGameScene alloc] initWithHud:hud] autorelease];
	
	// add layer as a child to scene
    [scene addChild:bg z:0];
	[scene addChild:game z:10];
    [scene addChild:hud z:20];
    pass1 = false;
    rotating1 = 0;
    
	// return the scene
	return scene;
}

// On "init" you need to initialize your instance
-(id) initWithHud:(Hud*)hudRef
{
    hud = hudRef;
	// always call "super" init
	if( (self=[super init]) ) {
        // Add pause layer
        pauseLayer = [[PauseLayer alloc] initWithHud:self];
        [hud addChild:pauseLayer z:300];
        
        // Adding object layer
        plushyLayer = [CCSpriteBatchNode batchNodeWithFile:@"monkeys.png" capacity:150];
        [self addChild:plushyLayer z:200];
        
        [MazeLayer initMapDictionaries];

        // add score
        scoreDelay = SCORE_DELAY;
        score = 0;
        nextObject= 5.0f;  // first object to appear after 3s
        
        // add maze
        if ([MainMenuScene showTips]) {
            currentLevel = 1;
        }
        else {
            // The first map should always be easy
//            diffFactor = 1;
//            currentLevel = [self levelChooser];
//            diffFactor = 0.6;
        }
        
        // load intro bridge
        initialBridge = [TransitionObject transitionObjectSprite];
        [initialBridge setPhysicsPosition:b2Vec2FromCC(0, 100)];
        [initialBridge setBodyType:b2_kinematicBody];
        [initialBridge setLinearVelocity:b2Vec2(MAZESPEED,0)];
        [self addChild:[initialBridge ccNode] z:30];
        
        // Add monkey
        plushy = [[[Plushy alloc] initWithGameLayer:self] autorelease];
        plushySpeed = 3.0;
        [plushy setLinearVelocity:b2Vec2(plushySpeed,0)];
        [plushyLayer addChild:[plushy ccNode] z:10];
        
        // following the movements of the plushy
        [self runAction:[CCCustomFollow actionWithTarget:[plushy ccNode]]];
        
        // drawing the world boundary for debugging
        //[self addChild:[[GB2DebugDrawLayer alloc] init] z:500];
        
        self.isTouchEnabled = YES;
        isSwipable = YES;
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark GameKit delegate
// Add new update method
- (void)update:(ccTime)dt {
    
    //Delay variables decrementing
    if (speedDelay > 0) {
        speedDelay --;
    }
    if (scoreDelay > 0) {
        scoreDelay--;
    }
    
    // Update score with a little bit delay for performance concern
    if (scoreDelay ==0) {
        score ++ ;
        [hud updateScore:score];
        scoreDelay = SCORE_DELAY;
    }
    
    if (score > 500) {
        CCLOG(@"Scores");
    }
    
    // Check the status of the maze
    [self checkMapStatus];
    
    // Add objects to path
    if (!plushy.onBridge) {
        int objectPattern = [GameScene getRandomNumberBetweenMin:1 andMax:2];
        [self nextObject:dt pattern:objectPattern];
    }
    
    // Showing tips
    if (plushy.tip != -1 && [MainMenuScene showTips]) {
        showingTip1 = plushy.tip;
        tutorial1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip1]];
        switch (showingTip1) {
            case 1: {
                // swipe left
                tutorial1.position = ccp(plushy.ccPosition.x - 150, plushy.ccPosition.y);
                hand = [CCSprite spriteWithFile:@"hand.png"];                
                hand.position = tutorial1.position;
                [self addChild:hand z:500 tag:10];
                id moveHandLeft = [CCMoveBy actionWithDuration:0.5 position:ccp(-40, 0)];
                [hand runAction:moveHandLeft];
                isSwipable = YES;
                break;
            }
            
            case 2: {
                // swipe right
                tutorial1.position = ccp(plushy.ccPosition.x - 100, plushy.ccPosition.y);
                hand = [CCSprite spriteWithFile:@"hand.png"];
                hand.position = tutorial1.position;
                [self addChild:hand z:500 tag:10];
                id moveHandRight = [CCMoveBy actionWithDuration:0.5 position:ccp(40, 0)];
                [hand runAction:moveHandRight];
                isSwipable = YES;
                break;
            }
            
            case 3: {
                // jump
                tutorial1.position = ccp(plushy.ccPosition.x - 100, plushy.ccPosition.y);
                // animation seq
                break;
                
            }
            
            case 4: {
                // sliding
                tutorial1.position = ccp(plushy.ccPosition.x - 100, plushy.ccPosition.y);
                
                // animation seq
                break;
                
            }
            case 5: case 6: {
                // cactus and bananas
                [pauseLayer pauseGame];
                tutorial1.position = ccp(plushy.ccPosition.x - 100, plushy.ccPosition.y);
                break;
            }
                
            case 10: case 11:{
                // arrows
                tutorial1.scale = 0.5;
                tutorial1.position = ccp(plushy.ccPosition.x, plushy.ccPosition.y+70);
                isSwipable = YES;
                break;
            }
                
            default:
                break;
        }
        [self addChild:tutorial1 z:450];
        [plushy setTip];
        // show the tool tips and imgs
        // when swife, resume
    }
    
    if (plushy.collide) {
        [currMazeLayer stop];
    }
    if (plushy.dead)
    {
        NSArray* fruits = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:plushy.bananaScore],
                           [NSNumber numberWithInt:0],
                           [NSNumber numberWithInt:0], nil];
        [[GB2Engine sharedInstance] deleteAllObjects];
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:score wtihFruits:fruits]];
    }
}

-(void)checkMapStatus
{
    if (plushy.loadmap) {
        mapCount += 1;
        [self loadMazeLayer];
        plushy.loadmap = NO;
    }
}

-(void)loadMazeLayer
{
    //Load new mazelayer
    if (currMazeLayer != nil) {
        [currMazeLayer setBridgeBody:b2_kinematicBody];
    }
    prevMazeLayer = currMazeLayer;
    currMazeLayer = [[[MazeLayer alloc] init] autorelease];
    [self addChild:currMazeLayer z:10];
    CGPoint levelInfo = [currMazeLayer levelChooser:mapCount];
    if (ceil(levelInfo.x) == 0) {
        // In case if the level is somehow off, it will default to level 1
        levelInfo.x = 1;
    }
    [currMazeLayer loadMaze:ceil(levelInfo.x) withObject:ceil(levelInfo.y)];
    //[currMazeLayer loadMaze:1 withObject:0];
    [currMazeLayer lineUpAround:[plushy ccNode].position];
}

-(void)showBridge
{
    [currMazeLayer showBridge];
    [self removeChild:prevMazeLayer cleanup:YES];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}

-(void)resetHandLeft:(CCNode*)node
{
    node.position = ccp(node.position.x+20, node.position.y);
}

-(void)resetHandRight:(CCNode*)node
{
    node.position = ccp(node.position.x-20, node.position.y);
}

-(float) timer: (ccTime) dt
{
    if (seconds >= 2) {
        plushy.sliding = true;
    }
    //whatever you do here (e.g. move sprite) will be done continuously until TouchEnded occurs
    seconds ++;
    return dt;
    
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    seconds = 0;
    [self schedule:@selector(timer:) interval:0.08];
    
    //Swipe Detection Part 1
    firstTouch = location;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 2
    lastTouch = location;
//    [self unschedule:@selector(timer:)];
//    if (plushy.sliding) {
//        if ((showingTip1 == 4)
//            && [MainMenuScene showTips]) {
//            [self removeChild:tutorial1 cleanup:YES];
//            showingTip1 = -1;
//            isSwipable = NO;
//        }
//        plushy.sliding = false;
//    }
    
    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    //    NSLog(@"SwipeLength is: %f", swipeLength);
    // tap gesture
    if (swipeLength < 20 && seconds < 5)
    {
        // If pause button is tapped
        if (CGRectContainsPoint(hud.pauseButtonRect, location)){
            [pauseLayer pauseGame];
            [pauseLayer pauseLayerVisible:YES];
        }
        // Otherwise its' for jumping and we prevent double jumping
        else if (!plushy.jumping) {
            if ((showingTip1 == 3)
                && [MainMenuScene showTips]) {
                [self removeChild:tutorial1 cleanup:YES];
                showingTip1 = -1;
                isSwipable = NO;
            }
            else if ((showingTip1 == 5 || showingTip1 == 6)
                     && [MainMenuScene showTips]) {
                [pauseLayer resumeGame];
                [self removeChild:tutorial1 cleanup:YES];
                showingTip1 = -1;
                isSwipable = NO;
            }
            
            [plushy jump];
        }
    }
    else
    {
        //Check if the swipe is a left swipe and long enough
        //if (firstTouch.x > lastTouch.x && swipeLength > 60 && plushy.swipeRange) //left swipe (90)
        if (firstTouch.x > lastTouch.x && swipeLength > 60 && isSwipable && !plushy.onBridge) //left swipe (90)
        {
            
            CGPoint p1 = [plushy ccNode].position;
            p1.y = p1.y-80;
            [currMazeLayer transformAround:p1 WithAngle:-90];
        }
        //else if(firstTouch.x < lastTouch.x && swipeLength > 60 && plushy.swipeRange) // right swipe (-90)
        else if(firstTouch.x < lastTouch.x && swipeLength > 60 && isSwipable && !plushy.onBridge) // right swipe (-90)
        {
            CGPoint p1 = [plushy ccNode].position;
            p1.y = p1.y+10;
            [currMazeLayer transformAround:p1 WithAngle:90];
        }
        if ((showingTip1 == 1 || showingTip1 == 2 || showingTip1 == 10 || showingTip1 == 11)
            && [MainMenuScene showTips]) {
            isSwipable = NO;
            showingTip1 = -1;
            [self removeChildByTag:10 cleanup:YES];
            [self removeChild:tutorial1 cleanup:YES];
        }
        
    }
}

- (void)setInvisible:(id)a data:(CCNode *)node{
    node.visible = NO;
}
- (void)setNodeVisible:(id)a data:(CCNode *)node {
    node.visible = YES;
}

-(void)setHandPos:(id)a data:(CCNode *)node {
    node.position = ccp(node.position.x-15, node.position.y-10);
}

+(void)resetSwipe
{
    isSwipable = YES;
}

+(void)addScore:(int)points {
    score += points;
}

@end
