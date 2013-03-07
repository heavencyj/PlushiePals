//
//  TutorialLayer.m
//  CollisionTest
//
//  Created by Heaven Chen on 2/15/13.
//
//

#import "TutorialScene.h"
#import "GameScene.h"
#import "CCSprite.h"
#import "CCNode+SFGestureRecognizers.h"

@implementation TutorialScene
CCSprite *page;
int pageIndex;
CCMenuItemImage* button;
CCMenu *menu;
CCLayer *menuLayer;
CCSprite *map;
CCLayer *tryLayer;
CCSprite *monkey;

+(id) scene
{
  CCScene *scene = [CCScene node];
  
  TutorialScene *layer = [TutorialScene node];
  
  [scene addChild: layer];
  
  return scene;
}


-(id) init
{
  
  if( (self=[super init] )) {
    
    // Adding solid background color
    CCNode *_background = [CCSprite spriteWithFile: @"Menu screen.png"];
    _background.anchorPoint = ccp(0,0);
    //_background.position = ccp(winSize.width/2, winSize.height/2);
    _background.position = ccp(0,0);
    [self addChild:_background];
    
    pageIndex = 1;
    [self loadTutorial];
  }
  return self;
}

- (void) startGame: (id) sender
{
  CCMenuItemImage *button = (CCMenuItemImage *)sender;
  [[CCDirector sharedDirector] replaceScene:[GameScene scene:button.tag]];
}

-(void) loadTutorial
{
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  
  self.isTouchEnabled = YES;
  
  NSString* tutorial = [@"Tutorial level " stringByAppendingFormat:@"%d.png", pageIndex];
  // Adding solid background color
  page= [CCSprite spriteWithFile: tutorial];
  //page.anchorPoint = ccp(0,0);
  page.position = ccp(winSize.width/2, winSize.height/2);
  //page.position = ccp(0,0);
  [self addChild:page];
  
  // ADD the button
  switch (pageIndex) {
    case 1:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Play icon.png"
                selectedImage:nil
                target:self
                selector:@selector(leftswipe)];
      
      break;
      
    case 2:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Play icon.png"
                selectedImage:nil
                target:self
                selector:@selector(rightswipe)];
      
      break;
      
    case 3:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Play icon.png"
                selectedImage:nil
                target:self
                selector:@selector(tap)];
      
      break;
//      
//    case 4:
//      button = [CCMenuItemImage
//                itemWithNormalImage:@"Play icon.png"
//                selectedImage:nil
//                target:self
//                selector:@selector(starPage)];
//       break;

    
    case 4:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Play icon.png"
                selectedImage:nil
                target:self
                selector:@selector(startGame:)];
      // Start with level 1;
      button.tag = 1;
      
      break;
  
    default:
      break;
  }
  
  button.position = ccp(-winSize.width/5, -winSize.height/4);
  menuLayer = [[[CCLayer alloc] init] autorelease];
  [page addChild:menuLayer];
  menu = [CCMenu menuWithItems: button, nil];
  [menuLayer addChild: menu];
  
}

-(void)leftswipe
{
  //pageIndex = 2;
  // load canyon and monkey
  [self loadPlushy];
  
  // load map
  map = [CCSprite spriteWithFile:@"map level 3.png"];
  map.anchorPoint = ccp(0.95, 1);
  map.position = ccp(300,130);
  [tryLayer addChild:map z:1];

  //[self loadTutorial];
  
  // add gesture
  UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGestureRecognizer:)];
  [self addGestureRecognizer:swipeLeftGestureRecognizer];
  swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  swipeLeftGestureRecognizer.delegate = self;
  [swipeLeftGestureRecognizer release];
}

-(void)rightswipe
{
  //pageIndex = 3;
  
  // load plushy
  [self loadPlushy];
  
  // load map
  map = [CCSprite spriteWithFile:@"map level 3.png"];
  map.anchorPoint = ccp(0.75, 0.4);
  map.rotation = -180;
  map.position = ccp(300,200);
  [tryLayer addChild:map z:1];
  
  UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGestureRecognizer:)];
  [self addGestureRecognizer:swipeRightGestureRecognizer];
  swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  swipeRightGestureRecognizer.delegate = self;
  [swipeRightGestureRecognizer release];
  
  //[self loadTutorial];
}

-(void)tap
{
  //pageIndex = 4;
  
  [self loadPlushy];
  
  map = [CCSprite spriteWithFile:@"map level 3.png"];
  map.anchorPoint = ccp(0.3, 1.1);
  map.position = ccp(300,200);
  [tryLayer addChild:map z:1];
  //[self loadTutorial];
  
  // add gesture
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
  [self addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  tapGestureRecognizer.delegate = self;
  [tapGestureRecognizer release];
  // load canyon
}

- (void)handleSwipeLeftGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  self.isTouchEnabled = NO;
  [self removeGestureRecognizer:aGestureRecognizer];
  pageIndex = 2;

  //roate left
  [map runAction:[CCSequence actions:[CCRotateBy actionWithDuration:0.8 angle:-90],
                  [CCDelayTime actionWithDuration:1],
                  [CCCallFunc actionWithTarget:self selector:@selector(cleanAndLoad)], nil]];
}

- (void)handleSwipeRightGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  self.isTouchEnabled = NO;
  [self removeGestureRecognizer:aGestureRecognizer];
  pageIndex = 3;

  //rotate right
  [map runAction:[CCSequence actions:[CCRotateBy actionWithDuration:0.8 angle:90],
                  [CCDelayTime actionWithDuration:1],
                  [CCCallFunc actionWithTarget:self selector:@selector(cleanAndLoad)], nil]];
}


- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  
  self.isTouchEnabled = NO;
  [self removeGestureRecognizer:aGestureRecognizer];
  pageIndex = 4;
  //tap to jump
  [monkey runAction:[CCSequence actions:[CCJumpBy actionWithDuration:1 position:ccp(150,0) height:50 jumps:1],
                  [CCDelayTime actionWithDuration:1],
                  [CCCallFunc actionWithTarget:self selector:@selector(cleanAndLoad)], nil]];
  
}

-(void)starPage
{
  pageIndex = 5;
  [self loadTutorial];
}

- (void)loadPlushy
{
  // remove the tutorial page
  [self removeChild:page cleanup:YES];
  
  // create a new layer to hold plushy and the map
  tryLayer = [[[CCLayer alloc] init] autorelease];
  tryLayer.anchorPoint = ccp(0,0);
  tryLayer.position = ccp(0,0);
  monkey = [CCSprite spriteWithFile:@"Monkey run 2.png"];
  monkey.anchorPoint = ccp(0.5, 0.5);
  monkey.position = ccp(300,200);
  [tryLayer addChild:monkey z:10];
  [self addChild:tryLayer];
}

-(void)cleanAndLoad
{
  [self removeChild:tryLayer cleanup:YES];
  [self loadTutorial];
}

- (void) dealloc
{
  
  [super dealloc];
}

@end
