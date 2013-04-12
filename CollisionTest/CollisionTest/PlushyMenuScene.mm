//
//  PlushyMenuScene.mm
//  Plushy
//
//  Created by Heaven Chen on 2/11/13.
//
//

#import "PlushyMenuScene.h"
#import "MainMenuScene.h"
#import "StatScene.h"

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
        CCSprite *background = [CCSprite spriteWithFile:@"Menu screen.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        CCMenuItemImage *momo = [CCMenuItemImage
                                 itemWithNormalImage:@"Momo icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(showStat)];
        momo.position = ccp(-winSize.width/3 , 0);
        
        CCMenuItemImage *cora = [CCMenuItemImage
                                 itemWithNormalImage:@"Cora icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(locked)];
        cora.position = ccp(0,0);
        
        CCMenuItemImage *hazel = [CCMenuItemImage
                                 itemWithNormalImage:@"Hazel icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(locked)];
        hazel.position = ccp(winSize.width/3, 0);
        
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(0,-winSize.height/3);
        
        CCMenu *menu = [CCMenu menuWithItems: momo, cora, hazel, home,nil];
        [menuLayer addChild: menu];
    }
    return self;
}

- (void)goHome {
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}

-(void)showStat {
    [[CCDirector sharedDirector] replaceScene:[StatScene scene]];
}

-(void)locked {
    
}

- (void) dealloc
{
    
    [super dealloc];
}
@end