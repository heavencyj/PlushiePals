//  This file was generated by LevelHelper
//  http://www.levelhelper.org
//
//  LevelHelperLoader.mm
//  Created by Bogdan Vladu
//  Copyright 2011 Bogdan Vladu. All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  This notice may not be removed or altered from any source distribution.
//  By "software" the author refers to this code file and not the application 
//  that was used to generate this file.
//
////////////////////////////////////////////////////////////////////////////////

#import "LHTouchMgr.h"
#import "cocos2d.h"
#import "LHSprite.h"
#import "LHBezier.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
@implementation LHTouchInfo
@synthesize relativePoint;
@synthesize glPoint;
@synthesize delta;
@synthesize event;
@synthesize touch;
@synthesize sprite;
@synthesize bezier;
-(id)initLHTouchInfo{
    self = [super init];
	if (self != nil){
        sprite = nil;
        bezier = nil;
        event = nil;
        touch = nil;
        relativePoint = CGPointZero;
        glPoint = CGPointZero;
        delta = CGPointZero;
	}
	return self;
}
+(id)touchInfo{
#ifndef LH_ARC_ENABLED
    return [[[LHTouchInfo alloc] initLHTouchInfo] autorelease];
#else
    return [[LHTouchInfo alloc] initLHTouchInfo];
#endif
}
@end
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
@implementation LHObserverPair
@synthesize object;
@synthesize selector;
//------------------------------------------------------------------------------
-(id)initObserverPair{
    self = [super init];
	if (self != nil){
        object = nil;
        selector = nil;
	}
	return self;
}
//------------------------------------------------------------------------------


+(id)observerPair{
#ifndef LH_ARC_ENABLED
    return [[[LHObserverPair alloc] initObserverPair] autorelease];    
#else
    return [[LHObserverPair alloc] initObserverPair];    
#endif
}
//------------------------------------------------------------------------------
+(void)performObserverPair:(LHObserverPair*)pair object:(id)info{
    if(pair && pair.object){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [pair.object performSelector:pair.selector 
                                        withObject:info];
#pragma clang diagnostic pop        
    }        

}
@end
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


@implementation LHTouchMgr
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
+ (LHTouchMgr*)sharedInstance{
	static id sharedInstance = nil;
	if (sharedInstance == nil){
		sharedInstance = [[LHTouchMgr alloc] init];
	}
    return sharedInstance;
}
//------------------------------------------------------------------------------
-(void)dealloc
{
#ifndef LH_ARC_ENABLED
    if(onTouchBeginOnSpriteOfTag)
        [onTouchBeginOnSpriteOfTag release];
    onTouchBeginOnSpriteOfTag = nil;
    if(onTouchMovedOnSpriteOfTag)
        [onTouchMovedOnSpriteOfTag release];
    onTouchMovedOnSpriteOfTag = nil;
    if(onTouchEndedOnSpriteOfTag)
        [onTouchEndedOnSpriteOfTag release];
    onTouchEndedOnSpriteOfTag = nil;

    if(swallowTouchesOnTag)
        [swallowTouchesOnTag release];
    swallowTouchesOnTag = nil;

    if(priorityForTouchesOfTag)
        [priorityForTouchesOfTag release];
    priorityForTouchesOfTag = nil;
    
	[super dealloc];
#endif
}
//------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self != nil) {
        onTouchBeginOnSpriteOfTag = nil;
        onTouchMovedOnSpriteOfTag = nil;
        onTouchEndedOnSpriteOfTag = nil;
        swallowTouchesOnTag = nil;
        priorityForTouchesOfTag = nil;
	}
	return self;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(void) setPriority:(int)priority forTouchesOfTag:(int)tag{
    if(priorityForTouchesOfTag == nil)
        priorityForTouchesOfTag = [[NSMutableDictionary alloc] init];
    
    [priorityForTouchesOfTag setObject:[NSNumber numberWithInt:priority] 
                                forKey:[NSNumber numberWithInt:tag]];
}
//------------------------------------------------------------------------------
-(void) swallowTouchesForTag:(int)tag{

    if(swallowTouchesOnTag == nil)
        swallowTouchesOnTag = [[NSMutableDictionary alloc] init];
    
    [swallowTouchesOnTag setObject:[NSNumber numberWithBool:TRUE] 
                            forKey:[NSNumber numberWithInt:tag]];
}
//------------------------------------------------------------------------------
-(void)registerTouchBeginObserver:(id)observer selector:(SEL)selector 
                forTag:(int)tag{
    [self registerTouchBeganObserver:observer selector:selector forTag:tag];
}

-(void)registerTouchBeganObserver:(id)observer selector:(SEL)selector forTag:(int)tag{
    
    if(onTouchBeginOnSpriteOfTag == nil)
        onTouchBeginOnSpriteOfTag = [[NSMutableDictionary alloc] init];
    
    [onTouchBeginOnSpriteOfTag removeObjectForKey:[NSNumber numberWithInt:(int)tag]];
    
    LHObserverPair* pair = [LHObserverPair observerPair];
    pair.object = observer;
    pair.selector = selector;
    [onTouchBeginOnSpriteOfTag setObject:pair 
                                  forKey:[NSNumber numberWithInt:(int)tag]];
}
-(void)registerTouchMovedObserver:(id)observer selector:(SEL)selector 
                forTag:(int)tag{
    if(onTouchMovedOnSpriteOfTag == nil)
        onTouchMovedOnSpriteOfTag = [[NSMutableDictionary alloc] init];
    
    [onTouchMovedOnSpriteOfTag removeObjectForKey:[NSNumber numberWithInt:(int)tag]];

    LHObserverPair* pair = [LHObserverPair observerPair];
    pair.object = observer;
    pair.selector = selector;
    [onTouchMovedOnSpriteOfTag setObject:pair 
                                  forKey:[NSNumber numberWithInt:(int)tag]];
}
-(void)registerTouchEndedObserver:(id)observer selector:(SEL)selector 
                forTag:(int)tag{
    if(onTouchEndedOnSpriteOfTag == nil)
        onTouchEndedOnSpriteOfTag = [[NSMutableDictionary alloc] init];
    
    [onTouchEndedOnSpriteOfTag removeObjectForKey:[NSNumber numberWithInt:(int)tag]];

    LHObserverPair* pair = [LHObserverPair observerPair];
    pair.object = observer;
    pair.selector = selector;
    [onTouchEndedOnSpriteOfTag setObject:pair 
                                  forKey:[NSNumber numberWithInt:(int)tag]];    
}
//removing touch begin observer will remove all other observers also
-(void)removeTouchBeginObserver:(id)observer{
    
    if(onTouchBeginOnSpriteOfTag == nil)
        return;
    
    NSArray* keys = [onTouchBeginOnSpriteOfTag allKeys];
    
    for(NSNumber* key in keys){
        LHObserverPair* pair = [onTouchBeginOnSpriteOfTag objectForKey:key];
        if(pair.object == observer){
            [onTouchBeginOnSpriteOfTag removeObjectForKey:key];
        }
    }

    [self removeTouchMovedObserver:observer];
    [self removeTouchEndedObserver:observer];
}
-(void)removeTouchMovedObserver:(id)observer{

    if(onTouchMovedOnSpriteOfTag == nil)
        return;
    
    NSArray* keys = [onTouchMovedOnSpriteOfTag allKeys];
    
    for(NSNumber* key in keys){
        LHObserverPair* pair = [onTouchMovedOnSpriteOfTag objectForKey:key];
        if(pair.object == observer){
            [onTouchMovedOnSpriteOfTag removeObjectForKey:key];
        }
    }
}
-(void)removeTouchEndedObserver:(id)observer{
    
    if(onTouchEndedOnSpriteOfTag == nil)
        return;
    
    NSArray* keys = [onTouchEndedOnSpriteOfTag allKeys];
    
    for(NSNumber* key in keys){
        LHObserverPair* pair = [onTouchEndedOnSpriteOfTag objectForKey:key];
        if(pair.object == observer){
            [onTouchEndedOnSpriteOfTag removeObjectForKey:key];
        }
    }
}

//------------------------------------------------------------------------------
-(LHObserverPair*)onTouchBeginObserverForTag:(int)tag{
    if(onTouchBeginOnSpriteOfTag){
        return [onTouchBeginOnSpriteOfTag objectForKey:[NSNumber numberWithInt:tag]];
    }
    return nil;
}
-(LHObserverPair*)onTouchMovedObserverForTag:(int)tag{
    if(onTouchMovedOnSpriteOfTag){
        return [onTouchMovedOnSpriteOfTag objectForKey:[NSNumber numberWithInt:tag]];
    }
    return nil;    
}
-(LHObserverPair*)onTouchEndedObserverForTag:(int)tag{
    if(onTouchEndedOnSpriteOfTag){
        return [onTouchEndedOnSpriteOfTag objectForKey:[NSNumber numberWithInt:tag]];
    }
    return nil;        
}
//------------------------------------------------------------------------------
-(bool)shouldTouchesBeSwallowedForTag:(int)tag{
    if(swallowTouchesOnTag){
        if(nil != [swallowTouchesOnTag objectForKey:[NSNumber numberWithInt:tag]])
            return true;
    }
    return false;
}
//------------------------------------------------------------------------------
-(int)priorityForTag:(int)tag{
    if(priorityForTouchesOfTag){
        NSNumber* nr = [priorityForTouchesOfTag objectForKey:[NSNumber numberWithInt:tag]];
        if(nr)
            return [nr intValue];
    }
    return 0;
}

@end
