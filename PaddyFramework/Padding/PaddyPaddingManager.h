//
//  PaddyPaddingManager.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingLayer.h"

@interface PaddyPaddingManager : NSObject

+ (BOOL)updatePaddingFor:(MSLayer*)layer;
+ (NSArray*)backgroundLayersFromLayers:(NSArray*)layers;

+ (MSLayer*)getBackgroundForLayer:(MSLayer*)layer;

@end
