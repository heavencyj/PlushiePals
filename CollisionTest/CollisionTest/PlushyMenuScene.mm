//
//  PlushyMenuScene.mm
//  Plushy
//
//  Created by Heaven Chen on 2/11/13.
//
//

#import "PlushyMenuScene.h"
#import "MainMenuScene.h"

@implementation PlushyMenuScene

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    PlushyMenuScene *layer = [PlushyMenuScene node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"Character screen.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(0,-winSize.height/3);
        
        CCMenu *menu = [CCMenu menuWithItems: home,nil];
        [menuLayer addChild: menu];
    }
    return self;
}

- (void)goHome {
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}


- (void) dealloc
{
    
    [super dealloc];
}
@end