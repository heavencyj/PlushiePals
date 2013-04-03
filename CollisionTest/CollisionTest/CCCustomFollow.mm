//
//  CCCustomFollow.m
//  CollisionTest
//
//  Created by Lan Li on 3/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCCustomFollow.h"


@implementation CCCustomFollow

-(void) step:(ccTime) dt
{
	if(boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(boundaryFullyCovered)
			return;
        
		CGPoint tempPos = ccpSub( halfScreenSize, followedNode_.position);
		[target_ setPosition:ccp(clampf(tempPos.x,leftBoundary,rightBoundary), clampf(tempPos.y,bottomBoundary,topBoundary))];
	}
	else
    {
        //////
        CGPoint targetPos = ccpSub(halfScreenSize, followedNode_.position);
        const float kMinDistanceFromCenter = 60.0f;
        const float kMaxDistanceFromCenter = 80.0f;
        
        if(isCurrentPosValid == NO)
        {
            isCurrentPosValid = YES;
            currentPos = targetPos;
        }
        
        float distanceFromCenter = ccpLength(ccpSub(targetPos, currentPos));
//        NSLog(@"[CCCustomFollow: Distance from center: %f", distanceFromCenter);
//        NSLog(@"Follow node position: (%f, %f)", followedNode_.position.x, followedNode_.position.y);
        if (distanceFromCenter < kMaxDistanceFromCenter && distanceFromCenter > kMinDistanceFromCenter) {
            [target_ setPosition:ccpSub( halfScreenSize, followedNode_.position )];
            CGPoint deltaPos = ccpSub(targetPos, previousTargetPos);
            currentPos = ccpAdd(currentPos, deltaPos);
            [target_ setPosition:currentPos];
            //NSLog(@"Current position: (%f, %f)", ((CCNode*)target_).position.x, ((CCNode*)target_).position.y);
        }
        else if (distanceFromCenter > kMaxDistanceFromCenter)
        {
            [((GameScene*)target_) setPlushyIsDead:TRUE];
        }
        
        previousTargetPos = targetPos;
    }
}

@end
