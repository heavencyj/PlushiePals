//
//  ActionLayer.m
//  Plushy
//
//  Created by Heaven Chen on 2/10/13.
//
//

#import "ActionLayer.h"
#import "LevelHelperLoader.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

@implementation ActionLayer


+ (id)scene {
  CCScene *scene = [CCScene node];
  
  ActionLayer *layer = [ActionLayer node];
  [scene addChild:layer];
  
  // adding debug draw layer
  //debugDraw = new GLESDebugDraw( PTM_RATIO );
  
  return scene;
}

- (id)init {
 	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		//[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -5.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		debugDraw = new GLESDebugDraw();
		world->SetDebugDraw(debugDraw);
		
		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
		debugDraw->SetFlags(flags);
    
		[self schedule: @selector(tick:) interval:1.0f/60.0f];
		
    //TUTORIAL - loading one of the levels - test each level to see how it works
    lh = [[LevelHelperLoader alloc] initWithContentOfFile:@"level1"];
    
    //creating the objects
    [lh addObjectsToWorld:world cocos2dLayer:self];
    
    if([lh hasPhysicBoundaries])
      [lh createPhysicBoundaries:world];
    
    if(![lh isGravityZero])
      [lh createGravity:world];
    
	}
	return self;
}

-(void) tick: (ccTime) dt
{
	[self step:dt];
  
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL)
    {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
      
      if(myActor != 0)
      {
        //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
        myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
        myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
      }
      
    }
	}
}

-(void)afterStep {
	// process collisions and result from callbacks called by the step
}
////////////////////////////////////////////////////////////////////////////////
-(void)step:(ccTime)dt {
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
	world->ClearForces ();
}

- (void) dealloc
{
  if(nil != lh)
    [lh release];
  
	delete world;
	world = NULL;
	
  delete debugDraw;
  
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end