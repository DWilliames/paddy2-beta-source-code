//
//  PaddyLayerUtils.m
//  PaddyFramework
//
//  Created by David Williames on 29/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayerUtils.h"

@implementation PaddyLayerUtils

+ (MSRect*)rectForLayer:(MSLayer*)layer {
    return [self rectForLayer:layer withFilter:^BOOL(MSLayer *layer) {
        return true;
    }];
}

+ (MSRect*)rectForLayer:(MSLayer *)layer withFilter:(BOOL (^)(MSLayer *layer))filterCondition {
    
    if (!filterCondition(layer) || layer.isMasked) {
        return nil;
    }
    
    if (![PaddyClass does:layer inheritFrom:Group]) {
        return [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
    }
    
    // Bounding rect for layers
    MSLayerGroup *group = (MSLayerGroup*)layer;
    if ([group layers].count < 1) {
        return nil;
    }
    
    MSRect *childrenBoundingRect = [self boundingRectForLayers:[group layers] withFilter:filterCondition];
    if (!childrenBoundingRect) {
        return nil;
    }
    
    // Offset the child bounding rect by this layers origin
    [childrenBoundingRect setX:(childrenBoundingRect.x + layer.frame.x)];
    [childrenBoundingRect setY:(childrenBoundingRect.y + layer.frame.y)];
    
    return childrenBoundingRect;
}

+ (MSRect*)boundingRectForLayers:(NSArray*)layers {
    
    return [self boundingRectForLayers:layers withFilter:^BOOL(MSLayer *layer) {
        return true;
    }];
}

+ (MSRect*)boundingRectForLayers:(NSArray*)layers withFilter:(BOOL (^)(MSLayer *layer))filterCondition {
    
    NSMutableArray *frames = [NSMutableArray array];
    for (MSLayer *layer in layers) {
        
        if (!filterCondition(layer) || layer.isMasked) {
            continue;
        }
        
        MSRect *frame = [self rectForLayer:layer withFilter:filterCondition];
        if (frame) {
            [frames addObject:frame];
        }
    }
    
    if (frames.count < 1) {
        return nil;
    }
    
    return [NSClassFromString(@"MSRect") rectWithUnionOfRects:frames];
}

+ (void)resizeLayerToFitChildren:(MSLayerGroup*)group withFilter:(BOOL (^)(MSLayer *layer))filterCondition offsetX:(BOOL)offsetX offsetY:(BOOL)offsetY {
    
    offsetX = true;
    offsetY = true;
    
//    NSLog(@"Resize layer: %@ to fit children... %@", group, [group layers]);
//    NSLog(@"Offset X: %@, y: %@", offsetX ? @"Yes" : @"No", offsetY ? @"Yes" : @"No");
    
    CGPoint origin = group.frame.origin;
    
    // Get the ideal bounding box
    MSRect *contentRect = [PaddyLayerUtils boundingRectForLayers:group.layers withFilter:filterCondition];
    
    group.disableAutomaticScalingCounter++;
    
    CGPoint contentOrigin = contentRect.origin;
    
    // Add the original origin to the bounding box
    contentRect.x += origin.x;
    contentRect.y += origin.y;
    
    [group.frame setRect:contentRect.rect];
    group.disableAutomaticScalingCounter--;
    
    // Offset all the layers so that they are in the bounding box
    for (MSLayer *layer in [group layers]) {
        if (offsetX) {
            [layer.frame setX:(layer.frame.origin.x - contentOrigin.x)];
        }
        if (offsetY) {
            [layer.frame setY:(layer.frame.origin.y - contentOrigin.y)];
        }
    }
}



+ (BOOL)doesArray:(NSArray*)array containSiblingToLayer:(MSLayer*)layer {
    if (!array || !layer) {
        return false;
    }
    
    MSLayerGroup *parent = [layer parentGroup];
    
    MSLayer *firstSibling = [PaddyUtils find:array withBlock:^BOOL(MSLayer *layer) {
        return [[layer parentGroup] isEqual:parent];
    }];
    
    return firstSibling != nil;
}

+ (NSArray*)getSiblingsToLayer:(MSLayer*)layer fromArray:(NSArray*)array {
    NSMutableArray *siblings = [NSMutableArray array];
    
    MSLayerGroup *parent = [layer parentGroup];
    
    for (MSLayer *layer in array) {
        if ([[layer parentGroup] isEqual:parent]) {
            [siblings addObject:layer];
        }
    }
    
    return siblings;
}

@end
