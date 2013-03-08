//
//  Object.m
//  CollisionTest
//
//  Created by Lan Li on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Object.h"
#import "GB2Contact.h"
#import "Plushy.h"

@implementation Object

@synthesize objName;

-(id) initWithObject:(NSString*)theObjName 
{
    self = [super initWithKinematicBody:theObjName
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
//        case 0:
//            objName = @"banana bomb";
//            break;
        
//        case 1:
//            objName = @"banana bunch";
//            break;
            
//        case 2: case 3: case 5:
//            objName = @"spider";
//            break;
        
        default:
            objName = @"banana single";
            break;
    }
    return [[[self alloc] initWithObject:objName] autorelease];
}

-(void) beginContactWithPlushy:(GB2Contact*)contact
{
    if (!collideWPlushy) {
        ((Plushy*)[contact otherObject]).bananaScore += 1;
        [[self ccNode] removeFromParentAndCleanup:YES];
        collideWPlushy = TRUE;
    }
}

-(void) beginContactWithMaze:(GB2Contact*)contact
{
    [[self ccNode] removeFromParentAndCleanup:YES];
}

@end
