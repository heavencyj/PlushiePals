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
#import "GameData.h"

@implementation PlushyMenuScene

CCLayer* missionLayer;

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
        
        CCSprite *scoreboard = [CCSprite spriteWithFile:@"Scoreboard.png"];
        scoreboard.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:scoreboard];

        
        CCSprite *monkeyOnCloud = [CCSprite spriteWithFile:@"monkey bananas.png"];
        monkeyOnCloud.position = ccp(winSize.width/5, winSize.height/2);
        [self addChild:monkeyOnCloud];

        id moveMonkeyDown = [CCMoveBy actionWithDuration:1 position:ccp(0, -30)];
        id moveMonkeyUp = [CCMoveBy actionWithDuration:1 position:ccp(0, 30)];
        id seq = [CCSequence actions:moveMonkeyDown,moveMonkeyUp , nil];
        [monkeyOnCloud runAction:[CCRepeatForever actionWithAction:seq]];
        
        for (int i=0; i < 5; i++) {
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:
                                      [NSString stringWithFormat:@"%d",[[GameData sharedGameData].highscore[i] integerValue]]
                                                        fontName:@"GROBOLD"
                                                        fontSize:30];
            scoreLabel.color = ccc3(245, 148, 36);
            
            if (winSize.width == 480) {
                scoreLabel.position = ccp(290, 250-i*50);
            }
            else scoreLabel.position = ccp(300,250-i*50);
            [scoreboard addChild:scoreLabel z:10];
        }
        
        NSArray *fruits = [NSArray arrayWithObjects:[NSNumber numberWithInt:[GameData sharedGameData].bananaCount],
                                                    [NSNumber numberWithInt:[GameData sharedGameData].mangosteenCount],
                                                    [NSNumber numberWithInt:[GameData sharedGameData].pineappleCount],nil];
        
        for (int i=0; i < 3; i++) {
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:
                                      [NSString stringWithFormat:@"%d",[fruits[i] integerValue]]
                                                        fontName:@"GROBOLD"
                                                        fontSize:30];
            scoreLabel.color = ccc3(245, 148, 36);
            if (winSize.width == 480) {
                scoreLabel.position = ccp(475, 230-i*80);
            }
            else scoreLabel.position = ccp(490, 230-i*80);
            [scoreboard addChild:scoreLabel z:10];
        }
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(-winSize.width/2.5, -120);
        
        CCMenuItemImage *next = [CCMenuItemImage
                                 itemWithNormalImage:@"Next icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goNext)];
        next.position = ccp(-winSize.width/2.5+80, -120);
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        CCMenu *menu = [CCMenu menuWithItems: home,next, nil];
        [menuLayer addChild: menu];
        
        
        [self initMission];
    }
    return self;
}

- (void)goHome {
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}

-(void)goNext
{
    missionLayer.visible = YES;
}

-(void)goBack
{
    missionLayer.visible = NO;
}


-(void)initMission {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    missionLayer = [CCSprite spriteWithFile:@"Menu screen.png"];
    missionLayer.anchorPoint = ccp(0,0);
    missionLayer.position = ccp(0,0);
    //missionLayer.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:missionLayer z:100];
    
    CCSprite *missions = [CCSprite spriteWithFile:@"Missions Screen.png"];
    missions.position = ccp(winSize.width/2, winSize.height/2);
    [missionLayer addChild:missions];
    
    CCSprite *monkeyOnCloud = [CCSprite spriteWithFile:@"monkey bananas.png"];
    monkeyOnCloud.position = ccp(winSize.width/5, winSize.height/2);
    [missionLayer addChild:monkeyOnCloud];
    id moveMonkeyDown = [CCMoveBy actionWithDuration:1 position:ccp(0, -30)];
    id moveMonkeyUp = [CCMoveBy actionWithDuration:1 position:ccp(0, 30)];
    id seq = [CCSequence actions:moveMonkeyDown,moveMonkeyUp , nil];
    [monkeyOnCloud runAction:[CCRepeatForever actionWithAction:seq]];
    
    CCMenuItemImage *home = [CCMenuItemImage
                             itemWithNormalImage:@"Home icon.png"
                             selectedImage:nil
                             target:self
                             selector:@selector(goHome)];
    home.position = ccp(-winSize.width/2.5, -120);
    
    CCMenuItemImage *back = [CCMenuItemImage
                             itemWithNormalImage:@"Back icon.png"
                             selectedImage:nil
                             target:self
                             selector:@selector(goBack)];
    back.position = ccp(-winSize.width/2.5+80, -120);
    
    CCLayer *menuLayer = [[CCLayer alloc] init];
    [missionLayer addChild:menuLayer];
    CCMenu *menu = [CCMenu menuWithItems: home,back, nil];
    [missionLayer addChild: menu];
    
    missionLayer.visible = NO;
}

- (void) dealloc
{
    
    [super dealloc];
}
@end