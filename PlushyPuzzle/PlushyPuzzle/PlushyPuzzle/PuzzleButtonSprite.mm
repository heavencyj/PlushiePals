//
//  ButtonSprite.m
//  PlushyPuzzle
//
//  Created by Lan Li on 2/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PuzzleButtonSprite.h"
#import "LHJoint.h"
#import "LHTouchMgr.h"

#define PTM_RATIO 32.0

@implementation PuzzleButtonSprite

@synthesize puzzlePiece;

- (LHSprite*)puzzlePiece
{
    if (!puzzlePiece) {
//        NSLog(@"button sprite unique name: %@", [self uniqueName]);
        unichar spriteNumber = [[self uniqueName] characterAtIndex:([self uniqueName].length-1)];
//        NSLog(@"joint name: %@", [NSString stringWithFormat:@"puzzle joint %c", spriteNumber]);
        LHJoint *puzzleJoint = [self jointWithUniqueName:[NSString stringWithFormat:@"puzzle joint %c", spriteNumber]];
        self.puzzlePiece = (LHSprite*)[puzzleJoint spriteA];
    }
    return puzzlePiece;
}

////////////////////////////////////////////////////////////////////////////////

-(void) dealloc{
	[super dealloc];
}

-(void) ownSpriteInit{
    //initialize your member variabled here
    [self addObserver:self forKeyPath:@"state" options:0 context:nil]; 
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

+(bool) isPuzzleButtonSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[PuzzleButtonSprite class]];
}

// Private Methods ------------------------------------------------------------------------

//-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (object == self && [keyPath isEqualToString:@"state"]) {
//        NSLog(@"OtherVC: The value of button press state has changed");
//        // If the button is pressed, start rotating the corresponding puzzlePiece
//        // Else if the button is no longer pressed, set button rotation to zero, or set rotation to be fixed
//    }
//}

- (void) rotatePuzzlePiece
{
    // Unfix body rotation.
    [self.puzzlePiece body]->SetAngularVelocity(5);
    [self.puzzlePiece body]->SetFixedRotation(0);
}

- (void) stopRotatePuzzlePiece
{
    [self.puzzlePiece body]->SetAngularVelocity(0);
    [self.puzzlePiece body]->SetFixedRotation(1);
}

////////////////////////////////// Touch Events ////////////////////////////////////////
//- (BOOL)containsTouchLocation:(UITouch *)touch
//{
//    // Check to see if the touch location falls within the current location of the button.
//    CGPoint location = [touch locationInView:[touch view]];
//    location = [[CCDirector sharedDirector] convertToGL:location];
////    CGPoint nodePosition = [self convertToNodeSpace:location];
//    float x = self.body->GetPosition().x*PTM_RATIO;
//    float y = self.body->GetPosition().y*PTM_RATIO;
////    NSLog(@"Touch location: (%f, %f)", location.x, location.y);
////    NSLog(@"Touch node position: (%f, %f)", nodePosition.x, nodePosition.y);
////    NSLog(@"Object location: (%f, %f)", x, y);
////    NSLog(@"X bound: (%f, %f)", x-self.boundingBox.size.width/2, x+self.boundingBox.size.width/2);
////    NSLog(@"Y bound: (%f, %f)", y-self.boundingBox.size.height/2, y+self.boundingBox.size.height/2);
//    if (location.x >= x-self.boundingBox.size.width/2 && location.x <= x+self.boundingBox.size.width/2) {
//        if (location.y >= y-self.boundingBox.size.height/2 && location.y <= y+self.boundingBox.size.height/2) {
//            return YES;
//        }
//    }
//    return NO;
//}

-(void) onEnter
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
    state = buttonNotPressed;
    [super onEnter];
}

-(void) onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}


//- (void)touchBegan:(LHTouchInfo*)info
//{
//    NSLog(@"TOUCH BEGINS ON BUTTON SPRITE!!");
//}
//
//- (void)touchMoved:(LHTouchInfo*)info
//{
//    NSLog(@"TOUCH MOVED ON BUTTON SPRITE!");
//}
//
//- (void)touchEnded:(LHTouchInfo*)info
//{
//    NSLog(@"Hello?");
//}

//-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    if ([self containsTouchLocation:touch]){
//        state = buttonPressed;
//        NSLog(@"Button name: %@", self.uniqueName);
////        NSLog(@"string found: %d", [self.uniqueName rangeOfString:@"red"].location);
//        if ([self.uniqueName rangeOfString:@"red"].location == NSNotFound && [self.uniqueName rangeOfString:@"blue"].location == NSNotFound) {
//            [self rotatePuzzlePiece];
//        }
//    }
//    else {
////        NSLog(@"Not pressed");
//        state = buttonNotPressed;
//    }
//    return 1;
//}
//
//-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    if (state == buttonPressed) {
//        state = buttonNotPressed;
//        if ([self.uniqueName rangeOfString:@"red"].location == NSNotFound && [self.uniqueName rangeOfString:@"blue"].location == NSNotFound) {
//            [self stopRotatePuzzlePiece];
//        }
//    }
//}

- (BOOL)isPressed {
    if (state == buttonNotPressed) return NO;
    if (state == buttonPressed) return YES;
    return NO;
}

@end
