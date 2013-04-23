//
//  BackStoryScene.m
//  CollisionTest
//
//  Created by Heaven Chen on 4/23/13.
//
//

#import "BackStoryScene.h"
#import "MapMenuScene.h"

@implementation BackStoryScene

int pageNumber;
CCSprite *story;
CCMenuItemImage *prev;
CCMenuItemImage *next;

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    BackStoryScene *layer = [BackStoryScene node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        pageNumber = 1;
        story = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Story %d.png", pageNumber]];
        story.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:story z:1];
        
        prev = [CCMenuItemImage
                   itemWithNormalImage:@"Back icon.png"
                   selectedImage:nil
                   target:self
                   selector:@selector(goPrev)];
        prev.position = ccp(-winSize.width/2+30, -winSize.height/2+30);
        prev.visible = NO;
        
        next = [CCMenuItemImage
                     itemWithNormalImage:@"Next icon.png"
                     selectedImage:nil
                     target:self
                     selector:@selector(goNext)];
        next.position = ccp(winSize.width/2-30, -winSize.height/2+30);
        
        CCMenuItemImage *skip = [CCMenuItemImage
                                     itemWithNormalImage:@"X icon.png"
                                     selectedImage:nil
                                     target:self
                                     selector:@selector(skip)];
        skip.position = ccp(winSize.width/2-30, winSize.height/2-30);
        
        
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer z:10];
        CCMenu *menu = [CCMenu menuWithItems:prev,next,skip, nil];
        [menuLayer addChild: menu z:10];
        
        
        
    }
    return self;
}

-(void)goPrev
{
    
    pageNumber --;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    story = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Story %d.png", pageNumber]];
    story.position = ccp(winSize.width/2, winSize.height/2);   
    [self addChild:story z:1];
    
    if (pageNumber == 1) {
        prev.visible = NO;
    }
    else prev.visible = YES;
    
}

-(void)goNext
{
    pageNumber ++;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    story = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Story %d.png", pageNumber]];
    story.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:story z:1];
    
    story = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Story %d.png", pageNumber]];
    
    if (pageNumber == 1) {
        prev.visible = NO;
    }
    else prev.visible = YES;
    
    if (pageNumber == 6) {
        next.visible = NO;
    }
    else next.visible = YES;
    
}

-(void)skip
{
    [[CCDirector sharedDirector] replaceScene:[MapMenuScene scene]];
}

- (void) dealloc
{
    
    [super dealloc];
}
@end
