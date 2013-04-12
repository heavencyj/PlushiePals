//
//  StatScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 4/12/13.
//
//

#import "StatScene.h"
#import "MainMenuScene.h"
#import "PlushyMenuScene.h"

@implementation StatScene

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    StatScene *layer = [StatScene node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"Scoreboard.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(-winSize.width/3,-winSize.height/3);
        
        CCMenuItemImage *plushies = [CCMenuItemImage
                    itemWithNormalImage:@"Plushy icon.png"
                    selectedImage:nil
                    target:self
                    selector:@selector(showPlushy)];
        plushies.position = ccp(-winSize.width/3+70,-winSize.height/3);
        
        CCMenu *menu = [CCMenu menuWithItems: home, plushies, nil];
        [menuLayer addChild: menu];
        

    }
    return self;
}

- (void)goHome {
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}

-(void)showPlushy {
    [[CCDirector sharedDirector] replaceScene:[PlushyMenuScene scene]];
}

- (void) dealloc
{
    
    [super dealloc];
}

@end

