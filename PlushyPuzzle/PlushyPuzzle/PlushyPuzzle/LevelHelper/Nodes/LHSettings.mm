//  This file was generated by LevelHelper
//  http://www.levelhelper.org
//
//  LevelHelperLoader.mm
//  Created by Bogdan Vladu
//  Copyright 2011 Bogdan Vladu. All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  This notice may not be removed or altered from any source distribution.
//  By "software" the author refers to this code file and not the application 
//  that was used to generate this file.
//
////////////////////////////////////////////////////////////////////////////////

#import "LHSettings.h"
#import "cocos2d.h"
#import "LevelHelperLoader.h"

#import "LHLayer.h"
#import "LHSprite.h"
#import "LHBezier.h"
#import "LHJoint.h"

@implementation LHSettings
////////////////////////////////////////////////////////////////////////////////

@synthesize useHDOnIpad;
@synthesize lhPtmRatio;
@synthesize customAlpha;
@synthesize convertLevel;
@synthesize levelPaused;
@synthesize isCoronaUser;
@synthesize preloadBatchNodes;
@synthesize device;
@synthesize safeFrame;
@synthesize userOffset;
@synthesize orientation;
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
+ (LHSettings*)sharedInstance{
	static id sharedInstance = nil;
	if (sharedInstance == nil){
		sharedInstance = [[LHSettings alloc] init];
	}
    return sharedInstance;
}
////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
#ifndef LH_ARC_ENABLED
    [hdSuffix release];
    [hd2xSuffix release];
    
    [markedSprites release];
    [markedBeziers release];
    [markedJoints release];
    [allLHMainLayers release];
    [activeFolder release];
	[super dealloc];
#endif
}
////////////////////////////////////////////////////////////////////////////////
- (id)init
{
	self = [super init];
	if (self != nil) {
        
        markedSprites = [[NSMutableSet alloc] init];
        markedBeziers = [[NSMutableSet alloc] init];
        markedJoints  = [[NSMutableSet alloc] init];
        allLHMainLayers = [[NSMutableArray alloc] init];
        
		useHDOnIpad = true;
		convertLevel = true;
		lhPtmRatio = 32.0f;
		customAlpha = 1.0f;
		convertRatio = CGPointMake(1, 1);
        realConvertRatio = CGPointMake(1, 1);
		newBodyId = 0;
        stretchArt = true;
        possitionOffset = CGPointMake(0.0f, 0.0f);
        levelPaused = false;
		//imagesFolder = [[NSMutableString alloc] init];
        isCoronaUser = false;
        preloadBatchNodes = false;
        orientation = 0;
        
        [self setSafeFrame:CGSizeMake(480, 320)]; //universal
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [self setConvertRatio:CGPointMake(winSize.width/safeFrame.width,
                                          winSize.height/safeFrame.height)];

        activeFolder = [[NSMutableString alloc] init];
#ifdef LH_USE_BOX2D
        activeBox2dWorld = NULL;
#endif
        hdSuffix = [[NSMutableString alloc] initWithString:@"-hd"];
        hd2xSuffix = [[NSMutableString alloc] initWithString:@"-ipadhd"];
        
        [self setDevice:2];//universal
	}
	return self;
}
////////////////////////////////////////////////////////////////////////////////
-(void)setActiveFolder:(NSString*)folder{
    if(nil == folder)return;
    [activeFolder setString:folder];
}
-(NSString*)activeFolder{
    return activeFolder;
}

-(void)addLHMainLayer:(LHLayer*)layer{
    [allLHMainLayers addObject:layer];
}
-(void)removeLHMainLayer:(LHLayer*)layer{
    [allLHMainLayers removeObject:layer];
}
-(NSArray*)allLHMainLayers{
    return allLHMainLayers;
}

#ifdef LH_USE_BOX2D
-(b2World*)activeBox2dWorld{
    return activeBox2dWorld;
}
-(void)setActiveBox2dWorld:(b2World*)world{
    activeBox2dWorld = world;
}
#endif

-(void)setHDSuffix:(NSString*)suffix{
    if(nil == suffix) {[hdSuffix setString:@"-hd"]; return;}
    [hdSuffix setString:suffix];
}
-(NSString*)hdSuffix{
    return hdSuffix;
}

-(void)setHD2xSuffix:(NSString*)suffix{
    if(nil == suffix) {[hd2xSuffix setString:@"-ipadhd"]; return;}
    [hd2xSuffix setString:suffix];
    
}
-(NSString*)hd2xSuffix{
    return hd2xSuffix;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(void) markSpriteForRemoval:(LHSprite*)ccsprite{
    if(nil == ccsprite) return;
    [markedSprites addObject:ccsprite];
}
//------------------------------------------------------------------------------
-(void) markBezierForRemoval:(LHBezier*) node{
    if(nil == node) return;
    [markedBeziers addObject:node];    
}
//------------------------------------------------------------------------------
-(void) markJointForRemoval:(LHJoint*)jt{
    if(jt != NULL) [markedJoints addObject:jt];
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(void) removeMarkedSprites{
    for(LHSprite* spr in markedSprites){
        [spr removeSelf];
    }
    [markedSprites removeAllObjects];
}
//------------------------------------------------------------------------------
-(void) removeMarkedBeziers{
    for(LHBezier* node in markedBeziers){
        [node removeSelf];
    }
    [markedBeziers removeAllObjects];   
}
//------------------------------------------------------------------------------
-(void) removeMarkedJoints{
    for(LHJoint* jt in markedJoints){
        [jt removeSelf];
    }
    [markedJoints removeAllObjects];
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


-(int)newBodyId{
	return newBodyId++;
}

-(NSString*)pathForSpriteHelperDocument:(NSString*)sceneFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[sceneFile stringByDeletingPathExtension] ofType:@"pshs"
                                                inDirectory:[[LHSettings sharedInstance] activeFolder]];
    
    if(nil == path){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* imagesPath = [documentsDirectory stringByAppendingPathComponent:[[LHSettings sharedInstance] activeFolder]];
        
        //in case scene file does not have an extension add it
        NSString* docPath = [imagesPath stringByAppendingPathComponent:[[sceneFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"pshs"]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:docPath])
            return docPath;
    }
    return path;
}



-(NSString*)diskPathForImage:(NSString*)img
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[img stringByDeletingPathExtension] ofType:[img pathExtension]
                                                inDirectory:[[LHSettings sharedInstance] activeFolder]];
    
    if(nil == path){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* imagesPath = [documentsDirectory stringByAppendingPathComponent:[[LHSettings sharedInstance] activeFolder]];
        
        //in case scene file does not have an extension add it
        NSString* docPath = [imagesPath stringByAppendingPathComponent:img];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:docPath])
        {
            //only return different path if we are in the document folder
            return docPath;
        }
    }
    //in case is in the bundle return same image
    return img;
}



//-(NSString*)imagePath:(NSString*)file
//{
//    NSString* computedFile = file;
//    if([self isIpad] && [self useHDOnIpad])
//    {
//        if(device != 1 && device != 3)//if ipad only then we dont need to apply transformations
//        {
//            //we use this - in case extension is "pvr.ccz"
//            //the normal cocoa method will give as false extension
//            
//            NSString* fileName = [file stringByDeletingPathExtension];
//            NSString* fileExtension = [file pathExtension];
//            NSRange extRange = [file rangeOfString:@"."];//find first dot
//            if(extRange.location != NSNotFound){
//                fileExtension = [file substringFromIndex:extRange.location];
//                fileName = [file substringToIndex:extRange.location];
//            }
//            
//            if(CC_CONTENT_SCALE_FACTOR() == 2){
//                //we have ipad retina
//                computedFile = [NSString stringWithFormat:@"%@%@%@", fileName, hd2xSuffix, fileExtension];
//            }
//            else {
//                //we have normal ipad - lets use the HD image
//                computedFile = [NSString stringWithFormat:@"%@%@%@", fileName, hdSuffix, fileExtension];
//            }
//        }
//        
//#if COCOS2D_VERSION >= 0x00020000
//        NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:[NSString stringWithFormat:@"%@%@",activeFolder, computedFile]];
//#else
//        NSString *fullpath = [CCFileUtils fullPathFromRelativePath:[NSString stringWithFormat:@"%@%@",activeFolder, computedFile]];
//#endif
//        
//        if([[NSFileManager defaultManager] fileExistsAtPath:fullpath]){
//            
//            return fullpath;
//        }
//    }
//    return [NSString stringWithFormat:@"%@%@",activeFolder, file];
//}


-(NSString*)imagePath:(NSString*)file

{
    NSString* computedFile = file;
    if([self isIpad] && [self useHDOnIpad])
        
    {
        if(device != 1 && device != 3)//if ipad only then we dont need to apply transformations
            
        {
            //we use this - in case extension is "pvr.ccz"
            //the normal cocoa method will give as false extension
            
            NSString* fileName = [file stringByDeletingPathExtension];
            
            NSString* fileExtension = [file pathExtension];
            
            NSRange extRange = [file rangeOfString:@"."];//find first dot
            
            if(extRange.location != NSNotFound){
                
                fileExtension = [file substringFromIndex:extRange.location];
                
                fileName = [file substringToIndex:extRange.location];
                
            }
            
            if(CC_CONTENT_SCALE_FACTOR() == 2){
                //we have ipad retina
                computedFile = [NSString stringWithFormat:@"%@%@%@", fileName, hd2xSuffix, fileExtension];
                
            }
            
            else {
                //we have normal ipad - lets use the HD image
                computedFile = [NSString stringWithFormat:@"%@%@%@", fileName, hdSuffix, fileExtension];
                
            }
        }
        return [self diskPathForImage:computedFile];
    }
    return [self diskPathForImage:file];
}




-(CGPoint) transformedScalePointToCocos2d:(CGPoint)point{
    
    CGPoint ratio = [self convertRatio];
    if([self isIpad] && [self useHDOnIpad] && device != 1 && device != 3)
    {
        ratio.x /= 2.0f;
        ratio.y /= 2.0f;
    }
    point.x *= ratio.x;
    point.y *= ratio.y;
    return point;
}
-(CGPoint) transformedPointToCocos2d:(CGPoint)point{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //ios 5.1 and old cocos2d bug - inverse sides if landscape
    if(orientation == 1) //landscape
    {
        if(winSize.width < winSize.height)//we need to inverse values
        {
            float w = winSize.width;
            winSize.width = winSize.height;
            winSize.height = w;
        }
    }
    
    CGPoint pos_offset = [self possitionOffset];
    CGPoint user_offset = [self userOffset];
    CGPoint  wbConv = [self convertRatio];
    
    point.x += pos_offset.x/2.0f;
    point.y += pos_offset.y/2.0f;

    point.x += user_offset.x/2.0f;
    point.y += user_offset.y/2.0f;

    
    point.x *= wbConv.x;
    point.y  = winSize.height - point.y*wbConv.y;
    
    return point;
}
-(CGPoint)transformedPoint:(CGPoint)point forImage:(NSString*)image{
        
    if(device != 0 && device != 1 && device != 3) //iphone //ipad
    {
        point.x *= [self convertRatio].x;
        point.y *= [self convertRatio].y;

        if ([image rangeOfString:hdSuffix].location != NSNotFound ||
            [image rangeOfString:hd2xSuffix].location != NSNotFound) {
            point.x /=2.0f;
            point.y /=2.0f;        
        }
    }
    return point;    
}

-(CGRect)transformedTextureRect:(CGRect)rect forImage:(NSString*)image
{
    if(device != 0 && device != 1 && device != 3) //iphone //ipad
    {
        if( [image rangeOfString:hdSuffix].location != NSNotFound ||
            [image rangeOfString:hd2xSuffix].location != NSNotFound) {
        
            rect = CGRectMake(rect.origin.x*2.0f, rect.origin.y*2.0f, 
                              rect.size.width*2.0f, rect.size.height*2.0f);
        }
    }

    return rect;    
}

-(CGSize)transformedSize:(CGSize)size forImage:(NSString*)image
{
    if(device != 0 && device != 1 && device != 3) //iphone //ipad
    {
        if ([image rangeOfString:hdSuffix].location != NSNotFound ||
            [image rangeOfString:hd2xSuffix].location != NSNotFound) {
            size = CGSizeMake(size.width*2.0f, size.height*2.0f);
        }
    }
    
    return size;    
}


-(bool)isHDImage:(NSString*)image
{
    if(device == 0 || device == 1 || device == 3) //iphone //ipad
        return false;
    
    if ([image rangeOfString:hdSuffix].location == NSNotFound&&
        [image rangeOfString:hd2xSuffix].location == NSNotFound) {
        return false;
    }
    return true;
}

-(bool)isIpad
{
//    if(![self useHDOnIpad]){
//        return false;
//    }

    
#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED
	
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
	UIDevice* thisDevice = [UIDevice currentDevice];
	if ([thisDevice respondsToSelector:@selector(userInterfaceIdiom)]){
		if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad){
			return true;
		}
	}
	else{
		return false;
	}
#else
	return false;
#endif
    
#endif
    
#else
	return true;
#endif
	
	return false;
}

-(bool)isIphone5{
    
    if([[CCDirector sharedDirector] winSize].width == 568 ||
       [[CCDirector sharedDirector] winSize].height == 568)
//    if([[CCDirector sharedDirector] winSizeInPixels].width == 1136 ||
//       [[CCDirector sharedDirector] winSizeInPixels].height == 1136)
        return YES;
    
    return NO;
}

-(void) setStretchArt:(bool)value{
    stretchArt = value;
//    possitionOffset.x =0.0f;
//    possitionOffset.y =0.0f;   
}

-(bool)stretchArt{
    return stretchArt;
}

-(void) setConvertRatio:(CGPoint)val// usesCustomSize:(bool)usesCustomSize{
{
	convertRatio = val;
    realConvertRatio = val;
    if(!stretchArt)
    {
        if([self isIpad])
        {
            if(convertRatio.x > 1.0 || convertRatio.y > 1.0f)
            {
                convertRatio.x = 2.0f;
                convertRatio.y = 2.0f;
                
#ifdef LH_SCENE_TESTER
    convertRatio.x = 1.0f;
    convertRatio.y = 1.0f;
#endif
                
                if([[CCDirector sharedDirector] winSize].width == 1024.0f)
                {
                    possitionOffset.x = 32.0f;
                    possitionOffset.y = 64.0f;   
                }
                else {
                    possitionOffset.x = 64.0f;
                    possitionOffset.y = 32.0f;
                }
                
#ifdef LH_SCENE_TESTER
                if([[CCDirector sharedDirector] winSize].width == 512.0f)
                {
                    possitionOffset.x = 16.0f;
                    possitionOffset.y = 32.0f;  
                }
                else {
                    possitionOffset.x = 32.0f;
                    possitionOffset.y = 16.0f;
                }
#endif

            }
            
            if(device == 3)
            {
                convertRatio.x = 1.0f;
                convertRatio.y = 1.0f;
            }
        }
        
        if([self isIphone5]){
            
            if(convertRatio.x > 1.0 || convertRatio.y > 1.0f)
            {
                convertRatio.x = 1.0f;
                convertRatio.y = 1.0f;
                
                if((int)[[CCDirector sharedDirector] winSize].width == 568)
                {
                    possitionOffset.x = 88.0f;
                    possitionOffset.y = 0.0f;
                }
                else {
                    possitionOffset.x = 0.0f;
                    possitionOffset.y = 88.0f;
                }
                
            }
        }
    }
}
-(CGPoint) possitionOffset{
    return possitionOffset;
}

-(CGPoint) convertRatio{
	
	if(!convertLevel)
		return CGPointMake(1, 1);
	
	return convertRatio;
}


-(CGPoint) realConvertRatio{
    if(!convertLevel)
		return CGPointMake(1, 1);
	
	return realConvertRatio;
}


@end
