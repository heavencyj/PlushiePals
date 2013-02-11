//
//  ActionLayer.m
//  Plushy
//
//  Created by Heaven Chen on 2/10/13.
//
//

#import "ActionLayer.h"

@implementation ActionLayer

+ (id)scene {
  CCScene *scene = [CCScene node];
  
  ActionLayer *layer = [ActionLayer node];
  [scene addChild:layer];
  
  // adding debug draw layer
  //debugDraw = new GLESDebugDraw( PTM_RATIO );
  
  return scene;
}

@end