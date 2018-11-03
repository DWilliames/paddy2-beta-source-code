//
//  PaddyLayoutManager.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayoutManager.h"
#import "PaddyStackGroup.h"
#import "PaddyPaddingManager.h"
#import "PaddySymbolManager.h"
#import "PaddySelectionTracker.h"
#import "PaddyDocument.h"
#import "PaddySymbolDataManager.h"

@implementation PaddyLayoutManager

#pragma mark - convenient methods


// Layout the layers – including Stack Groups and Padding
// It can also update all of the ancestors as well
// Save state: determines whether we need to re-save the new state to the cache after it has been layed out

+ (void)updateForLayer:(MSLayer*)layer withReason:(PaddyLayoutReason)reason {
    
    PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer withReason:reason];
    if (layoutInstance) {
        [self updateForLayoutInstances:@[layoutInstance] andSaveState:TRUE];
    }
}


+ (void)updateForLayers:(NSArray*)layers withReason:(PaddyLayoutReason)reason {
    
    NSMutableArray *layoutInstances = [NSMutableArray array];
    for (MSLayer *layer in layers) {
        PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer withReason:reason];
        if (layoutInstance) {
            [layoutInstances addObject:layoutInstance];
        }
    }
    
    [self updateForLayoutInstances:layoutInstances andSaveState:TRUE];
}


+ (void)updateForLayoutInstance:(PaddyLayoutInstance*)instance andSaveState:(BOOL)saveState {
    [self updateForLayoutInstances:@[instance] andSaveState:saveState];
}

+ (void)updateForLayoutInstances:(NSArray*)instances andSaveState:(BOOL)saveState {
    
    if (instances.count == 0) {
        return;
    }
    
    // Layout out layers:
    // 1. Sort all layers based on their depth
    // 2. Only re-layout a single layer, if it is a Symbol instance
    // 3. If it's a group, update padding layers within it, then update the stack group (if it has it)
    // 4. If the group was resized, update its children first
    
    [PaddyManager log:@"Layout for instances: %@", instances];
    PaddyBenchmark *benchmark = [PaddyBenchmark benchmark:@"Layout layers"];

    NSMutableOrderedSet *remainingLayers = [NSMutableOrderedSet orderedSet];

    NSMutableSet *layersThatChanged = [NSMutableSet set]; // To update the cached model objects
    
    // TODO: If layout instance, was resizing a group – account for that first
    
    // A lookup for each instance, and the reason it was captured
    NSMutableDictionary *layoutInstanceLookup = [NSMutableDictionary dictionary];
    
    for (PaddyLayoutInstance *layoutInstance in instances) {
        if (layoutInstance.reason == ChangedSize && [PaddyClass does:layoutInstance.layer inheritFrom:Group]) {
            // Update all the children if it's not an Artboard that does not resize contents
            
            if ([PaddyClass is:layoutInstance.layer instanceOf:Artboard]) {
                MSArtboardGroup *artboard = (MSArtboardGroup*)layoutInstance.layer;
                if (!artboard.resizesContent) {
                    continue;
                }
            }
            
            MSLayerGroup *group = (MSLayerGroup*)layoutInstance.layer;
            
            
            
            // TODO: FIX THIS RESIZING
            BOOL commandHeld = ([NSEvent modifierFlags] & NSEventModifierFlagCommand) != 0;
            if (commandHeld) {
                [self resizeGroup:group withOldFrame:layoutInstance.originalFrame];
            } else {
                [remainingLayers addObjectsFromArray:group.children];
            }
            
            
            if ([PaddyClass is:group instanceOf:SymbolMaster]) {
                PaddySymbolManager *symbolManager = [[PaddyDocumentManager currentPaddyDocument] symbolManager];
                
                [symbolManager symbolMasterUpdated:(MSSymbolMaster*)group];
            }
        }
        
        [layoutInstanceLookup setObject:layoutInstance forKey:layoutInstance.layer.objectID];
        
        if ([layoutInstance.layer parentGroup]) {
            [layoutInstanceLookup setObject:layoutInstance forKey:((MSLayerGroup*)layoutInstance.layer.parentGroup).objectID];
        }
        
        
        [remainingLayers addObjectsFromArray:[layoutInstance layersToUpdate]];

    }
    
    [remainingLayers sortUsingComparator:^NSComparisonResult(id a, id b) {
        return ((NSArray*)[a ancestors]).count >= ((NSArray*)[b ancestors]).count ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    [PaddyManager log:@"Sorted beginning layers: %@", remainingLayers];
    
//    NSLog(@"Layout: %@", instances);
    
    for (MSLayer *layer in remainingLayers) {
        if (!layer) {
            continue;
        }
        
        PaddyLayoutInstance *layoutInstance = [layoutInstanceLookup objectForKey:layer.objectID];
        [PaddyManager log:@"- Layout: %@\nInstance: %@", layer, layoutInstance];
        
        // Update padding and spacing for layer
        
        if ([PaddyClass is:layer instanceOf:Page]) {
            MSPage *page = (MSPage*)layer;
            
            if (page.cachedArtboards && page.cachedArtboards.count > 0) {
                [PaddyManager log:@"WON'T UPDATE PAGE"];
                continue;
            }
        }
        
        if ([PaddyStackGroup canBeStackGroup:layer]) {
            
            CGPoint origin = layer.frame.origin;
            
            [PaddyManager log:@"Update for layout instances: %@", layer.name];
            PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
            
            MSAbsoluteRect *originalGroupAbsoluteRect;
            MSRect *originalContentRect;
            
            if (layoutInstance && stackGroup && stackGroup.stackProperties) {
                
//                MSAbsoluteRect *originalRect = layoutInstance.originalParentFrame;
                
                originalGroupAbsoluteRect = layoutInstance.originalParentFrame;
                
                // Cases: Toggle visiblity, moved, copied / duplicated, deleted
                
                // All the layers that aren't a Padding layer, or the layers that caused this update
                NSMutableArray *contentLayers = [PaddyUtils filter:stackGroup.layer.layers withBlock:^BOOL(MSLayer *layer) {
//                    if ([layer isEqual:layoutInstance.layer] || [PaddyStackGroup shouldLayerBeIgnored:layer]) {
//                        return false;
//                    }
                    
                    if ([PaddyStackGroup shouldLayerBeIgnored:layer]) {
                        return false;
                    }
                    
                    if (stackGroup.stackProperties && stackGroup.stackProperties.collapsing && !layer.isVisible){
                        return false;
                    }
                    
                    return true;
                }];
                
//                NSLog(@"Content layers: %@", contentLayers);
                
                
//                if (layoutInstance.originalLayer) {
//                    MSLayer *originalLayer = [layoutInstance.originalLayer newMutableCounterpart];
////                    NSLog(@"Original layer: %@ – %@", layoutInstance.originalLayer, originalLayer);
////                    NSLog(@"Original rect: %@ – %@", layoutInstance.originalLayer.frame.newMutableCounterpart, originalLayer.frame);
//                    [contentLayers addObject:originalLayer];
//
////                    NSLog(@"Current rect: %@", layoutInstance.layer.frame);
////
////                    NSLog(@"Abs frame: %@ - %@", originalLayer.absoluteRect, layoutInstance.originalFrame);
////                    NSLog(@"From: %@ to: %@", layoutInstance.originalFrame, layoutInstance.updatedFrame);
//
//                    // Absolute
//                    CGPoint originalOrigin = layoutInstance.originalFrame.origin;
//                    CGPoint newOrigin = layoutInstance.updatedFrame.origin;
//
//                    CGPoint absoluteDiff = CGPointMake(newOrigin.x - originalOrigin.x, newOrigin.y - originalOrigin.y);
//
//                    // Reference
//                    originalOrigin = originalLayer.frame.origin;
//                    newOrigin = layoutInstance.layer.frame.origin;
//
//                    CGPoint refDiff = CGPointMake(newOrigin.x - originalOrigin.x, newOrigin.y - originalOrigin.y);
//
////                    NSLog(@"DIFF Ref: (%g, %g) – Abs: (%g, %g)", refDiff.x, refDiff.y, absoluteDiff.x, absoluteDiff.y);
////                    NSLog(@"Original layer: %@ – Current: %@", originalLayer.frame, layoutInstance.layer.frame);
//
//                    CGPoint offset = CGPointMake(absoluteDiff.x - refDiff.x, absoluteDiff.y - refDiff.y);
//                    NSLog(@"OFFSET: (%g, %g)", offset.x, offset.y);
//
//                    if (layoutInstance.originalParentFrame) {
//                        NSLog(@"Original: %@ – New: %@", layoutInstance.originalParentFrame, layer.absoluteRect);
//                    }
//
////                    origin = CGPointMake(origin.x - offset.x, origin.y - offset.y);
//                }
                
                originalContentRect = [PaddyLayerUtils boundingRectForLayers:contentLayers];
//                NSLog(@"Original group rect: %@", originalContentRect);

            
//            MSRect *originalFrame = [layer.frame copy];
            }
            
            
            if (stackGroup) {
                [stackGroup recalculateSpacingAndAlignment];
            }
            [PaddyPaddingManager updatePaddingFor:layer];
            
            if (stackGroup && stackGroup.stackProperties) {
                
//                if (layoutInstance) {
//                    MSAbsoluteRect *previousParentRect = layoutInstance.originalParentFrame;
//                    NSLog(@"Original parent frame: %@", previousParentRect);
//
//                    MSLayerGroup *parent = [layoutInstance.layer parentGroup];
//                    MSAbsoluteRect *newParentRect = [parent absoluteRect];
//                    NSLog(@"New parent frame: %@", newParentRect);
//
//                    if (stackGroup.stackProperties.orientation == Vertical) {
//                        float diff = previousParentRect.y - newParentRect.y;
//                        [parent.frame setY:parent.frame.y + diff];
//                    } else if (stackGroup.stackProperties.orientation == Horizontal) {
//                        float diff = previousParentRect.x - newParentRect.x;
//                        [parent.frame setY:parent.frame.x + diff];
//                    }
//
//                    [layersThatChanged addObject:parent];
//                    [layersThatChanged addObject:layer];
//                }
//
                
                
                
                
                BOOL test = false;
                
                if (test && originalGroupAbsoluteRect && originalContentRect) {
                    
                    
                    
                    CGPoint originalAbsoluteContentRect = CGPointMake(originalContentRect.x + originalGroupAbsoluteRect.x, originalContentRect.y + originalGroupAbsoluteRect.y);
                    
                    MSRect *contentRect = [stackGroup rectForContentLayers];
                    MSAbsoluteRect *absoluteRect = [stackGroup.layer absoluteRect];
                    
                    CGPoint newAbsoluteContentRect = CGPointMake(contentRect.x + absoluteRect.x, contentRect.y + absoluteRect.y);
                    
//                    NSLog(@"OLD: (%g, %g) – NEW: (%g, %g)", originalAbsoluteContentRect.x, originalAbsoluteContentRect.y, newAbsoluteContentRect.x, newAbsoluteContentRect.y);
                    
                    CGPoint offset = CGPointMake(newAbsoluteContentRect.x - originalContentRect.x, newAbsoluteContentRect.y - originalContentRect.y);
                    
//                    NSLog(@"Offset – (%g, %g)", offset.x, offset.y);
                    
//                    if (stackGroup.stackProperties.orientation == Vertical) {
//                        [layer.frame setY:layer.frame.y - offset.y];
//                    } else if (stackGroup.stackProperties.orientation == Horizontal) {
//                        [layer.frame setX:layer.frame.x - offset.x];
//                    }
                    
                    [layer.frame setY:layer.frame.y - offset.y];
                    [layer.frame setX:layer.frame.x - offset.x];
                }
                else {
//                    if (stackGroup.stackProperties.orientation == Horizontal) {
//                        [layer.frame setX:origin.x];
//                    } else if (stackGroup.stackProperties.orientation == Vertical) {
//                        [layer.frame setY:origin.y];
//                    }

                }
                
            } else {
                [((MSLayerGroup*)layer) resizeToFitChildrenWithOption:1];
            }
            
//
//            if (stackGroup && layoutInstance && stackGroup.alignments.count > 0) {
//                // Update the frame, based on the alignment
//
//                MSRect *originalFrame = layoutInstance.originalFrame;
//
//                NSLog(@"** Recalc end position for: %@", layoutInstance);
//                NSLog(@"\nOriginal frame: %@ \nNew frame: %@", originalFrame, layer.frame);
//
//                float x = layer.frame.x;
//                float y = layer.frame.y;
//
//                for (NSNumber *alignmentValue in stackGroup.alignments) {
//                    PaddyAlignment alignment = [alignmentValue integerValue];
//
//                    switch (alignment) {
//                        case Left:
//                            x = originalFrame.x;
//                            break;
//                        case Right:
//                            x = originalFrame.x + originalFrame.width - layer.frame.width;
//                            break;
//                        case Center:
//                            x = originalFrame.x + (originalFrame.width / 2.0) - (layer.frame.width - originalFrame.width) / 2.0;
//                            break;
//                        default:
//                            break;
//                    }
//                }
//
//                [layer.frame setOrigin:CGPointMake(x, y)];
//            }
        }
        
        if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
            [PaddyManager log:@"LAYOUT INSTANCE"];
            
            if ([PaddyData shouldSymbolBeAutoResized:(MSSymbolInstance*)layer]) {
                BOOL altHeld = ([NSEvent modifierFlags] & NSEventModifierFlagOption) != 0;
                BOOL selected = [[PaddyManager selectedLayers] containsObject:layer];
                
                if (altHeld) {
                    [PaddyManager log:@"ALT HELD DOWN"];
                }
                // Insert, if 'ALT' is being help down
                PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
                
                BOOL isMoving = ([layoutInstance.layer isEqual:layer] && selected && layoutInstance.reason == ChangedPosition);
                
                NSLog(@"Layout instance: %@", layoutInstance);
                
                if (!isMoving) {
                    [document.symbolManager updateSizeForSymbolInstance:(MSSymbolInstance*)layer andInsert:(!PRODUCTION && altHeld && selected) withMaster:nil];
                }
                
                
                [layersThatChanged addObject:layer];
                
            }
            
        } else if ([PaddyClass is:layer instanceOf:SymbolMaster]) {
            // SYMBOL MASTER
            MSSymbolMaster *master = (MSSymbolMaster*)layer;
            
            PaddySymbolManager *symbolManager = [[PaddyDocumentManager currentPaddyDocument] symbolManager];
            
            [symbolManager symbolMasterUpdated:master];
        }

    }
    
    
    
    if (saveState) {
        PaddySelectionTracker *selectionTracker = [[PaddyDocument current] selectionTracker];
        
        if (layersThatChanged.count > 0) {
            [selectionTracker didLayoutLayers:layersThatChanged.allObjects];
        }
        
        [benchmark logIntermittent:@"Updated selection"];
    }
    
    [benchmark logEnd];
    
    return;
}

+ (void)resizeGroup:(MSLayerGroup*)group withOldFrame:(MSAbsoluteRect*)oldFrame {
    if (!group) {
        return;
    }
    
    [PaddyManager log:@"Resize group – enforcing frame: %@", group];
//    NSLog(@"Resizing group: %@", group);
    
    CGPoint originalOrigin = group.frame.origin;
    
//    BOOL resizedHeight = group.frame.height != oldFrame.height;
//    BOOL resizedWidth = group.frame.width != oldFrame.width;
    
    NSArray *filteredLayers = [PaddyUtils filter:group.layers withBlock:^BOOL(MSLayer *layer) {
        return ![PaddyStackGroup shouldLayerBeIgnored:layer];
    }];
    
    NSArray *paddingLayers = [PaddyPaddingManager backgroundLayersFromLayers:group.layers];
    
    if (paddingLayers.count > 0) {
        
        MSRect *contentRect = [PaddyLayerUtils boundingRectForLayers:filteredLayers];
        
        // Our ideal insets
        float maxTop = 0;
        float maxRight = 10;
        float maxBottom = 0;
        float maxLeft = 0;
        
        for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
            PaddyModelPadding *props = paddingLayer.paddingProperties;
            MSRect *paddingRect = [PaddyLayerUtils rectForLayer:paddingLayer.layer];
            
            if (props.top && [props.top floatValue] > maxTop) {
                maxTop = [props.top floatValue];
            } else if (!props.top) {
                
                float top = contentRect.y - paddingRect.y;
                if (top > maxTop) {
                    maxTop = top;
                }
            }
            
            
            if (props.right && [props.right floatValue] > maxRight) {
                maxRight = [props.right floatValue];
            } else if (!props.right) {
                
                float right = (paddingRect.x + paddingRect.width) - (contentRect.x + contentRect.width);
                if (right > maxRight) {
                    maxRight = right;
                }
            }
            
            
            if (props.bottom && [props.bottom floatValue] > maxBottom) {
                maxBottom = [props.bottom floatValue];
            } else if (!props.bottom) {
                
                float bottom = (paddingRect.y + paddingRect.height) - (contentRect.y + contentRect.height);
                if (bottom > maxBottom) {
                    maxBottom = bottom;
                }
            }
            
            if (props.left && [props.left floatValue] > maxLeft) {
                maxLeft = [props.left floatValue];
            } else if (!props.left) {
                
                float left = contentRect.x - paddingRect.x;
                if (left > maxLeft) {
                    maxLeft = left;
                }
            }
        }
        
        // For all the content that is not the padding layers
        CGSize idealSize = CGSizeMake(group.frame.width - maxLeft - maxRight, group.frame.height - maxTop - maxBottom);
        CGPoint idealOrigin = CGPointMake(maxLeft, maxTop);
        
        
        // Put the layers in a group to resize them all at once
        MSLayerArray *layers = [NSClassFromString(@"MSLayerArray") arrayWithLayers:filteredLayers];
        MSLayerGroup *tempGroup = [[NSClassFromString(@"MSLayerGroup") alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        tempGroup.name = @"Group";
        
        [[layers parentOfFirstLayer] insertLayer:tempGroup afterLayer:[layers lastLayer]];
        [NSClassFromString(@"MSLayerGroup") moveLayers:[layers containedLayers] intoGroup:tempGroup];
        [tempGroup resizeToFitChildrenWithOption:1];
        
        [tempGroup.frame setOrigin:idealOrigin];
        [tempGroup.frame setSize:idealSize];
        
        [tempGroup ungroup];
    }
    
    [PaddyManager log:@"Resize group with old frame: %@", group.name];
    PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:group];
    if (stackGroup && stackGroup.stackProperties && filteredLayers.count > 0) {
        
        PaddyOrientation orientation = stackGroup.stackProperties.orientation;
        NSArray *sortedLayers = [PaddyLayoutManager sortedLayers:filteredLayers inOrientation:orientation];
        
        NSMutableArray *frames = [NSMutableArray array];
        
        float currentTotalSpace = 0;
        float totalResizableSize = 0;
        
        int resizableLayersCount = 0;
        
        PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
        
        for (MSLayer *layer in sortedLayers) {
            MSRect *previousFrame = [frames lastObject];
            MSRect *frame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
            
            if (previousFrame) {
                if (orientation == Vertical) {
                    currentTotalSpace += (frame.minY - previousFrame.maxY);
                } else if (orientation == Horizontal) {
                    currentTotalSpace += (frame.minX - previousFrame.maxX);
                }
            }
            
            if ([PaddyClass is:layer instanceOf:SymbolInstance] && [PaddyData shouldSymbolBeAutoResized:(MSSymbolInstance*)layer]) {
                
                [document.symbolManager updateSizeForSymbolInstance:(MSSymbolInstance*)layer andInsert:NO withMaster:nil];
                frame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
                
            } else if (orientation == Vertical && !layer.hasFixedHeight) {
                totalResizableSize += layer.frame.height;
                resizableLayersCount++;
            } else if (orientation == Horizontal && !layer.hasFixedWidth) {
                totalResizableSize += layer.frame.width;
                resizableLayersCount++;
            }
            
            [frames addObject:frame];
        }
        
        float idealTotalSpace = (stackGroup.stackProperties.spacing * (sortedLayers.count - 1));
        float spaceOffset = (idealTotalSpace - currentTotalSpace);
        
        float additionalSize = -(spaceOffset / (float)resizableLayersCount);
        
        // Re-stack
        frames = [NSMutableArray array];
        
        for (MSLayer *layer in sortedLayers) {
            MSRect *previousFrame = [frames lastObject];
            MSRect *frame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
            MSAbsoluteRect *absoluteFrame = [layer absoluteRect];
            
            MSRect *originalFrame = [frame copy];
            
            BOOL constraintProportions = layer.constrainProportions;
            [layer setConstrainProportions:FALSE];
            
            
            [PaddyManager log:@"\n1. (%@) %@", layer, layer.frame];
            
            
            // Offset the layer position accordingly
            if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
                [PaddyManager log:@"It's a symbol instance, so do nothing"];
            } else if (orientation == Vertical) {
                if (previousFrame) {
                    double y = stackGroup.stackProperties.spacing - frame.minY + previousFrame.maxY;
                    [layer.frame setY:(layer.frame.y + y)];
                }
                
                if (!layer.hasFixedHeight) {
                    double newHeight = (layer.frame.height + additionalSize);
                    if (newHeight < 1) {
                        newHeight = 1;
                    }
                    [layer.frame setHeight:newHeight];
                }
            } else if (orientation == Horizontal) {
                [PaddyManager log:@"\n2. (%@) %@", layer, layer.frame];
                if (previousFrame) {
                    double x = stackGroup.stackProperties.spacing - frame.minX + previousFrame.maxX;
                    [layer.frame setX:(layer.frame.x + x)];
                }
                [PaddyManager log:@"\n3. (%@) %@", layer, layer.frame];
                
                if (!layer.hasFixedWidth) {
                    double newWidth = (layer.frame.width + additionalSize);
                    if (newWidth < 1) {
                        newWidth = 1;
                    }
                    
                    [layer.frame setWidth:newWidth];
                }
                [PaddyManager log:@"\n4. (%@) %@", layer, layer.frame];
            }
            
            if ([PaddyManager.shared shouldPixelFit]) {
                [layer makeRectIntegral];
            }
            
            if ([PaddyClass is:layer instanceOf:Group]) {
                [self resizeGroup:(MSLayerGroup*)layer withOldFrame:absoluteFrame];
            } else if ([PaddyClass is:layer instanceOf:TextLayer]) {
                MSTextLayer *textLayer = (MSTextLayer*)layer;
                [textLayer adjustFrameToFit];
            }
            
            [layer setConstrainProportions:constraintProportions];
            
            
            MSRect *newFrame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
            [frames addObject:newFrame];
            
            [PaddyManager log:@"%@, updated frame - \nfrom: %@ \nto: %@", layer.name, originalFrame, newFrame];
        }
    } else {
        for (MSLayer *layer in group.layers) {
            if ([PaddyClass is:layer instanceOf:Group]) {
                [PaddyManager log:@"Resize sub group: %@", layer];
                [self resizeGroup:(MSLayerGroup*)layer withOldFrame:[layer absoluteRect]];
            }
        }
    }
    
    [group.frame setOrigin:originalOrigin];
}


#pragma mark - Sorting layers

+ (NSArray*)sortedLayers:(NSArray*)layers inOrientation:(PaddyOrientation)orientation {
    
    // TODO: use groups, excluding layers with '-' prefix
    return [layers sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        CGRect frameA = [(MSLayer*)a frameForTransforms];
        CGRect frameB = [(MSLayer*)b frameForTransforms];
        
        if (orientation == Vertical) {
            return frameA.origin.y >= frameB.origin.y ? NSOrderedDescending : NSOrderedAscending;
        } else {
            return frameA.origin.x >= frameB.origin.x ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
}

+ (double)totalSpacingForLayers:(NSArray*)layers forOrientation:(PaddyOrientation)orientation {
    NSArray *sortedLayers = [self sortedLayers:layers inOrientation:orientation];
    
    double totalSpacing = 0;
    
    MSRect *previousFrame;
    
    for (MSLayer *layer in sortedLayers) {
        MSRect *frame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
        
        if (previousFrame) {
            // Offset the layer position accordingly
            if (orientation == Vertical) {
                totalSpacing += (frame.minY - previousFrame.maxY);
            } else if (orientation == Horizontal) {
                totalSpacing += (frame.minX - previousFrame.maxX);
            }
        }
        previousFrame = frame;
    }
    
    return totalSpacing;
}

@end
