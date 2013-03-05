//
//  PlayerSprite.m
//  PlushyPuzzle
//
//  Created by Lan Li on 2/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PlayerSprite.h"

#define JUMP_IMPULSE 6.0f

@implementation PlayerSprite

////////////////////////////////////////////////////////////////////////////////

-(void) dealloc{
	[super dealloc];
}

-(void) ownSpriteInit{
    //initialize your member variabled here
}

-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteInit];
    }
    return self;
}

-(void)postInit{
    //do whatever you need here - at this point you will have all the info
}

+(id)spriteWithDictionary:(NSDictionary*)dictionary{
    return [[[self alloc] initWithDictionary:dictionary] autorelease];
}

+(id)batchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    return [[[self alloc] initBatchSpriteWithDictionary:dictionary batch:batch] autorelease];
}

-(id)initWithDictionary:(NSDictionary*)dictionary{
    self = [super initWithDictionary:dictionary];
    if (self != nil){
        [self ownSpriteInit];
    }
    return self;
}

-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteInit];
    }
    return self;
}

+(bool) isPlayerSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[PlayerSprite class]];
}

////////////////////////////////// Movements ////////////////////////////////////////
-(void) jump
{
    float impulseFactor = 1.0;
    [self body]->ApplyLinearImpulse(b2Vec2(0,[self body]->GetMass()*JUMP_IMPULSE*impulseFactor), [self body]->GetWorldCenter());
    
    //    [[SimpleAudioEngine sharedEngine] playEffect:@"jump.caf"
    //                                           pitch:gFloatRand(0.8,1.2)
    //                                             pan:(self.ccNode.position.x-240.0f) / 240.0f
    //                                            gain:1.0 ];
}

-(void) move:(const b2Vec2)speed
{
    float velChange = speed.x - [self body]->GetLinearVelocity().x;
    float impulse = [self body]->GetMass() * velChange;
    [self body]->ApplyLinearImpulse(b2Vec2(impulse,0), [self body]->GetWorldCenter());
//    if ([self body]->GetLinearVelocity() == b2Vec2(0, 0)) {
////        [self body]->SetLinearVelocity(speed);
//        float velChange = speed.x - [self body]->GetLinearVelocity().x;
//        float impulse = [self body]->GetMass() * velChange;
//        [self body]->ApplyLinearImpulse(b2Vec2(impulse,0), [self body]->GetWorldCenter());
//        
//        //TODO: Add sound and animation 
//    }
}

-(void)loadRunAnimation
{
    [self prepareAnimationNamed:@"Monkey_running" fromSHScene:@"Animations"];
}

-(void)loadJumpAnimation
{
    [self prepareAnimationNamed:@"Monkey_jumping" fromSHScene:@"Animations"];
}

-(void)loadDieAnimation
{
    [self prepareAnimationNamed:@"Monkey_dying" fromSHScene:@"Animations"];
}
////////////////////////////////// Touch Events ////////////////////////////////////////
-(void) onEnter
{
//    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
    [super onEnter];
}

-(void) onExit
{
//    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

@end
