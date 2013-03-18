//
//  BackgroundScene.m
//  CollisionTest
//
//  Created by Lan Li on 3/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BackgroundScene.h"
#import "CCParallaxNode-Extras.h"
#import "GB2Sprite.h"

@implementation BackgroundScene

CCSprite *background;
CCSprite *cloud1;
CCSprite *cloud2;
CCSprite *canyons;
CCSprite *canyons2;
CCParallaxNode *backgroundNode;

-(id) init
{
    if( (self=[super init]) ) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Adding solid background color
        background = [CCLayerColor layerWithColor:ccc4(253,250,180,255) width:winSize.width height:winSize.height];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        [self addChild:background];
        
        // Loading physics shapes
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"plushyshapes.plist"];
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"canyon_levels.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"monkeys_default.plist"];
        
        // 1) Create the CCParallaxNode
        backgroundNode = [CCParallaxNode node];
        [self addChild:backgroundNode z:10];
        
        // Create the continuous scrolling background
        cloud1 = [CCSprite spriteWithFile:@"Canyon cloud 1.png"];
        cloud2 = [CCSprite spriteWithFile:@"Canyon cloud 2.png"];
        canyons = [CCSprite spriteWithFile:@"Canyons looped.png"];
        canyons.tag = 1;
        canyons2 = [CCSprite spriteWithFile:@"Canyons looped.png"];
        canyons2.tag = 2;
        
        // Speeds ratio for the objects in the parallax layer
        CGPoint cloudSpeed = ccp(0.5, 0);
        CGPoint bgSpeed = ccp(1.0, 1.0);
        
        // Add children to CCParallaxNode
        [backgroundNode addChild:canyons z:1 parallaxRatio:bgSpeed positionOffset:ccp(canyons.contentSize.width/2, canyons.contentSize.height/2)];
        [backgroundNode addChild:canyons2 z:1 parallaxRatio:bgSpeed positionOffset:ccp(canyons2.contentSize.width+380, canyons2.contentSize.height/2)];
        [backgroundNode addChild:cloud1 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(0,winSize.height/1.2)];
        [backgroundNode addChild:cloud2 z:1 parallaxRatio:cloudSpeed positionOffset:ccp(cloud1.contentSize.width+100,winSize.height/1.2)];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)dt
{
    // Incrementing the position of the background parallaxnode
    CGPoint backgroundScrollVel = ccp(-100, 0);
    backgroundNode.position = ccpAdd(backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    
    // Add continuous scroll for clouds
    NSArray *clouds = [NSArray arrayWithObjects:cloud1, cloud2, nil];
    for (CCSprite *cloud in clouds) {
        if ([backgroundNode convertToWorldSpace:cloud.position].x < -cloud.contentSize.width) {
            [backgroundNode incrementOffset:ccp(2*cloud.contentSize.width-[backgroundNode convertToWorldSpace:cloud.position].x,0) forChild:cloud];
        }
    }
    
    // Add continuous scroll for the canyon
    NSArray *backgrounds = [NSArray arrayWithObjects: canyons, canyons2, nil];
    for (CCSprite *bg in backgrounds) {
        if ([backgroundNode convertToWorldSpace:bg.position].x < -500) {
            [backgroundNode incrementOffset:ccp(100+bg.contentSize.width-[backgroundNode convertToWorldSpace:background.position].x,0) forChild:background];
        }
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}

@end
