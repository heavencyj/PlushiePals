//
//  LHAsset.h
//  Cocos2d2.1beta2 box2d
//
//  Created by Bogdan Vladu on 1/31/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "cocos2d.h"

#import "lhConfig.h"

#ifdef LH_USE_BOX2D
#import "Box2D.h"
#endif

@class LHLayer;
@class LHBatch;
@class LHSprite;
@class LHBezier;
@class LHJoint;
@interface LHAsset : CCNode
{
    NSArray* lhNodes;	//array of NSDictionary //includes LHSprite, LHBezier, LHBatch, LHLayer
    NSArray* lhJoints;	//array of NSDictionary

    id  loadingProgressId;
    SEL loadingProgressSel;
    
    NSMutableDictionary* jointsInAsset;     //key - uniqueJointName     value - LHJoint*

    LHLayer* mainLayer;
}

//remember to release this object
//do not make it autorelease unless you retain the object somehow or the object will be released
//sprites and beziers in the asset will still be on screen because they are retained by the CCNode you load them in
-(id)initWithAssetFile:(NSString*)fileName;


//this should be called after loadAssetWithFileName and before createAssetInNode
-(void)registerLoadingProgressObserver:(id)object selector:(SEL)selector;

-(void)createAssetWithOffsetedPosition:(CGPoint)offsetPoint;



-(LHLayer*)layerWithUniqueName:(NSString*)name;
-(LHBatch*)batchWithUniqueName:(NSString*)name;
-(LHSprite*)spriteWithUniqueName:(NSString*)name;
-(LHBezier*)bezierWithUniqueName:(NSString*)name;
-(LHJoint*)jointWithUniqueName:(NSString*)name;
//------------------------------------------------------------------------------
-(NSArray*)allLayers;
-(NSArray*)allBatches;
-(NSArray*)allSprites;
-(NSArray*)allBeziers;
-(NSArray*)allJoints;
//------------------------------------------------------------------------------
-(NSArray*)layersWithTag:(int)tag;
-(NSArray*)batchesWithTag:(int)tag;
-(NSArray*)spritesWithTag:(int)tag;
-(NSArray*)beziersWithTag:(int)tag;
-(NSArray*)jointsWithTag:(int)tag;

@end


