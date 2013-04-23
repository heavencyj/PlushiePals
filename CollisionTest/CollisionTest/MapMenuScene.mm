//
//  MapMenuScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 4/22/13.
//
//

#import "MapMenuScene.h"
#import "MainMenuScene.h"
#import "GameData.h"
#import "RunningGameScene.h"
#import "BackStoryScene.h"

@implementation MapMenuScene

CCMenuItemImage *momo;
CCMenuItemImage *cora;
CCMenuItemImage *hazel;

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    MapMenuScene *layer = [MapMenuScene node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"Map.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];        
        
        CCMenuItemImage *canyonIcon = [CCMenuItemImage
                                 itemWithNormalImage:@"Clove Canyon.png"
                                 selectedImage:nil
                                 target:self
                                selector:@selector(startGame:)];
        canyonIcon.position = ccp(-200, -10);
        canyonIcon.tag = 1;
        id moveIconDown1 = [CCMoveBy actionWithDuration:0.9 position:ccp(0, -30)];
        id moveIconUp1 = [CCMoveBy actionWithDuration:0.9 position:ccp(0, 30)];
        id seq1 = [CCSequence actions:moveIconDown1,moveIconUp1, nil];
        [canyonIcon runAction:[CCRepeatForever actionWithAction:seq1]];
        
        CCMenuItemImage *mountainIcon = [CCMenuItemImage
                                       itemWithNormalImage:@"Mulberry Mountains.png"
                                       selectedImage:nil
                                       target:self
                                       selector:@selector(startGame:)];
        mountainIcon.position = ccp(-80, -20);
        mountainIcon.tag = 2;
        id moveIconDown2 = [CCMoveBy actionWithDuration:1.1 position:ccp(0, -30)];
        id moveIconUp2 = [CCMoveBy actionWithDuration:1.1 position:ccp(0, 30)];
        id seq2 = [CCSequence actions:moveIconDown2,moveIconUp2, nil];
        [mountainIcon runAction:[CCRepeatForever actionWithAction:seq2]];
        
        CCMenuItemImage *hillIcon = [CCMenuItemImage
                                       itemWithNormalImage:@"Ivyhill.png"
                                       selectedImage:nil
                                       target:self
                                       selector:@selector(showBackstory)];
        hillIcon.position = ccp(-200, -100);
        hillIcon.tag = 3;
        id moveIconDown3 = [CCMoveBy actionWithDuration:1 position:ccp(0, -30)];
        id moveIconUp3 = [CCMoveBy actionWithDuration:1 position:ccp(0, 30)];
        id seq3 = [CCSequence actions:moveIconDown3,moveIconUp3, nil];
        [hillIcon runAction:[CCRepeatForever actionWithAction:seq3]];
        
        CCMenuItemImage *islandIcon = [CCMenuItemImage
                                     itemWithNormalImage:@"Sneezewort Island.png"
                                     selectedImage:nil
                                     target:self
                                     selector:@selector(doNothing)];
        islandIcon.position = ccp(200, 50);
        islandIcon.tag = 4;
        
        CCMenuItemImage *jungleIcon = [CCMenuItemImage
                                       itemWithNormalImage:@"Juniper Jungle.png"
                                       selectedImage:nil
                                       target:self
                                       selector:@selector(startGame:)];
        jungleIcon.position = ccp(30, -90);
        jungleIcon.tag = 5;
        id moveIconDown5 = [CCMoveBy actionWithDuration:1.05 position:ccp(0, -30)];
        id moveIconUp5 = [CCMoveBy actionWithDuration:1.05 position:ccp(0, 30)];
        id seq5 = [CCSequence actions:moveIconDown5,moveIconUp5, nil];
        [jungleIcon runAction:[CCRepeatForever actionWithAction:seq5]];
        
        
        momo = [CCMenuItemImage
                   itemWithNormalImage:@"Momo icon.png"
                   selectedImage:nil
                   target:self
                   selector:@selector(pickPlushy:)];
        momo.position = ccp(-winSize.width/2+30, winSize.height/2-30);
        momo.tag = 1;
        
        cora = [CCMenuItemImage
                itemWithNormalImage:@"Cora icon.png"
                selectedImage:nil
                target:self
                selector:@selector(pickPlushy:)];
        cora.position = ccp(-winSize.width/2+30+50, winSize.height/2-30);
        cora.tag = 2;
        
        hazel = [CCMenuItemImage
                itemWithNormalImage:@"Hazel icon.png"
                selectedImage:nil
                target:self
                selector:@selector(pickPlushy:)];
        hazel.position = ccp(-winSize.width/2+30+100, winSize.height/2-30);
        hazel.tag = 3;
        
        [self checkPlushy];
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(220, -100);
    
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        CCMenu *menu = [CCMenu menuWithItems:momo, cora, hazel, home,canyonIcon, mountainIcon,
                        hillIcon,islandIcon, jungleIcon, nil];
        [menuLayer addChild: menu];
        
        
       
    }
    return self;
}

- (void)goHome {
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}

-(void)startGame:(id)sender
{
    CCMenuItemImage *button = (CCMenuItemImage *)sender;
    [GameData sharedGameData].mapTheme = button.tag;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[GameData sharedGameData].mapTheme forKey:@"mapTheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[CCDirector sharedDirector] replaceScene:[RunningGameScene scene]];
}

-(void)showBackstory
{
    [[CCDirector sharedDirector] replaceScene:[BackStoryScene scene]];
}

-(void)checkPlushy
{
    switch ([GameData sharedGameData].plushy) {
        case 1:
            [momo setNormalImage:[CCSprite spriteWithFile:@"Momo icon large.png"]];
            [cora setNormalImage:[CCSprite spriteWithFile:@"Cora icon.png"]];
            [hazel setNormalImage:[CCSprite spriteWithFile:@"Hazel icon.png"]];
            break;
            
        case 2:
            [cora setNormalImage:[CCSprite spriteWithFile:@"Cora icon large.png"]];
            [momo setNormalImage:[CCSprite spriteWithFile:@"Momo icon.png"]];
            [hazel setNormalImage:[CCSprite spriteWithFile:@"Hazel icon.png"]];
            break;
            
        case 3:
            [hazel setNormalImage:[CCSprite spriteWithFile:@"Hazel icon large.png"]];
            [momo setNormalImage:[CCSprite spriteWithFile:@"Momo icon.png"]];
            [cora setNormalImage:[CCSprite spriteWithFile:@"Cora icon.png"]];
            break;
            
        default:
            break;
    }
    
}

-(void)pickPlushy:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    CCMenuItemImage *button = (CCMenuItemImage *)sender;
    [GameData sharedGameData].plushy = button.tag;
    [defaults setInteger:[GameData sharedGameData].plushy forKey:@"plushy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkPlushy];
}

-(void)doNothing
{
    
}

- (void) dealloc
{
    
    [super dealloc];
}
@end