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
}

+(TransitionObject*) objectSprite:(NSString *)shapeName spriteName:(NSString *)spriteName;
-(void)remove;

@end
