//
//  Hud.h
//  CollisionTest
//
//  Created by Lan Li on 3/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class PauseButton;

@interface Hud : CCLayer {
    CCLabelTTF* scoreLabel;
    
    CGRect pauseButtonRect;
    CCSprite *pauseButton;
}

@property (readonly) CCSprite *pauseButton;
@property (readonly) CGRect pauseButtonRect;
-(id) init;
-(void)updateScore:(int)score;
@end
