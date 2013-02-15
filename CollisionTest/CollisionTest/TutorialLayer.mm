//
//  TutorialLayer.m
//  CollisionTest
//
//  Created by Heaven Chen on 2/15/13.
//
//

#import "TutorialLayer.h"
#import "HelloWorldLayer.h"
#import "CCSprite.h"
#import "CCNode+SFGestureRecognizers.h"

@implementation TutorialLayer
CCSprite *page;
int pageIndex;
CCMenuItemImage* button;
CCMenu *menu;
CCLayer *menuLayer;
CCLayer *tryLayer;


+(id) scene
{
  CCScene *scene = [CCScene node];
  
  TutorialLayer *layer = [TutorialLayer node];
  
  [scene addChild: layer];
  
  return scene;
}


-(id) init
{
  
  if( (self=[super init] )) {
    
    // Adding solid background color
    CCNode *_background = [CCSprite spriteWithFile: @"Canyon background blue.png"];
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
  [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene:button.tag]];
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
                itemWithNormalImage:@"Try button.png"
                selectedImage:@"Try button selected.png"
                target:self
                selector:@selector(leftswipe)];
      
      break;
      
    case 2:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Flip button.png"
                selectedImage:@"Flip button selected.png"
                target:self
                selector:@selector(rightswipe)];
      
      break;
      
    case 3:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Tap button.png"
                selectedImage:@"Tap button selected.png"
                target:self
                selector:@selector(tap)];
      
      break;
      
    case 4:
      button = [CCMenuItemImage
                itemWithNormalImage:@"Play.png"
                selectedImage:@"Play selected.png"
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
  [self removeChild:page cleanup:YES];
  UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGestureRecognizer:)];
  [self addGestureRecognizer:swipeLeftGestureRecognizer];
  swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  swipeLeftGestureRecognizer.delegate = self;
  [swipeLeftGestureRecognizer release];
  
  // load canyon and monkey
  [self loadPlushy];
  
  // load map
  CCSprite *map = [CCSprite spriteWithFile:@"map level 3.png"];
  map.anchorPoint = ccp(0.9, 1.1);
  map.position = ccp(300,200);
  [tryLayer addChild:map];

  //[self loadTutorial];
}

-(void)rightswipe
{
  //pageIndex = 3;
  UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGestureRecognizer:)];
  [self addGestureRecognizer:swipeRightGestureRecognizer];
  swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  swipeRightGestureRecognizer.delegate = self;
  [swipeRightGestureRecognizer release];
 
  // load plushy
  [self loadPlushy];
  
  // load map
  CCSprite *map = [CCSprite spriteWithFile:@"map level 3.png"];
  map.anchorPoint = ccp(0.9, 1.1);
  map.position = ccp(300,200);
  [tryLayer addChild:map];
  
  //[self loadTutorial];
}

-(void)tap
{
  //pageIndex = 4;
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
  [self addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  tapGestureRecognizer.delegate = self;
  [tapGestureRecognizer release];
  // load canyon
  
  [self loadPlushy];
  [self loadMap:@"map3.png"];
  //[self loadTutorial];
}

- (void)handleTapGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  self.isTouchEnabled = NO;
  [self removeChild:tryLayer cleanup:YES];
  pageIndex = 2;
  //roate left
  [self loadTutorial];
  
}

- (void)handleSwipeLeftGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  [self removeChild:tryLayer cleanup:YES];
  self.isTouchEnabled = NO;
  pageIndex = 3;
  //rotate right
  [self loadTutorial];
}

- (void)handleSwipeRightGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
  self.isTouchEnabled = NO;
  pageIndex = 4;
  //tap to jump
  [self loadTutorial];
}

- (void)loadPlushy
{
  // create a new layer to hold plushy and the map
  tryLayer = [[[CCLayer alloc] init] autorelease];
  tryLayer.anchorPoint = ccp(0,0);
  tryLayer.position = ccp(0,0);
  CCSprite *plushy = [CCSprite spriteWithFile:@"Monkey run 2.png"];
  plushy.anchorPoint = ccp(0.5, 0.5);
  plushy.position = ccp(300,200);
  [tryLayer addChild:plushy];
  [self addChild:tryLayer];
}

-(void)loadMap:(NSString*)map
{
  
}

- (void) dealloc
{
  
  [super dealloc];
}

@end
