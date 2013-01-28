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

#define kNumMazes   1
#define PTM_RATIO 32
#define WALKING_FRAMES 3

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize objectLayer = _objectLayer;
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

// on "init" you need to initialize your instance
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
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"monkeyshapes.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"chase-hd.plist"];
        
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
        
        
        CGPoint cloudSpeed = ccp(0.5, 0);
        CGPoint bgSpeed = ccp(1.0, 1.0);
        //CGPoint mazeSpeed = ccp(0.1,0.1);
        
        // Add children to CCParallaxNode
        [_backgroundNode addChild:_canyons z:1 parallaxRatio:bgSpeed positionOffset:ccp(_canyons.contentSize.width/2, _canyons.contentSize.height/2)];
        [_backgroundNode addChild:_canyons2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_canyons2.contentSize.width+380, _canyons2.contentSize.height/2)];
        [_backgroundNode addChild:_cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
        [_backgroundNode addChild:_cloud2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(_cloud1.contentSize.width+200,winSize.height/1.2)];
        
        
        // Adding object layer
        _objectLayer = [CCSpriteBatchNode batchNodeWithFile:@"chase-hd.png" capacity:150];
        [self addChild:_objectLayer z:20];
        
        // Setup floor front layer, physics position is 0/0 by default
//        _obstacleNode = [CCParallaxNode node];
//        [self addChild:_obstacleNode z:30];
        
//        _canyonunit = [CCSprite spriteWithSpriteFrameName:@"unit canyon.png"];
//        _canyonunit.position = ccp(240,10);
//        [_objectLayer addChild:_canyonunit];
//        [self addBoxBodyForSprite:_canyonunit];
//        CGPoint canyonUnitSpeed = ccp(0.5, 0.5);
//        [_obstacleNode addChild:_canyonunit z:30 parallaxRatio:canyonUnitSpeed positionOffset:ccp(200, 200)];
        
        //[_objectLayer addChild:[[Floor floorSprite] ccNode] z:50];
        _floor = [Floor floorSprite];
        [_objectLayer addChild:[_floor ccNode] z:30];
        [_floor setPhysicsPosition:b2Vec2FromCC(240,10)];
        
//      Add monkey
        _monkey = [[[Monkey alloc] initWithGameLayer:self] autorelease];
        [_objectLayer addChild:[_monkey ccNode] z:10000];
        [_monkey setPhysicsPosition:b2Vec2FromCC(10,20)];
        
        [self scheduleUpdate];
        
        // Box2D
//        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
//        bool doSleep = false;
//        _world = new b2World(gravity);
//        _world->SetAllowSleeping(doSleep);
        
        // Create contact listener
//        _contactListener = new MyContactListener();
//        _world->SetContactListener(_contactListener);

        // Enable debug draw
        //        [self addChild:[[GB2DebugDrawLayer alloc] init] z:30];
        //        _debugDraw = new GLESDebugDraw(PTM_RATIO);
        //        _world->SetDebugDraw(_debugDraw);
        //        uint32 flags = 0;
        //        flags += b2Draw::e_shapeBit;
        //        _debugDraw->SetFlags(flags);
        
        // Animating running monkey
//        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
//        
//        CCSpriteBatchNode *monkeySprite = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:2];
//        [self addChild:monkeySprite];
//        
//        NSMutableArray *walkAnimFrames = [NSMutableArray array];
//        for(int i = 1; i <= WALKING_FRAMES; ++i) {
//            [walkAnimFrames addObject:
//             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
//              [NSString stringWithFormat:@"Monkey run %d.png", i]]];
//        }
//        CCAnimation *walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
//        
//        self.spriteSheet = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
//        _spriteSheet.position = ccp(winSize.width/2-50, winSize.height/2);
//        self.walkAction = [CCRepeatForever actionWithAction:
//                           [CCAnimate actionWithAnimation:walkAnim]];
//        [_spriteSheet runAction:_walking];
//        [monkeySprite addChild:_spriteSheet];
//        monkey = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
//        [self addBoxBodyForSprite:monkey];
        
        // Testing collision bound on the running monkey
//        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:2];
//        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
//        [self addChild:_spriteSheet z:0 tag:0];
//        monkey = [CCSprite spriteWithSpriteFrameName:@"Monkey run 1.png"];
//        //monkey = [CCSprite spriteWithFile: @"MonkeyIcon.png"];
//        monkey.position = ccp(winSize.width/2, winSize.height/2);
//        [self addChild:monkey];
//        [self addBoxBodyForSprite:monkey];
        
//        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
//        [self addGestureRecognizer:swipeLeftGestureRecognizer];
//        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        swipeLeftGestureRecognizer.delegate = self;
//        [swipeLeftGestureRecognizer release];
//        
//        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
//        [self addGestureRecognizer:swipeRightGestureRecognizer];
//        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//        swipeRightGestureRecognizer.delegate = self;
//        [swipeRightGestureRecognizer release];
//        
//        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
//        [self addGestureRecognizer:tapGestureRecognizer];
//        tapGestureRecognizer.numberOfTapsRequired = 1;
//        tapGestureRecognizer.delegate = self;
//        [tapGestureRecognizer release];
        
        // schedule a repeating callback on every frame
        //[self schedule:@selector(nextFrame:)];
        //[self scheduleUpdate];
        
        //self.isTouchEnabled = YES;
        
    
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
        
        
        // Loading audio effect
        //[[SimpleAudioEngine sharedEngine] loadEffect:"collisionaudio.caf"];
    }

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
    
        std::vector<b2Body *>::iterator pos2;
        for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
            b2Body *body = *pos2;
            if (body->GetUserData() != NULL) {
                //CCSprite *sprite = (CCSprite *) body->GetUserData();
                //[_spriteSheet removeChild:sprite cleanup:YES];
            }
            _world->DestroyBody(body);
    }
    
    if (toDestroy.size() > 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"collisionaudio.caf"];
    }
}

//-(void) draw
//{
//    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
//	//glDisable(GL_TEXTURE_2D);
//	//glDisableClientState(GL_COLOR_ARRAY);
//	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//    
//	_world->DrawDebugData();
//    
//	//glEnable(GL_TEXTURE_2D);
//	//glEnableClientState(GL_COLOR_ARRAY);
//	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//}

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
- (void)update:(ccTime)dt {

    //CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    // Incrementing the position of the background parallaxnode
    CGPoint backgroundScrollVel = ccp(-100, 0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    
//    CGPoint obstacleScrollVel = ccp(-100, 0);
//    _obstacleNode.position = ccpAdd(_obstacleNode.position, ccpMult(obstacleScrollVel, dt));
    
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

- (void)addBoxBodyForSprite:(CCSprite *)sprite {
    
    b2BodyDef spriteBodyDef;
    spriteBodyDef.type = b2_dynamicBody;
    spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
    spriteBodyDef.userData = sprite;
    b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
    
    b2PolygonShape spriteShape;
    spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
     sprite.contentSize.height/PTM_RATIO/2);
//    if (sprite.tag == 1) {
//        int num = 6;
//        b2Vec2 verts[] = {b2Vec2(4.5f / PTM_RATIO, -17.7f / PTM_RATIO),
//            b2Vec2(20.5f / PTM_RATIO, 7.2f / PTM_RATIO),
//            b2Vec2(22.8f / PTM_RATIO, 29.5f / PTM_RATIO),
//            b2Vec2(-24.7f / PTM_RATIO, 31.0f / PTM_RATIO),
//            b2Vec2(-20.2f / PTM_RATIO, 4.7f / PTM_RATIO),
//            b2Vec2(-11.7f / PTM_RATIO, -17.5f / PTM_RATIO)};
//        spriteShape.Set(verts, num);
//    } else {
//        // Do the same thing as the above, but use the car data this time
//        int num = 7;
//        b2Vec2 verts[] = {b2Vec2(-11.8f / PTM_RATIO, -24.5f / PTM_RATIO),
//            b2Vec2(11.7f / PTM_RATIO, -24.0f / PTM_RATIO),
//            b2Vec2(29.2f / PTM_RATIO, -14.0f / PTM_RATIO),
//            b2Vec2(28.7f / PTM_RATIO, -0.7f / PTM_RATIO),
//            b2Vec2(8.0f / PTM_RATIO, 18.2f / PTM_RATIO),
//            b2Vec2(-29.0f / PTM_RATIO, 18.7f / PTM_RATIO),
//            b2Vec2(-26.3f / PTM_RATIO, -12.2f / PTM_RATIO)};
//        spriteShape.Set(verts, num);
//    }
    
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

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
//    float angle = (aGestureRecognizer.direction ==  UISwipeGestureRecognizerDirectionRight) ? 90:-90;
//    [monkey runAction:[CCRotateBy actionWithDuration:0.8 angle:angle]];
//    CGSize winSize = [CCDirector sharedDirector].winSize;
//    for (CCSprite *maze in _mazes) {
//        [maze stopAllActions];
//        [maze runAction:[CCSequence actions:
//                         [CCMoveBy actionWithDuration:7 position:ccp(0,winSize.width+maze.contentSize.width)],
//                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
//                         nil]];
//        
//    }
}

- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
//    [pig stopAllActions];
//    [pig runAction: [CCJumpBy actionWithDuration:1 position:ccp(0,0) height:80 jumps:1]];
}
@end
