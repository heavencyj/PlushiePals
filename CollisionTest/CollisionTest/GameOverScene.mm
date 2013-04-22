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
#import "GameData.h"

@implementation GameOverScene
CCSprite *gameoverbg;
CCSprite *monkeyOnCloud;
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
        CCSprite *blueBG = [CCSprite spriteWithFile:@"End Screen background.png"];
        blueBG.anchorPoint = ccp(0,0);
        blueBG.position = ccp(0,0);
        [self addChild:blueBG];
        gameoverbg = [CCSprite spriteWithFile: @"End Screen clouds.png"];
        gameoverbg.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:gameoverbg z:6];

        monkeyOnCloud = [CCSprite spriteWithFile:@"monkey bananas.png"];
        monkeyOnCloud.position = ccp(winSize.width/4, winSize.height/2);
        [self addChild:monkeyOnCloud z:10];
        
        id moveMonkeyDown = [CCMoveBy actionWithDuration:1 position:ccp(0, -30)];
        id moveMonkeyUp = [CCMoveBy actionWithDuration:1 position:ccp(0, 30)];
        id seq = [CCSequence actions:moveMonkeyDown,moveMonkeyUp , nil];
        //[CCCallFunc actionWithTarget:self selector:@selector(resetMonkeyPosition)]
        [monkeyOnCloud runAction:[CCRepeatForever actionWithAction:seq]];
        
        for (int i = 0; i<5; i++) {
            CCSprite *banana = [CCSprite spriteWithFile:@"banana single.png"];
            banana.position = ccp(70+i*90,300+i*8);
            banana.rotation = i*45;
            [self addChild:banana z:5];
            
            id bananaDroppoing = [CCMoveBy actionWithDuration:2 position:ccp(0, -200)];
            id bananaInvisible = [CCCallFuncND actionWithTarget:self selector:@selector(setInvisible:data:) data:banana];
            id bananaReset= [CCCallFuncND actionWithTarget:self selector:@selector(setBananaPos:data:) data:banana];
            //id bananadelay = [CCDelayTime actionWithDuration:0.5];
            id bananaVisible = [CCCallFuncND actionWithTarget:self selector:@selector(setNodeVisible:data:) data:banana];
            id seq = [CCSequence actions:bananaDroppoing, bananaInvisible,bananaReset, bananaVisible, nil];
            [banana runAction:[CCRepeatForever actionWithAction:seq]];                             
        }
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer z:20];
        
        CCMenuItemImage *home = [CCMenuItemImage
                                 itemWithNormalImage:@"Home icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(goHome)];
        home.position = ccp(-winSize.width*9/24, -winSize.height/3);
        
        CCMenuItemImage *restart = [CCMenuItemImage
                                    itemWithNormalImage:@"Play icon.png"
                                    selectedImage:nil
                                    target:self
                                    selector:@selector(restart)];
        restart.position = ccp(-winSize.width*6/24,-winSize.height/3);
        
        CCMenuItemImage *plushy = [CCMenuItemImage
                                 itemWithNormalImage:@"Score icon.png"
                                 selectedImage:nil
                                 target:self
                                 selector:@selector(showPlushy)];
        plushy.position = ccp(-winSize.width*3/24,-winSize.height/3);
        
       // why can't access after the for loop?? probably memory problem
        CCLOG(@"high scores r %@", [GameData sharedGameData].highscore);
        int rank=0;
        for (int i=0; i<5; i++) {
            if (levelScore > [[GameData sharedGameData].highscore[i] integerValue]) {
                [[GameData sharedGameData].highscore insertObject:[NSNumber numberWithInt:levelScore] atIndex:i];
                [[GameData sharedGameData].highscore removeLastObject];
                rank = i+1;
                break;
            }            
        }
        CCLOG(@"you ranked NO.%d", rank);
        CCLOG(@"high scores r %@", [GameData sharedGameData].highscore);
        int highestscore = [[[GameData sharedGameData].highscore objectAtIndex:0] integerValue];
        
        CCLabelTTF *scoreTxtLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"YOU SCORED"]
                                                   fontName:@"GROBOLD"
                                                   fontSize:26];
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",levelScore]
                                                    fontName:@"GROBOLD"
                                                    fontSize:75];
        
        CCLabelTTF *highscoreLabel = [CCLabelTTF labelWithString:
                                      [NSString stringWithFormat:@"Top Score  %d",highestscore]
                                                        fontName:@"GROBOLD"
                                                        fontSize:26];
        CCSprite *bananaIcon = [CCSprite spriteWithFile:@"Banana icon.png"];
        
        CCLabelTTF *bananaLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",
                                                               [GameData sharedGameData].bananaCount]
                                                    fontName:@"GROBOLD"
                                                    fontSize:28];
        
        scoreLabel.color = ccc3(245, 148, 36);
        scoreLabel.position = ccp(winSize.width/5, -25);
        
        scoreTxtLabel.color = ccc3(245, 148, 36);
        scoreTxtLabel.position = ccp(winSize.width/5, 35);
        
        bananaLabel.color = ccc3(245, 148, 36);
        bananaLabel.position = ccp(winSize.width/5+70, -winSize.height/4-30);
        
        bananaIcon.position = ccp(winSize.width/5,-winSize.height/4-30);
        
        highscoreLabel.color = ccc3(245, 148, 36);
        highscoreLabel.position = ccp(winSize.width/5,-winSize.height/4);
        
        CCMenuItemLabel *scoreTxt= [CCMenuItemLabel itemWithLabel:scoreTxtLabel];
        CCMenuItemLabel *score = [CCMenuItemLabel itemWithLabel:scoreLabel];
        CCMenuItemLabel *bananaCnt = [CCMenuItemLabel itemWithLabel:bananaLabel];
        CCMenuItemLabel *highscore = [CCMenuItemLabel itemWithLabel:highscoreLabel];
        CCMenuItemImage *bananaIconImg = [CCMenuItemImage itemWithNormalSprite:bananaIcon selectedSprite:nil];
        CCMenu *menu = [CCMenu menuWithItems: home, restart, plushy, scoreTxt, score,
                        bananaIconImg, bananaCnt, highscore, nil];
        [menuLayer addChild: menu z:20];
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

-(void)resetMonkeyPosition
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    monkeyOnCloud.position = ccp(winSize.width/4, winSize.height/2);
}

- (void)setInvisible:(id)a data:(CCNode *)node{
    node.visible = NO;
}
- (void)setNodeVisible:(id)a data:(CCNode *)node {
    node.visible = YES;
}

-(void)setBananaPos:(id)a data:(CCNode *)node {
    node.position = ccp(node.position.x, node.position.y+200);
}

- (void)dealloc {
    [super dealloc];
}

@end