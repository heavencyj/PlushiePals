//
//  LHAsset.m
//  Cocos2d2.1beta2 box2d
//
//  Created by Bogdan Vladu on 1/31/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "LHAsset.h"
#import "LHLayer.h"
#import "LHJoint.h"
#import "LHSprite.h"
#import "LHBezier.h"
#import "LHParallaxNode.h"
#import "LHPathNode.h"
#import "LHSettings.h"
#import "LevelHelperLoader.h"
@implementation LHAsset

-(id)initWithAssetFile:(NSString*)fileName{
    
    self = [super init];
    if (self != nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension]
                                                         ofType:@"plha"];
        
        NSAssert(nil!=path, @"Invalid asset file. Please add the LevelHelper asset file to Resource folder.");
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        jointsInAsset = [[NSMutableDictionary alloc] init];
        
        lhNodes = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"NODES_INFO"]];
		
        ///////////////////////LOAD JOINTS//////////////////////////////////////////////////////////
        lhJoints = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"JOINTS_INFO"]];        
    }
    return self;
}

-(void)registerLoadingProgressObserver:(id)object selector:(SEL)selector{
    loadingProgressId = object;
    loadingProgressSel = selector;
}
//------------------------------------------------------------------------------
-(void) callLoadingProgressObserverWithValue:(float)val
{
    if(loadingProgressId != nil && loadingProgressSel != nil)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [loadingProgressId performSelector:loadingProgressSel
                                withObject:[NSNumber numberWithFloat:val]];
#pragma clang diagnostic pop
    }
}


-(void)createAllNodesWithOffset:(CGPoint)offsetPoint
{
    CGPoint curOffset = [[LHSettings sharedInstance] userOffset];
    
    [[LHSettings sharedInstance] setUserOffset:offsetPoint];
    
    for(NSDictionary* dictionary in lhNodes)
    {
        if([[dictionary objectForKey:@"NodeType"] isEqualToString:@"LHLayer"]){
            LHLayer* layer = [LHLayer layerWithDictionary:dictionary];
            
            
            if(layer){
                [self addChild:layer z:[layer zOrder]];
                mainLayer = layer;
            }
        }
    }
    
    [[LHSettings sharedInstance] setUserOffset:curOffset];
}

-(void) createAllJoints{
    
#ifdef LH_USE_BOX2D
    for(NSDictionary* jointDict in lhJoints)
	{
        b2World* box2dWorld = [[LHSettings sharedInstance] activeBox2dWorld];
        
        LHJoint* joint = [LHJoint jointWithDictionary:jointDict
                                                world:box2dWorld
                                               loader:self];
        
        if(joint)
            [jointsInAsset setObject:joint
                              forKey:[jointDict objectForKey:@"UniqueName"]];
	}
#endif
}


-(void)createAssetWithOffsetedPosition:(CGPoint)offsetPoint{
    
    //order is important
    [self callLoadingProgressObserverWithValue:0.10];
    [self createAllNodesWithOffset:offsetPoint];
    [self callLoadingProgressObserverWithValue:0.80f];
    [self createAllJoints];
    [self callLoadingProgressObserverWithValue:1.0f];
}


-(LHLayer*)layerWithUniqueName:(NSString*)name{
    if([[mainLayer uniqueName] isEqualToString:name])
        return mainLayer;
    return [mainLayer layerWithUniqueName:name];
}
-(LHBatch*)batchWithUniqueName:(NSString*)name{
    return [mainLayer batchWithUniqueName:name];
}
-(LHSprite*)spriteWithUniqueName:(NSString*)name{
    return [mainLayer spriteWithUniqueName:name];
}
-(LHBezier*)bezierWithUniqueName:(NSString*)name{
    return [mainLayer bezierWithUniqueName:name];
}
-(LHJoint*) jointWithUniqueName:(NSString*)name{
    return [jointsInAsset objectForKey:name];
}
//------------------------------------------------------------------------------
-(NSArray*)allLayers{
    NSMutableArray* array = [NSMutableArray array];
    //[array addObject:mainLHLayer];//we dont give user access to the main lh layer
    [array addObjectsFromArray:[mainLayer allLayers]];
    return array;
}
-(NSArray*)allBatches{
    return [mainLayer allBatches];
}
-(NSArray*)allSprites{
    return [mainLayer allSprites];
}
-(NSArray*)allBeziers{
    return [mainLayer allBeziers];
}
-(NSArray*) allJoints{
    return [jointsInAsset allValues];
}
//------------------------------------------------------------------------------
-(NSArray*)layersWithTag:(int)tag{
    NSMutableArray* array = [NSMutableArray array];
    if(tag == [mainLayer tag])
        [array addObject:mainLayer];
    [array addObjectsFromArray:[mainLayer layersWithTag:tag]];
    return array;
}
-(NSArray*)batchesWithTag:(int)tag{
    return [mainLayer batchesWithTag:tag];
}
-(NSArray*)spritesWithTag:(int)tag{
    return [mainLayer spritesWithTag:tag];
}
-(NSArray*)beziersWithTag:(int)tag{
    return [mainLayer beziersWithTag:tag];
}
-(NSArray*) jointsWithTag:(int)tag{
    NSMutableArray* jointsWithTag = [NSMutableArray array];
	NSArray* joints = [jointsInAsset allValues];
	for(LHJoint* jt in joints){
        if([jt tag] == tag){
            [jointsWithTag addObject:jt];
        }
	}
    return jointsWithTag;
}


-(void)dealloc{
    
    [mainLayer removeAllChildrenWithCleanup:YES];
    [mainLayer removeSelf];
    mainLayer = nil;
    
#ifndef LH_ARC_ENABLED
    [jointsInAsset release];
    [lhNodes release];
    [lhJoints release];
    
    [super dealloc];
#endif

    jointsInAsset = nil;
    lhNodes = nil;
}
@end
