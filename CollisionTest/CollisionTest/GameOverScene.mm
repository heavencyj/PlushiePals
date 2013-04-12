//
//  GameOverScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 2/1/13.
//
//

#import "GameOverScene.h"
#import "RunningGameScene.h"
#import "MainMenuScene.h"
#import "PlushyMenuScene.h"

@implementation GameOverScene
CCSprite *gameoverbg;
bool congrats;
int curLevel;
int levelScore;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOverScene *layer = [GameOverScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(CCScene *) scene:(bool)didpass withLevel:(int)level withScore:(int)score
{
    congrats = didpass;
    curLevel = level;
    levelScore = score;
    return [self scene];
    
}

+(CCScene *) scene:(int)withScore
{
    levelScore = withScore;
    return [self scene];
    
}

-(id) init
{
    if( (self=[super init] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *blueBG = [CCSprite spriteWithFile:@"Canyon background.png"];
        blueBG.anchorPoint = ccp(0,0);
        blueBG.position = ccp(0,0);
        [self addChild:blueBG];
        gameoverbg = [CCSprite spriteWithFile: @"End screen.png"];
        gameoverbg.position = ccp(winSize.width/2, winSize.height/2+10);
        [self addChild:gameoverbg];
        //
        //    CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello World"
        //                                           fontName:@"GROBOLD"
        //                                           fontSize:16];
        //    [self addChild:label];
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(-winSize.width*7/24, -winSize.height/4);
        
        CCMenuItemImage *restart = [CCMenuItemImage
                                    itemWithNormalImage:@"Return icon.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(restart)];
        restart.position = ccp(-winSize.width*4/24,-winSize.height/4);
        
        CCMenuItemImage *plushy = [CCMenuItemImage
                                 itemWithNormalImage:@"Plushy icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(showPlushy)];
        plushy.position = ccp(-winSize.width*1/24,-winSize.height/4);
        
//        CCLabelTTF *momoLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"MOMO"]
//                                                    fontName:@"GROBOLD"
//                                                    fontSize:20];
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",levelScore]
                                                    fontName:@"GROBOLD"
                                                    fontSize:50];
        
        CCLabelTTF *highscoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HIGH SCORE"]
                                              fontName:@"GROBOLD"
                                              fontSize:15];
        
        CCLabelTTF *scoreLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",356]
                                                    fontName:@"GROBOLD"
                                                    fontSize:20];
        
        scoreLabel.color = ccc3(245, 148, 36);
        scoreLabel.position = ccp(-winSize.width*4/24, -winSize.height/15);
        
        //momoLabel.color = ccc3(245, 148, 36);
        //momoLabel.position = ccp(-winSize.width*4/24, -winSize.height/12+25);
        
        scoreLabel2.color = ccc3(245, 148, 36);
        scoreLabel2.position = ccp(-winSize.width*4/24,winSize.height/8);
        
        highscoreLabel.color = ccc3(245, 148, 36);
        highscoreLabel.position = ccp(-winSize.width*4/24,winSize.height/8+25);
        
        CCMenuItemLabel *score = [CCMenuItemLabel itemWithLabel:scoreLabel];
        CCMenuItemLabel *score2 = [CCMenuItemLabel itemWithLabel:scoreLabel2];
        //CCMenuItemLabel *momo= [CCMenuItemLabel itemWithLabel:momoLabel];
        CCMenuItemLabel *highscore = [CCMenuItemLabel itemWithLabel:highscoreLabel];
//        CCMenu *menu = (congrats && (curLevel != 6)) ? [CCMenu menuWithItems: home, restart, next,score, nil]
//        : [CCMenu menuWithItems: home, restart, nil];
        CCMenu *menu = [CCMenu menuWithItems: home, restart, plushy, score, score2,highscore, nil];
        [menuLayer addChild: menu];
    }
    return self;
}

-(void)restart{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    
    [[CCDirector sharedDirector] replaceScene:[RunningGameScene scene]];
}

-(void)showPlushy
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    [[CCDirector sharedDirector] replaceScene:[PlushyMenuScene scene]];
}

- (void)goHome {
    [[SimpleAudioEngine sharedEngine] playEffect:@"Click.caf"];
    
    [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    
}

- (void)dealloc {
    [super dealloc];
}

@end