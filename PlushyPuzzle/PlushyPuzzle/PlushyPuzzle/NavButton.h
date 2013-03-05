//
//  NavButton.h
//  PlushyPuzzle
//
//  Created by Lan Li on 2/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum tagButtonState {
    buttonStatePressed,
    buttonStateNotPressed
} ButtonState;

typedef enum tagButtonStatus {
    buttonStatusEnabled,
    buttonStatusDisabled
} ButtonStatus;

@interface NavButton : CCSprite <CCTargetedTouchDelegate> {
@private
    ButtonState state;
    CCTexture2D *buttonNormal;
    CCTexture2D *buttonLit;
    ButtonStatus buttonStatus;
//    CGRect rect;
}

//@property(nonatomic, readonly) CGRect rect;

+ (id)buttonWithTexture:(CCTexture2D *)normalTexture atPosition:(CGPoint)position;
- (void)setNormalTexture:(CCTexture2D *)normalTexture;
- (void)setLitTexture:(CCTexture2D *)litTexture;
- (BOOL)containsTouchLocation:(UITouch *)touch;
- (BOOL)isPressed;
- (BOOL)isNotPressed;

@end
