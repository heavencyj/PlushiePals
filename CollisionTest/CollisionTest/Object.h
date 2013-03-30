//
//  Object.h
//  CollisionTest
//
//  Created by Lan Li on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GB2Sprite.h"

#define BANANA_BOMB 0
#define BANANA_BUNCH 1
#define SPIDER 2
#define CACTUS_BOMB 3

@interface Object : GB2Sprite {
    
    NSString *objName; //!< type of the object
    
    BOOL bodyTypeChange;
    BOOL contacted;
    BOOL animateBomb;
    int animPhase;        //!< the current animation phase
    ccTime animDelay;     //!< delay until the next animation phase is
}

@property (retain, nonatomic) NSString *objName;


/**
 * Creates an object with the given type
 * The name is used to determine object's sound,
 * sprite and physics shape
 *
 * @param objName name of the object.
 */
-(id) initWithObject:(NSString*)objName;

/**
 * Factory method will create a random object
 */
+(Object*) randomObject:(int)type;

-(void)changeType:(b2BodyType)type;
-(void)setSensor:(BOOL)isSensor;

@end
