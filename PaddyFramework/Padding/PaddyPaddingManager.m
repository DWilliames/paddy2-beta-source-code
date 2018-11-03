//
//  PaddyPaddingManager.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingManager.h"
#import "PaddyLayoutManager.h"

@implementation PaddyPaddingManager

// Return if it actually updated
+ (BOOL)updatePaddingFor:(MSLayer*)layer {
    
    NSArray *layers = [layer parentGroup] ? [[layer parentGroup] layers] : @[];
    
    if ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:Artboard] || [PaddyClass is:layer instanceOf:SymbolMaster] || [PaddyClass is:layer instanceOf:Page]) {
        layers = [(MSLayerGroup*)layer layers];
    }
    
    
    NSArray *paddingLayers = [self backgroundLayersFromLayers:layers];
    if (paddingLayers.count < 1) {
        return FALSE;
    }
    
    // Keep track of the 'raw' – padding layers
    NSMutableArray *rawPaddingLayers = [NSMutableArray array];
    
    for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
        [rawPaddingLayers addObject:paddingLayer.layer];
    }
    
    
    PaddyPaddingLayer *firstPaddingLayer = [paddingLayers firstObject];
    MSLayerGroup *parent = [firstPaddingLayer.layer parentGroup];
    
    // Keep track of the original frame of the parent
    MSRect *originalParentFrame = [parent.frame copy];
    
    // All the layers that should be contained
    NSArray *contentLayers = [PaddyUtils filter:[parent layers] withBlock:^BOOL(MSLayer *layer) {
        if ([rawPaddingLayers containsObject:layer]) {
            return false;
        }
        if ([PaddyPaddingLayer shouldLayerBeIgnored:layer]) {
            return false;
        }
        
        return true;
    }];
    
    // Only layout if there's actually some content layers
    if (contentLayers.count < 1) {
        return FALSE;
    }
    
    // Container rect for everything that isn't a Padding layer
    MSRect *containerRect = [PaddyLayerUtils boundingRectForLayers:contentLayers withFilter:^BOOL(MSLayer *layer) {
        if ([rawPaddingLayers containsObject:layer]) {
            return false;
        }
        if ([PaddyPaddingLayer shouldLayerBeIgnored:layer]) {
            return false;
        }
        
        return true;
    }];
    
    for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
        [PaddyManager log:@"Update padding for: %@", paddingLayer];

        PaddyModelPadding *props = paddingLayer.paddingProperties;
        if (!props.enabled) {
            [PaddyManager log:@"Padding not enabled for: %@", paddingLayer];
            continue;
        }
        
        MSLayer *layer = paddingLayer.layer;
        
        double top, right, bottom, left;
        
        if (props.top) {
            top = [props.top doubleValue];
        } else {
            double yDiff = layer.frame.y - containerRect.y;
            top = -round(yDiff);
        }

        if (props.right) {
            right = [props.right doubleValue];
        } else {
            double xDiff = layer.frame.x - containerRect.x;
            double rightDiff = (containerRect.width - layer.frame.width - xDiff);
            right = -round(rightDiff);
        }
        
        if (props.bottom) {
            bottom = [props.bottom doubleValue];
        } else {
            double yDiff = layer.frame.y - containerRect.y;
            double bottomDiff = (containerRect.height - layer.frame.height - yDiff);
            bottom = -round(bottomDiff);
        }
        
        if (props.left) {
            left = [props.left doubleValue];
        } else {
            double xDiff = layer.frame.x - containerRect.x;
            left = -round(xDiff);
        }
        
        double x = containerRect.x - left;
        double y = containerRect.y - top;
        double width = containerRect.width + left + right;
        double height = containerRect.height + bottom + top;
        
        if ([PaddyManager.shared shouldPixelFit]) {
            x = round(x);
            y = round(y);
            width = round(width);
            height = round(height);
        }
        
        [paddingLayer.layer.frame setRectByIgnoringProportions:CGRectMake(x, y, width, height)];

    }
    
    [PaddyManager log:@"Update padding for: %@", parent.name];
    PaddyStackGroup *stackGroupParent = [PaddyStackGroup fromLayer:parent];
    if (stackGroupParent && stackGroupParent.stackProperties && stackGroupParent.stackProperties.collapsing) {
        
        PaddyOrientation orientation = stackGroupParent.stackProperties.orientation;

        [PaddyLayerUtils resizeLayerToFitChildren:parent withFilter:^BOOL(MSLayer *layer) {
            return [layer isVisible];
        } offsetX:(orientation == Horizontal) offsetY:(orientation == Vertical)];
 
    } else {
        [parent resizeToFitChildrenWithOption:1];
    }
    
    
    MSRect *newParentFrame = [parent frame];
    
    // TODO: If the parent has fixed dimensions; resize the group instead
    
//    if ((parent.hasFixedWidth || parent.hasFixedHeight) && [parent parentGroup] && ![PaddyClass is:[parent parentGroup] instanceOf:Page]) {
//
//        if (parent.hasFixedWidth) {
//            [parent.frame setWidth:originalParentFrame.width];
//        }
//
//        if (parent.hasFixedHeight) {
//            [parent.frame setHeight:originalParentFrame.height];
//        }
//
//        [parent.frame setOrigin:originalParentFrame.origin];
//
//        [PaddyLayoutManager resizeGroup:parent withOldFrame:newParentFrame];
//    }
    
    // It recalculated the padding, if the parent has now changed size
    return ![originalParentFrame isEqual:newParentFrame];
}


// Return all of the 'PaddyPaddingLayer's from the given layers
+ (NSArray*)backgroundLayersFromLayers:(NSArray*)layers {
    
    NSMutableArray *backgroundLayers = [NSMutableArray array];
    
    for (MSLayer *layer in layers) {
        if ([PaddyPaddingLayer shouldLayerBeIgnored:layer]) {
            continue;
        }
        
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
        if (paddingLayer && paddingLayer.paddingProperties) {
            [backgroundLayers addObject:paddingLayer];
        }
    }
    
    return backgroundLayers;
}


+ (MSLayer*)getBackgroundForLayer:(MSLayer*)layer {
    
    NSArray *layers = [layer parentGroup] ? ((MSLayerGroup*)[layer parentGroup]).layers : nil;
    
    if ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:Artboard] || [PaddyClass is:layer instanceOf:SymbolMaster] || [PaddyClass is:layer instanceOf:Page]) {
        layers = ((MSLayerGroup*)layer).layers;
    }
    
    // Get background candidate from layers
    if (!layer) {
        return nil;
    }
    
    __block MSLayer *candidate;
    
    MSLayer *existingBackground = [PaddyUtils find:layers withBlock:^BOOL(MSLayer *layer) {
        if ([PaddyPaddingLayer shouldLayerBeIgnored:layer] || [PaddyClass is:layer instanceOf:Group]) {
            return false;
        }
        
        if ([PaddyPaddingLayer canLayerHavePadding:layer]) {
            PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
            if (paddingLayer) {
                return true;
            } else if (!candidate) {
                candidate = layer;
            }
        }
        
        return false;
    }];
    
    return existingBackground ? existingBackground : candidate;
}

@end
