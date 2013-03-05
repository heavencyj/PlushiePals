/*
 MIT License
 
 Copyright (c) 2010 Andreas Loew / www.code-and-web.de
 
 For more information about htis module visit
 http://www.PhysicsEditor.de
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "Hud.h"
#import "NavButton.h"
#import "GMath.h"

@implementation Hud

@synthesize leftButton;
@synthesize rightButton;
@synthesize jumpButton;
@synthesize turnButton;

-(id) init
{        
    if( (self=[super init]))
    {
        // initialize all navigation buttons. 
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // initialize of left, right, and jump button
        CCTexture2D *left = [[CCTextureCache sharedTextureCache] addImage:@"button blue small.png"];
        leftButton = [NavButton buttonWithTexture:left atPosition:CGPointMake(winSize.width/4, [left contentSize].height/2)];
        [self addChild:leftButton z:100];
        CCTexture2D *right = [[CCTextureCache sharedTextureCache] addImage:@"button red small.png"];
        rightButton = [NavButton buttonWithTexture:right atPosition:CGPointMake(winSize.width/2, [right contentSize].height/2)];
        [self addChild:rightButton z:100];
        CCTexture2D *jump = [[CCTextureCache sharedTextureCache] addImage:@"button gray small.png"];
        jumpButton = [NavButton buttonWithTexture:jump atPosition:CGPointMake(3*winSize.width/4, [jump contentSize].height/2)];
        [self addChild:jumpButton z:100];
        
//        // create banana sprites for the energy hud
//        for(int i=0; i<MAX_ENERGY_TOKENS; i++)
//        {
//            const float ypos = 290.0f;
//            const float margin = 40.0f;
//            const float spacing = 20.0f;
//            
//            energyTokens[i] = [CCSprite spriteWithSpriteFrameName:@"hud/banana.png"];
//            energyTokens[i].position = ccp(margin+i*spacing, ypos);
//            energyTokens[i].visible = NO;
//            [self addChild:energyTokens[i]];            
//        }        
//
//        // cache sprite frames for the digits
//        CCSpriteFrameCache *sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
//        for(int i=0; i<10; i++)
//        {
//            digitFrame[i] = [sfc spriteFrameByName:
//                             [NSString stringWithFormat:@"numbers/%d.png", i]];
//        }
//        
//        // init digit sprites
//        for(int i=0; i<MAX_DIGITS; i++)
//        {
//            digits[i] = [CCSprite spriteWithSpriteFrame:digitFrame[0]];
//            digits[i].position = ccp(345+i*25, 290);
//            [self addChild:digits[i]];
//        }
    }
    
    return self;
}

//-(void) setEnergy:(float) energy
//{
//    float energyChangeRate = 2.0f;
//    
//    // slowly adjust displayed energy to monkeys real energy
//    if(currentEnergy < energy-0.01f)
//    {
//        // increase energy - but limit to maximum
//        currentEnergy = MIN(currentEnergy+energyChangeRate, energy);
//    }
//    else if(currentEnergy > energy+0.01f)
//    {
//        // reduce energy - but don't let it drop below 0
//        currentEnergy = MAX(currentEnergy-energyChangeRate, 0.0f);
//    }
//    currentEnergy = clamp(currentEnergy, 0.0f, MONKEY_MAX_ENERGY);
//    
//    int numBananas = round(MAX_ENERGY_TOKENS * currentEnergy / MONKEY_MAX_ENERGY);
//    int i=0;
//    for(; i<numBananas; i++)
//    {
//        if(!energyTokens[i].visible)
//        {
//            energyTokens[i].visible = YES;
//            energyTokens[i].scale = 0.6f;
//            energyTokens[i].opacity = 0.0f;
//            
//            // fade in and scale
//            [energyTokens[i] runAction:
//             [CCSpawn actions:
//              [CCFadeIn actionWithDuration:0.3f],
//              [CCScaleTo actionWithDuration:0.3f scale:1.0f],
//              nil]];
//        }
//    }
//    for(; i<MAX_ENERGY_TOKENS; i++)
//    {
//        if(energyTokens[i].visible && (energyTokens[i].numberOfRunningActions == 0) )
//        {
//            // fade out, scale to 0, hide when done
//            [energyTokens[i] runAction:
//             [CCSequence actions:
//              [CCSpawn actions:
//               [CCFadeOut actionWithDuration:0.3f],
//               [CCScaleTo actionWithDuration:0.3f scale:0.0f],
//               nil],
//              [CCHide action]
//              , nil]
//             ];
//        }
//    }
//}
//
//-(void) setScore:(float) score
//{
//    char strbuf[MAX_DIGITS+1];
//    memset(strbuf, 0, MAX_DIGITS+1);
//    
//    snprintf(strbuf, MAX_DIGITS+1, "%*d", MAX_DIGITS, (int)roundf(score));
//    int i=0;
//    for(; i<MAX_DIGITS; i++)
//    {
//        if(strbuf[i] != ' ')
//        {
//            [digits[i] setDisplayFrame:digitFrame[strbuf[i]-'0']];
//            [digits[i] setVisible:YES];
//        }
//        else
//        {
//            [digits[i] setVisible:NO];
//        }
//    }
//}

@end
