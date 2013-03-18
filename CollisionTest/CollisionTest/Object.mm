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
#import "Maze.h"

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

+(Object*) randomObject:(int)type
{
    NSString *objName;
    switch(type)
    {
        case BANANA_BOMB:
            objName = @"banana bomb";
            break;
        
        case BANANA_BUNCH:
            objName = @"banana bunch";
            break;

        case SPIDER:
            objName = @"spider";
            break;
        default:
            objName = @"banana single";
            break;
    }
    return [[[self alloc] initWithObject:objName] autorelease];
}

-(void)changeType:(b2BodyType)type
{
    body->SetType(type);
}

-(void) beginContactWithPlushy:(GB2Contact*)contact
{
    NSString *fixtureId = (NSString *)contact.ownFixture->GetUserData(); 
    if ([fixtureId isEqualToString:@"bomb"]) {
        // speed up the maze
        Maze *maze = ((Plushy*)[contact otherObject]).gameLayer.maze;
        [maze setLinearVelocity:b2Vec2(maze.linearVelocity.x-0.5, maze.linearVelocity.y)];
    }
    else
    {
        ((Plushy*)[contact otherObject]).bananaScore += 1;
    }
    [[self ccNode] removeFromParentAndCleanup:YES];
}

-(void) beginContactWithMaze:(GB2Contact*)contact
{
    [[self ccNode] removeFromParentAndCleanup:YES];
}

@end
