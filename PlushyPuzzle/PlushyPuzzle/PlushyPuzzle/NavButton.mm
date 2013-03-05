//
//  NavButton.mm
//  PlushyPuzzle
//
//  Created by Lan Li on 2/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NavButton.h"

@implementation NavButton

//- (CGRect)rect
//{
//    if (rect.size.height == 0 && rect.size.width == 0) {
//        CGSize s = [self.texture contentSize];
//        rect = CGRectMake(self.position.x, self.position.y, s.width, s.height);
//    }
//    return rect;
//}

//+ (id)buttonWithTexture:(CCTexture2D *)normalTexture
//{
//    return [[[self alloc] initWithTexture:normalTexture] autorelease];
//}

+ (id)buttonWithTexture:(CCTexture2D *)normalTexture atPosition:(CGPoint)position
{
     return [[[self alloc] initWithTexture:normalTexture atPosition:position] autorelease];
}

- (void)setNormalTexture:(CCTexture2D *)normalTexture {
    buttonNormal = normalTexture;
}

- (void)setLitTexture:(CCTexture2D *)litTexture {
    buttonLit = litTexture;
}

//- (void)setLocation:(CGPoint)buttonPos{
//    location = buttonPos;
//    //TODO: move the location of the rect to this new position. 
//}

- (BOOL)isPressed {
    if (state == buttonStateNotPressed) return NO;
    if (state == buttonStatePressed) return YES;
    return NO;
}

- (BOOL)isNotPressed {
    if (state == buttonStateNotPressed) return YES;
    if (state == buttonStatePressed) return NO;
    return YES;
}

//TODO: init with the parent layer
- (id)initWithTexture:(CCTexture2D *)aTexture atPosition:(CGPoint)position
{
    if ((self = [super initWithTexture:aTexture]) ) {
        
        [self setNormalTexture:aTexture];
        state = buttonStateNotPressed;
        self.position = position;
    }
    return self;
}

- (void)onEnter
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
    [super onEnter];
}

- (void)onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    //TODO: update the position to check the button status
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.x >= self.position.x-[self.texture contentSize].width/2 && location.x <= self.position.x+[self.texture contentSize].width/2) {
        if (location.y >= self.position.y-[self.texture contentSize].height/2 && location.y <= self.position.y+[self.texture contentSize].height/2) {
            return YES;
        }
    }
    return NO;
}

// TODO: perhaps remove touch monitoring from NavButton? All the touch efforts will be conducted in the GameLayer?
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (state == buttonStatePressed) return NO;
    if ( ![self containsTouchLocation:touch] ) return NO;
    if (buttonStatus == buttonStatusDisabled) return NO;
    
    state = buttonStatePressed;
//    [self setTexture:buttonLit];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // If it weren't for the TouchDispatcher, you would need to keep a reference
    // to the touch from touchBegan and check that the current touch is the same
    // as that one.
    // Actually, it would be even more complicated since in the Cocos dispatcher
    // you get NSSets instead of 1 UITouch, so you'd need to loop through the set
    // in each touchXXX method.
    
    if ([self containsTouchLocation:touch]) return;
    //if (buttonStatus == buttonStatusDisabled) return NO;
    
    state = buttonStateNotPressed;
//    [self setTexture:buttonNormal];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    state = buttonStateNotPressed;
//    [self setTexture:buttonNormal];
}

@end
