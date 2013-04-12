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
        
        [MazeLayer initMapLevels];

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
        // regain one life for every 300 points plushy gains
        if (score % 300 == 0) {
            [plushy regainLive];
        }
        scoreDelay = SCORE_DELAY;
    }
    
    // Check the status of the maze
    [self checkMapStatus];
    
    // Add objects to path
    int objectPattern = [GameScene getRandomNumberBetweenMin:1 andMax:2];
    [self nextObject:dt pattern:objectPattern];
    
    // Showing tips
    if (plushy.tip != -1 && [MainMenuScene showTips]) {
        showingTip1 = plushy.tip;
        switch (showingTip1) {
            case 1: case 2: case 3: case 4: case 5: case 6:
                [pauseLayer pauseGame];
                tutorial1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip1]];
                tutorial1.position = ccp([[CCDirector sharedDirector] winSize].width/3, [[CCDirector sharedDirector] winSize].height/2);
                [self addChild:tutorial1 z:500];
                [plushy setTip];
                break;
                
            case 10: case 11:
                [pauseLayer pauseGame];
                tutorial1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial %d.png", showingTip1]];
                tutorial1.scale = 0.5;
                tutorial1.position = ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/3);
                [self addChild:tutorial1 z:500];
                [plushy setTip];
                break;
                
            default:
                break;
        }
        // show the tool tips and imgs
        // when swife, resume
    }
    
    if (plushy.collide) {
        [currMazeLayer stop];
    }
    if (plushy.dead)
    {
        if (!plushy.lives) {
            [[GB2Engine sharedInstance] deleteAllObjects];
            //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass1 withLevel:currentLevel withScore:plushy.bananaScore]];
            [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:pass1 withLevel:currentLevel withScore:score]];
            //[Plushy playSound:DYING];
        }
        else
        {
            // stop following the plushy, reset the plushy, then begin following plushy once more
            [self stopAction:[CCCustomFollow actionWithTarget:[plushy ccNode]]];
            [plushy destroyLive];
            [plushy resetPlushyPosition];
            [currMazeLayer reset];
        }
    }
}

-(void)checkMapStatus
{
    if (plushy.loadmap) {
        [self loadMazeLayer];
        plushy.loadmap = NO;
    }
    else if (plushy.showmap)
    {
        [self revealMazeLayer];
        plushy.showmap = NO;
    }
}

-(void)loadMazeLayer
{
    //Load new mazelayer
    if (currMazeLayer != nil) {
        [currMazeLayer setBridgeBody:b2_kinematicBody];
    }
    currMazeLayer = [[[MazeLayer alloc] init] autorelease];
    [self addChild:currMazeLayer z:10];
    [currMazeLayer loadMaze:[currMazeLayer levelChooser]];
}

-(void)revealMazeLayer
{
    //remove previous mazelayer
    [currMazeLayer lineUpAround:[plushy ccNode].position];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}


-(float) timer: (ccTime) dt
{
    if (seconds >= 5) {
        plushy.sliding = true;
        //[Plushy playSound:SLIDING];
    }
    //whatever you do here (e.g. move sprite) will be done continuously until TouchEnded occurs
    seconds ++;
    return dt;
    
}

+(void)addScore:(int)points {
    score += points;
}

@end
