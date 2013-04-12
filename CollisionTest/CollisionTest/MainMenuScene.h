//
//  MainMenuScene.h
//  Plushy
//
//  Created by Heaven Chen on 2/11/13.
//
//

#import "cocos2d.h"

@interface MainMenuScene : CCLayer
{

}



+(id) scene;
+(bool)showTips;
+(bool)isTestMode;
+(bool)showFirst;
+(void)setFirst:(bool)on;
+(void)setTips:(bool)on;
@end