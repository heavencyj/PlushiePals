//
//  GameOverScene.h
//  CollisionTest
//
//  Created by Heaven Chen on 2/1/13.
//
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
  CCLabelTTF *_label;
}
@property (nonatomic, retain) CCLabelTTF *label;
@end

@interface GameOverScene : CCScene {
  GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end
