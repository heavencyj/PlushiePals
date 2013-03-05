//
//  RaycastCallback.h
//  PlushyPuzzle
//
//  Created by Allen Benson G Tan on 5/21/12.
//  Copyright (c) 2012 WhiteWidget Inc. All rights reserved.
//

#ifndef CutCutCut_RaycastCallback_h
#define CutCutCut_RaycastCallback_h

#import "Box2D.h"
#import "PuzzleSprite.h"
#import "LHSprite.h"

#define collinear(x1,y1,x2,y2,x3,y3) fabsf((y1-y2) * (x1-x3) - (y1-y3) * (x1-x2))
#define JUMP_IMPULSE 6.0f
extern float PTM_RATIO;

class RaycastCallback : public b2RayCastCallback
{
public:
    RaycastCallback(){
    }
    
    float32 ReportFixture(b2Fixture *fixture,const b2Vec2 &point,const b2Vec2 &normal,float32 fraction)
    {
        LHSprite *lhs = (LHSprite*)fixture->GetBody()->GetUserData();
        // Tap to jump.
        if ([[lhs uniqueName] isEqualToString:@"Monkey"]) {
            float impluseFactor = 0.6;
            b2Body *monkeyShape = [lhs body];
            monkeyShape->ApplyLinearImpulse(b2Vec2(0, monkeyShape->GetMass()*JUMP_IMPULSE*impluseFactor), monkeyShape->GetWorldCenter());
        }
        // Detecting left and right swipes
        else
        {
            PuzzleSprite *puzzlePiece = (PuzzleSprite*)lhs;
            if (!puzzlePiece.swipeEntry) {
                puzzlePiece.swipeEntry = YES;
                puzzlePiece.swipeExit = NO;
                puzzlePiece.entryPoint = puzzlePiece.body->GetLocalPoint(point);
                NSLog(@"Entry point is (%f, %f)", puzzlePiece.entryPoint.x, puzzlePiece.entryPoint.y);
            }
            else if (!puzzlePiece.swipeExit)
            {
                puzzlePiece.exitPoint = puzzlePiece.body->GetLocalPoint(point);
                if (puzzlePiece.entryPoint.x-puzzlePiece.exitPoint.x > 0) {
                    [lhs body]->SetTransform([lhs body]->GetPosition(), -1*CC_DEGREES_TO_RADIANS(90)+[puzzlePiece body]->GetAngle());
                }
                else
                {
                    [lhs body]->SetTransform([lhs body]->GetPosition(), -1*(-1*CC_DEGREES_TO_RADIANS(90)+[lhs body]->GetAngle()));
                }
                puzzlePiece.swipeEntry = NO;
                puzzlePiece.swipeExit = YES;
                NSLog(@"Exit point is (%f, %f)", puzzlePiece.exitPoint.x, puzzlePiece.exitPoint.y);
            }
        }
        
        return 1;
    }
};

#endif


