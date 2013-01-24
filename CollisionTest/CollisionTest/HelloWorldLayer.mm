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

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "CCParallaxNode-Extras.h"

#define kNumMazes   1
#define PTM_RATIO 32
#define WALKING_FRAMES 3

CCSprite *pig;
CCSprite *monkey;
CCSprite *bg;

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize spriteSheet = _spriteSheet;
@synthesize walkAction = _walking;

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

- (void)addBoxBodyForSprite:(CCSprite *)sprite {
    
    b2BodyDef spriteBodyDef;
    spriteBodyDef.type = b2_dynamicBody;
    spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO,
                               sprite.position.y/PTM_RATIO);
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

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        //        bg = [CCSprite spriteWithFile: @"Canyon_background.png"];
        //        bg.position = ccp(winSize.width/2, winSize.height/2);
        //        bg.scale = 1.5;
        //        [self addChild:bg];
        
        // Box2D
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = false;
        _world = new b2World(gravity);
        _world->SetAllowSleeping(doSleep);
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        // Preload effect
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"collisionaudio.caf"];
        
        // Enable debug draw
        //        _debugDraw = new GLESDebugDraw(PTM_RATIO);
        //        _world->SetDebugDraw(_debugDraw);
        //
        //        uint32 flags = 0;
        //        flags += b2Draw::e_shapeBit;
        //        _debugDraw->SetFlags(0x0001);
        
        // Create sprite sheet and frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        
        CCSpriteBatchNode *monkeySprite = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:2];
        [self addChild:monkeySprite];
        
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= WALKING_FRAMES; ++i) {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Monkey run %d.png", i]]];
        }
        CCAnimation *walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
        
        self.spriteSheet = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
        _spriteSheet.position = ccp(winSize.width/2-50, winSize.height/2);
        self.walkAction = [CCRepeatForever actionWithAction:
                           [CCAnimate actionWithAnimation:walkAnim]];
        [_spriteSheet runAction:_walking];
        [monkeySprite addChild:_spriteSheet];
        //monkey = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
        //[self addBoxBodyForSprite:monkey];
        
        // create and initialize our seeker sprite, and add it to this layer
        //        pig = [CCSprite spriteWithFile: @"Pig.png"];
        //        //pig.position = ccp(50, 100 );
        //        pig.position = ccp(winSize.width * 0.1, winSize.height * 0.5);
        //        pig.scale = 0.6;
        //        [self addChild:pig z:1];
        //        [self addBoxBodyForSprite:pig];
        
        // do the same for our cocos2d guy, reusing the app icon as its image
        
        
        //        monkey = [CCSprite spriteWithFile: @"empty.png"];
        //        monkey.position = ccp(winSize.width/2, winSize.height/2);
        //        [self addChild:monkey z:1];
        
        // Testing collision bound on the running monkey
        //        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:2];
        //        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        //        [self addChild:_spriteSheet z:0 tag:0];
        //        monkey = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
        //        //monkey = [CCSprite spriteWithFile: @"MonkeyIcon.png"];
        //        monkey.position = ccp(winSize.width/2, winSize.height/2);
        //        [self addChild:monkey];
        //        [self addBoxBodyForSprite:monkey];
        
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
        
        // schedule a repeating callback on every frame
        [self schedule:@selector(nextFrame:)];
        //[self scheduleUpdate];
        
        self.isTouchEnabled = YES;
        
        /*
         // 1) Create the CCParallaxNode
         _backgroundNode = [CCParallaxNode node];
         [self addChild:_backgroundNode z:0];
         
         // 2) Create the sprites we'll add to the CCParallaxNode
         _cloud1 = [CCSprite spriteWithFile:@"Canyon_cloud1.png"];
         //[self addBoxBodyForSprite:_cloud1];
         _cloud2 = [CCSprite spriteWithFile:@"Canyon_cloud2.png"];
         //[self addBoxBodyForSprite:_cloud2];
         _canyons = [CCSprite spriteWithFile:@"Canyons.png"];
         
         // 3) Determine relative movement speeds for space dust and background
         CGPoint cloudSpeed = ccp(0.1, 0.1);
         CGPoint bgSpeed = ccp(0.05, 0.05);
         //CGPoint mazeSpeed = ccp(0.1,0.1);
         
         // 4) Add children to CCParallaxNode
         [_backgroundNode addChild:_canyons z:1 parallaxRatio:cloudSpeed positionOffset:ccp(_canyons.contentSize.width/2,_canyons.contentSize.height/2)];
         [_backgroundNode addChild:_cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
         [_backgroundNode addChild:_cloud2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_cloud1.contentSize.width,winSize.height/1.2)];
         //[_backgroundNode addChild:monkey z:1 parallaxRatio:mazeSpeed positionOffset:ccp(winSize.width*0.25,0)];
         */
        
        // Add to bottom of init
        //        _mazes = [[CCArray alloc] initWithCapacity:kNumMazes];
        //        for(int i = 0; i < kNumMazes; ++i) {
        //            CCSprite *maze = [CCSprite spriteWithFile:@"maze_demo.png"];
        //            maze.visible = NO;
        //            //[self addChild:maze];
        //            [monkey addChild:maze];
        //            [_mazes addObject:maze];
        //            //[self addBoxBodyForSprite:maze];
        //        }
    }
    
    [self schedule:@selector(tick:)];
	return self;
}

- (void)tick:(ccTime)dt {
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"collisionaudio.caf"];
    
    _world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
            
            b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                       sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            
            b->SetTransform(b2Position, b2Angle);
        }
    }
    
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"collisionaudio.caf"];
            //            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            //            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            //
            //            if (spriteA.tag == 1 && spriteB.tag == 2) {
            //                toDestroy.push_back(bodyA);
            //            } else if (spriteA.tag == 2 && spriteB.tag == 1) {
            //                toDestroy.push_back(bodyB);
            //            }
        }
    }
    
    //    std::vector<b2Body *>::iterator pos2;
    //    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
    //        b2Body *body = *pos2;
    //        if (body->GetUserData() != NULL) {
    //            //CCSprite *sprite = (CCSprite *) body->GetUserData();
    //            //[_spriteSheet removeChild:sprite cleanup:YES];
    //        }
    //        _world->DestroyBody(body);
    //    }
    
    //    if (toDestroy.size() > 0) {
    //        [[SimpleAudioEngine sharedEngine] playEffect:@"collisionaudio.caf"];
    //    }
}

-(void) draw
{
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
	//glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_COLOR_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	_world->DrawDebugData();
    
	//glEnable(GL_TEXTURE_2D);
	//glEnableClientState(GL_COLOR_ARRAY);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)spriteDone:(id)sender {
    
    CCSprite *sprite = (CCSprite *)sender;
    
    b2Body *spriteBody = NULL;
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *curSprite = (CCSprite *)b->GetUserData();
            if (sprite == curSprite) {
                spriteBody = b;
                break;
            }
        }
    }
    if (spriteBody != NULL) {
        _world->DestroyBody(spriteBody);
    }
    
    //[_spriteSheet removeChild:sprite cleanup:YES];
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

#pragma mark GameKit delegate
// Add new update method
- (void)nextFrame:(ccTime)dt {
    
    pig.position = ccp( pig.position.x + 100*dt, pig.position.y );
    if (pig.position.x > 480+32) {
        pig.position = ccp( -32, pig.position.y );
    }
    
    //    CGPoint backgroundScrollVel = ccp(-1000, 0);
    //    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    //
    //    // Add at end of your update method
    //    NSArray *clouds = [NSArray arrayWithObjects:_cloud1, _cloud2, nil];
    //    for (CCSprite *cloud in clouds) {
    //        if ([_backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
    //            [_backgroundNode incrementOffset:ccp(2*cloud.contentSize.width,0) forChild:cloud];
    //        }
    //    }
    //
    //    NSArray *backgrounds = [NSArray arrayWithObjects:_canyons, nil];
    //    for (CCSprite *background in backgrounds) {
    //        if ([_backgroundNode convertToWorldSpace:background.position].x < -background.contentSize.width) {
    //            [_backgroundNode incrementOffset:ccp(1000,0) forChild:background];
    //        }
    //    }
    //
    //    if ([_backgroundNode convertToWorldSpace:monkey.position].x < -monkey.contentSize.width) {
    //        [_backgroundNode incrementOffset:ccp(1000,0) forChild:monkey];
    //    }
    //
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

// Add new method
- (void)setInvisible:(CCNode *)node {
    node.visible = NO;
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
    float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
    [monkey runAction:[CCRotateBy actionWithDuration:0.8 angle:angle]];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    for (CCSprite *maze in _mazes) {
        [maze stopAllActions];
        [maze runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:7 position:ccp(0,winSize.width+maze.contentSize.width)],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
        
    }
}

- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
    [pig stopAllActions];
    [pig runAction: [CCJumpBy actionWithDuration:1 position:ccp(0,0) height:80 jumps:1]];
}
@end
