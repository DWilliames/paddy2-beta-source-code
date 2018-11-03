//
//  PaddyLayerUtils.h
//  PaddyFramework
//
//  Created by David Williames on 29/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyLayerUtils : NSObject

+ (MSRect*)rectForLayer:(MSLayer*)layer;
+ (MSRect*)rectForLayer:(MSLayer *)layer withFilter:(BOOL (^)(MSLayer *layer))filterCondition;

+ (MSRect*)boundingRectForLayers:(NSArray*)layers;
+ (MSRect*)boundingRectForLayers:(NSArray*)layers withFilter:(BOOL (^)(MSLayer *layer))filterCondition;

+ (void)resizeLayerToFitChildren:(MSLayerGroup*)group withFilter:(BOOL (^)(MSLayer *layer))filterCondition offsetX:(BOOL)offsetX offsetY:(BOOL)offsetY;


+ (BOOL)doesArray:(NSArray*)array containSiblingToLayer:(MSLayer*)layer;
+ (NSArray*)getSiblingsToLayer:(MSLayer*)layer fromArray:(NSArray*)array;


@end
