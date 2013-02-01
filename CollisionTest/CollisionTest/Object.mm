//
//  Object.m
//  CollisionTest
//
//  Created by Lan Li on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Object.h"
#import "GB2Contact.h"

@implementation Object

@synthesize objName;

-(id) initWithObject:(NSString*)theObjName 
{
    self = [super initWithDynamicBody:theObjName
                      spriteFrameName:[NSString stringWithFormat:@"%@.png", theObjName]];
    if(self)
    {
        self.objName = theObjName;
    }
    return self;
}

+(Object*) randomObject
{
    NSString *objName;
    switch(rand() % 18)
    {
        case 0:
            objName = @"banana bomb";
            break;
            
        case 1:
            objName = @"banana bunch";
            break;
            
        case 2: case 3: case 5:
            objName = @"spider";
            break;
            
        default:
            objName = @"banana single";
            break;
    }
    return [[[self alloc] initWithObject:objName] autorelease];
}

-(void) beginContactWithMonkey:(GB2Contact*)contact
{
    //b2Vec2 velocity = [self linearVelocity];
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData();
    if([fixtureId isEqualToString:@"contact point"])
    {
        //NSLog(@"Something contacted object %@", (NSString *)contact.ownFixture->GetUserData());
        [[self ccNode] removeFromParentAndCleanup:YES];
    }
}

@end
