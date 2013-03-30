//
//  TransitionObject.m
//  CollisionTest
//
//  Created by Heaven Chen on 3/26/13.
//
//

#import "TransitionObject.h"

@implementation TransitionObject


+(TransitionObject*) objectSprite:(NSString *)shapeName spriteName:(NSString *)spriteName
{
    return [[[self alloc] initWithKinematicBody:shapeName spriteFrameName:spriteName] autorelease];
}

-(void)remove
{
    [[self ccNode] removeFromParentAndCleanup:YES];
    [self destroyBody];
}

@end
