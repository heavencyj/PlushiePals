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

@interface Object : GB2Sprite {
    
    NSString *objName; //!< type of the object
    BOOL collideWPlushy;
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
+(Object*) randomObject;

@end
