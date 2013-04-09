//
//  TransitionObject.h
//  CollisionTest
//
//  Created by Heaven Chen on 3/26/13.
//
//

#import "cocos2d.h"
#import "GB2Sprite.h"

@interface TransitionObject : GB2Sprite
{
    BOOL contacted_end;
    BOOL contacted_start;
}

+(TransitionObject*) transitionObjectSprite;
-(void)remove;
-(void)setBodyType:(b2BodyType)bodyType;
-(void)setBridgeBodySensor:(BOOL)sensor;
-(b2Body*)getBody;
@end
