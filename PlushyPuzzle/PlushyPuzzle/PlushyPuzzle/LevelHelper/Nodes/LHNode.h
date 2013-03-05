//
//  LHNode.h
//  
//
//  Created by Bogdan Vladu on 4/2/12.
//  Copyright (c) 2012 Bogdan Vladu. All rights reserved.
//

#import "CCNode.h"
#import "lhConfig.h"
#ifdef LH_USE_BOX2D
#include "Box2D.h"
#endif

@interface LHNode : CCNode
{
    NSString* uniqueName;
    
#ifdef LH_USE_BOX2D
    b2Body* body;
#endif
}

+(id)nodeWithDictionary:(NSDictionary*)dictionary;

#ifdef LH_USE_BOX2D
-(void)setBody:(b2Body*)body;
-(b2Body*)body;
#endif

//this methods are added here for kobold2d 2.0.4 collision handling class
//that class does not test for the node type and its asserting because it calls
//setColor without testing for it.
-(ccColor3B) color;
-(void) setColor:(ccColor3B)color3;

@end
