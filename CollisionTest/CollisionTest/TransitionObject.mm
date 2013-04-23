//
//  TransitionObject.m
//  CollisionTest
//
//  Created by Heaven Chen on 3/26/13.
//
//

#import "TransitionObject.h"
#import "GB2Contact.h"
#import "RunningGameScene.h"
#import "Plushy.h"
#import "Maze.h"

@implementation TransitionObject


+(TransitionObject*) transitionObjectSprite
{
    return [[[self alloc] initWithDynamicBody:@"bridge" spriteFrameName:@"bridge.png"] autorelease];
}

-(void)remove
{
    [[self ccNode] removeFromParentAndCleanup:YES];
    [self destroyBody];
}

-(void) beginContactWithPlushy:(GB2Contact*)contact
{
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
//    if([fixtureId isEqualToString:@"bridgeend"]){
//        if (!contacted_end) {
//            contacted_end = TRUE;
//            //TODO: Setting the positioning the maze at the correct spot
//            ((Plushy*)contact.otherObject).showmap = YES;
//        }
//    }
//    else if([fixtureId isEqualToString:@"bridgestart"]){
//        if (!contacted_start) {
//            ((Plushy*)contact.otherObject).loadmap=YES;
//            contacted_start = TRUE;
//        }
//    }
    if([fixtureId isEqualToString:@"bridgestart"]){
        if (!contacted_start) {
            ((Plushy*)contact.otherObject).loadmap=YES;
            contacted_start = TRUE;
        }
    }
}

-(void)setBridgeBodySensor:(BOOL)sensor
{
    for (b2Fixture *f=body->GetFixtureList(); f->GetNext() != nil; f=f->GetNext()) {
        NSString *fixtureId = (NSString*)f->GetUserData();
        if ([fixtureId isEqualToString:@"bridge"]) {
            f->SetSensor(sensor);
            break;
        }
    }
}

-(void)setBodyType:(b2BodyType)bodyType
{
    body->SetType(bodyType);
}

-(b2Body*)getBody
{
    return body;
}

- (void) dealloc
{
	[super dealloc];
}

@end
