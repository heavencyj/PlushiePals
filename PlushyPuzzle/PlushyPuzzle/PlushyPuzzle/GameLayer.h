//
//  HelloWorldLayer.h
//  PlushyPuzzle
//
//  Created by Lan Li on 2/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LevelHelperLoader.h"
#import "PlayerSprite.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
@class ButtonSprite;
@class Hud;
@class PlayerSprite;

// HelloWorldLayer
@interface GameLayer : CCLayer
{
    b2World *world;
	GLESDebugDraw *m_debugDraw;		// strong ref
    LevelHelperLoader *loader;
    
    Hud *hud;
    
    PlayerSprite *playerSprite;
    
    ccTime timeStep;
}

@property(nonatomic, retain) LevelHelperLoader *loader;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
//- (void)touchEnded:(LHTouchInfo*)info;
//- (void)touchMoved:(LHTouchInfo*)info;

@end
