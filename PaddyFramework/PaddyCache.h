//
//  PaddyCache.h
//  PaddyFramework
//
//  Created by David Williames on 1/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingLayer.h"
#import "PaddyStackGroup.h"

@interface PaddyCache : NSObject

+ (void)clear;
+ (void)clearForLayer:(MSLayer*)layer;

+ (PaddyPaddingLayer*)paddingForLayer:(MSLayer*)layer;
+ (PaddyStackGroup*)stackGroupForLayer:(MSLayer*)layer;

+ (void)setPadding:(PaddyPaddingLayer*)padding forLayer:(MSLayer*)layer;
+ (void)setStackGroup:(PaddyStackGroup*)stackGroup forLayer:(MSLayer*)layer;

@end
