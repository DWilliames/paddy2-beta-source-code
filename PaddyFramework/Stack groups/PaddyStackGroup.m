//
//  PaddyStackGroup.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyStackGroup.h"
#import "PaddyPaddingLayer.h"
#import "PaddyLayoutManager.h"
#import "PaddyNameReader.h"
#import "PaddyNameGenerator.h"

@interface PaddyStackGroup ()

@property (nonatomic, strong) MSLayerGroup *layer;

@property (nonatomic, strong) NSArray *alignments;
@property (nonatomic, strong) PaddyModelStack *stackProperties;

@property (nonatomic) BOOL shouldIgnore;

@end


@implementation PaddyStackGroup

+ (PaddyStackGroup*)fromLayer:(MSLayer*)layer ignoringCache:(BOOL)ignoreCache {
    PaddyStackGroup *layerCache = [PaddyCache stackGroupForLayer:layer];
    if (!layerCache || ignoreCache) {
        layerCache = [[PaddyStackGroup alloc] initWithLayer:(MSLayerGroup*)layer];
        
        if (!ignoreCache) {
            [PaddyCache setStackGroup:layerCache forLayer:layer];
        }
    }

    return layerCache;
}

+ (PaddyStackGroup*)fromLayer:(MSLayer*)layer {
    return [self fromLayer:layer ignoringCache:false];
}

+ (BOOL)canBeStackGroup:(MSLayer*)layer {
    if (!layer) {
        return false;
    }
    
    if ([PaddyClass is:layer instanceOf:Group]) {
        return true;
    }
    
    if ([PaddyClass is:layer instanceOf:Artboard]) {
        return true;
    }
    
    if ([PaddyClass is:layer instanceOf:SymbolMaster]) {
        return true;
    }
    
    if ([PaddyClass is:layer instanceOf:Page]) {
        return true;
    }
    
    return false;
}

+ (BOOL)shouldLayerBeIgnored:(MSLayer*)layer {
    // Layer has padding
    if ([PaddyClass is:layer instanceOf:Artboard]) {
        return true;
    }
    
    if ([PaddyClass is:layer instanceOf:Slice]) {
        return true;
    }
    
    if ((layer.name.length > 0 && [[layer.name substringToIndex:1] isEqualToString:@"-"]) || [PaddyData shouldLayerBeIgnored:layer]) {
        if ([PaddyClass is:layer instanceOf:TextLayer] && [[(MSTextLayer*)layer stringValue] isEqualToString:layer.name]) {
            return false;
        }
        
        return true;
    }
    
    PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
    if (paddingLayer && paddingLayer.paddingProperties) {
        return true;
    }
    
    return false;
}

- (instancetype)initWithLayer:(MSLayerGroup*)layer {
    
    if (![PaddyStackGroup canBeStackGroup:layer]) {
        return nil;
    }
    
    if (!(self = [super init])) {
        return nil;
    }
    
    self.layer = layer;
    
    // Let's get the values from the layer name first...
    PaddyNamesPreference namePreference = [PaddyPreferences getNamesPreference];
    PaddyNameReader *nameReader = [PaddyNameReader readFromLayer:layer];
    if (nameReader) {
        self.alignments = nameReader.alignments;
        self.stackProperties = nameReader.stackProperties;
        self.shouldIgnore = nameReader.shouldIgnore;
        
        // Override 'collapsing data'; because it isn't in the name
        PaddyModelStack *stackProps = [PaddyData stackDataForLayer:self.layer];
        self.stackProperties.collapsing = stackProps.collapsing;
        
        [PaddyData saveStackData:self.stackProperties toLayer:self.layer];
        [PaddyData saveAlignmentData:self.alignments toLayer:self.layer];
        [PaddyData saveShouldBeIgnored:self.shouldIgnore toLayer:self.layer];
    } else if (namePreference != ShowLayerNames) {
        self.stackProperties = [PaddyData stackDataForLayer:self.layer];
        self.alignments = [PaddyData alignmentDataForLayer:self.layer];
        self.shouldIgnore = [PaddyData shouldLayerBeIgnored:self.layer];
    }
    
    return self;
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PaddySwizzle appendMethod:@"MSLayer_setIsVisible:" with:^(id layer, va_list args){
            
            if ([[PaddyManager selectedLayers] containsObject:layer]) {
                
                PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
                [document.selectionTracker updateLayer:layer withReason:ChangedVisibility];
//                [PaddySelectionTracker ]
//                [PaddyLayoutManager updateForLayer:layer withReason:ChangedVisibility];
            } else {
                [PaddyManager log:@"Visiblity changed, but the layer is not selected"];
            }
        }];
    });
}

- (NSString*)description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@", self.layer.name];
    
    if (self.stackProperties) {
        [string appendFormat:@" - %@", self.stackProperties];
    }
    
    // Append each of the 'Alignments'
    if (self.alignments.count > 0) {
        NSMutableString *alignmentString = [NSMutableString string];
        for (int i = 0; i < self.alignments.count; i++) {
            NSString *alignment = [PaddyModelAlignment stringFromAlignment:[[self.alignments objectAtIndex:i] integerValue]];
            [alignmentString appendFormat:@"%@%@", alignment, (i < self.alignments.count - 1) ? @", " : @" "];
        }
        
        [string appendFormat:@" – %@", alignmentString];
    }
    
    return string;
}

- (void)updateStackProperties:(PaddyModelStack*)stackProperties {
    
    // Strip out not relevant alignments
    NSMutableArray *alignments = [NSMutableArray arrayWithArray:self.alignments];
    
    // Strip out relevant alignments
    switch (stackProperties.orientation) {
        case Horizontal:
            [alignments removeObject:@(Left)];
            [alignments removeObject:@(Right)];
            [alignments removeObject:@(Center)];
            break;
        case Vertical:
            [alignments removeObject:@(Top)];
            [alignments removeObject:@(Bottom)];
            [alignments removeObject:@(Middle)];
            break;
        case NoOrientation:
            break;
    }
    
    self.stackProperties = stackProperties;
    [PaddyData saveStackData:self.stackProperties toLayer:self.layer];
    
    
    
    // If we actually did strip some alignments
//    if (![alignments isEqualToArray:self.alignments]) {

        
        self.alignments = alignments;
        [PaddyData saveAlignmentData:self.alignments toLayer:self.layer];
    
    [PaddyNameGenerator updateNameForLayer:self.layer];
    
    [PaddyLayoutManager updateForLayer:self.layer withReason:StackGroupPropertiesChanged];
//    [PaddyLayoutManager layoutLayer:self.layer includingAncestors:YES];
    
        [[PaddyDocumentManager currentPaddyDocument] refreshInspector];
//    }
    
    
    [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
    
    
}

- (void)updateAlignments:(NSArray*)alignments {
    
    self.alignments = alignments;
    [PaddyData saveAlignmentData:self.alignments toLayer:self.layer];
    
    [PaddyNameGenerator updateNameForLayer:self.layer];
    
    [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
    
    [PaddyLayoutManager updateForLayer:self.layer withReason:AlignmentPropertiesChanged];
//    [PaddyLayoutManager layoutLayer:self.layer includingAncestors:YES];
}

// Return if it changed any layers
- (BOOL)recalculateSpacingAndAlignment {
    
    [PaddyManager log:@"Recalculate spacing for: %@", self.layer];
    
    PaddyBenchmark *benchmark = [PaddyBenchmark benchmark];
    
    NSArray *layers = self.layer.layers;
    
    if (layers.count == 0 || (!self.stackProperties && self.alignments.count == 0)) {
        // No layers to space
        return FALSE;
    }
    
    CGPoint position = self.layer.frame.origin;
    
    // If there's at least one locked layer; we'll use the first one to 'anchor' the alignment
    MSLayer *anchor;
    CGPoint anchorOrigin;

    
    // 1. FILTER
    // Remove the layers that we don't want to space
    NSMutableArray *filteredLayers = [NSMutableArray array];
    for (MSLayer *layer in layers) {
        
        // Ignore 'background' layers, 'Artboards', 'Slices' and layers with prefix '-'
        if ([PaddyStackGroup shouldLayerBeIgnored:layer]) {
            continue;
        }
        
        // Don't add hidden layers, if the stack is 'collapsing'
        if (self.stackProperties && self.stackProperties.collapsing && !layer.isVisible){
            continue;
        }
        
        if (!anchor && layer.isLocked) {
            anchor = layer;
            anchorOrigin = layer.absolutePosition;
        }
        
        [filteredLayers addObject:layer];
    }
    
//    [PaddyManager log:@"Filtered layers: %@", filteredLayers];
    
    
    
    // If there's alignment and curently no anchor layer, use the selected layer
    // Unless CMD or ALT is being held
    BOOL anchorFeature = false;
    
    BOOL commandHeld = ([NSEvent modifierFlags] & NSEventModifierFlagCommand) != 0;
    BOOL optionHeld = ([NSEvent modifierFlags] & NSEventModifierFlagOption) != 0;
    
    if (anchorFeature && self.alignments.count > 0 && !optionHeld && !commandHeld && [PaddyManager selectedLayers].count > 0) {
        
        // If any of the selected layers are in this group; use it as the anchor
        for (MSLayer *layer in [PaddyManager selectedLayers]) {
            if ([layers containsObject:layer]) {
                anchor = layer;
                anchorOrigin = layer.absolutePosition;
            }
            break;
        }
    }
    
    
    
    
    // 2. SORT
    // In order from 'top to bottom' (vertical) or 'left to right' (horizontal)
    PaddyOrientation orientation = (self.stackProperties) ? self.stackProperties.orientation : Vertical;
    NSArray *sortedLayers = [PaddyLayoutManager sortedLayers:filteredLayers inOrientation:orientation];
    
    [PaddyManager log:@"Sorted layers:  %@", sortedLayers];
    
    
    // 3. ADJUST
    // Shift all the layers frames in reference to the first object
    
    NSMutableArray *frames = [NSMutableArray array];
    
    for (MSLayer *layer in sortedLayers) {
        
        BOOL layerIsCollapsingStackGroup = false;
        
        if ([PaddyClass is:layer instanceOf:Group]) {
            
            PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
            if (stackGroup && stackGroup.stackProperties && stackGroup.stackProperties.collapsing) {
                
                PaddyOrientation orientation = stackGroup.stackProperties.orientation;
                
                [PaddyLayerUtils resizeLayerToFitChildren:((MSLayerGroup*)layer) withFilter:^BOOL(MSLayer *layer) {
                    return [layer isVisible];
                } offsetX:(orientation == Horizontal) offsetY:(orientation == Vertical)];
                
                layerIsCollapsingStackGroup = true;
            } else {
                [((MSLayerGroup*)layer) resizeToFitChildrenWithOption:1];
            }
        }
        
        MSRect *previousFrame = [frames lastObject];
//        MSRect *frame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
        
        MSRect *frame = [PaddyLayerUtils rectForLayer:layer withFilter:^BOOL(MSLayer *layer) {
            if (layerIsCollapsingStackGroup && !layer.isVisible) {
                return false;
            }
            return ![PaddyData shouldLayerBeIgnored:layer];
        }];
        
        if (!frame) {
            continue;
        }
        
//        MSRect *frame = [PaddyLayerUtils rectForLayer:layer];
        
        if (self.stackProperties && previousFrame) {
            // Offset the layer position accordingly
            if (self.stackProperties.orientation == Vertical) {
                double y = self.stackProperties.spacing - frame.minY + previousFrame.maxY;
                [layer.frame setY:(layer.frame.y + y)];
            } else if (self.stackProperties.orientation == Horizontal) {
                double x = self.stackProperties.spacing - frame.minX + previousFrame.maxX;
                [layer.frame setX:(layer.frame.x + x)];
            }
            
            if ([PaddyManager.shared shouldPixelFit]) {
                [layer makeOriginIntegral];
            }
        }
        
        [frame setOrigin:layer.frame.origin];
        
        // TODO: Pixel fit the new position
//        frame = [NSClassFromString(@"MSRect") rectWithRect:[layer frameForTransforms]];
//        frame = [PaddyLayerUtils rectForLayer:layer withFilter:^BOOL(MSLayer *layer) {
//            return ![PaddyData shouldLayerBeIgnored:layer];
//        }];
//        frame = [PaddyLayerUtils rectForLayer:layer];
        if (frame) {
            [frames addObject:layer.frame];
        }
        
    }
    
//    [PaddyManager log:@"Frames: %@", frames];
    
    
    // 4. ALIGN
    // Now, let's shift their positions to be in alignment
    
    if (self.alignments.count > 0) {
//        MSRect *containerRect = [NSClassFromString(@"MSRect") rectWithUnionOfRects:frames];
        MSRect *containerRect = [PaddyLayerUtils boundingRectForLayers:sortedLayers];
        
        for (MSLayer *layer in sortedLayers) {
            
            // Update for every possible alignment (in most cases only one)
            for (NSNumber *alignmentValue in self.alignments) {
                
                PaddyAlignment alignment = [alignmentValue integerValue];
                
                switch (alignment) {
                    case Left:
                        [layer.frame setX:containerRect.minX];
                        break;
                    case Right:
                        [layer.frame setMaxX:containerRect.maxX];
                        break;
                    case Center:
                        [layer.frame setMidX:containerRect.midX];
                        break;
                    case Top:
                        [layer.frame setY:containerRect.minY];
                        break;
                    case Bottom:
                        [layer.frame setMaxY:containerRect.maxY];
                        break;
                    case Middle:
                        [layer.frame setMidY:containerRect.midY];
                        break;
                    case NoAlignment:
                        break;
                }
                
            }
            
            if ([PaddyManager.shared shouldPixelFit]) {
                [layer makeOriginIntegral];
            }
            
        }
    }
    
    
    if (self.stackProperties && self.stackProperties.collapsing) {
        
        PaddyOrientation orientation = self.stackProperties.orientation;
        
        [PaddyLayerUtils resizeLayerToFitChildren:self.layer withFilter:^BOOL(MSLayer *layer) {
            return [layer isVisible];
        } offsetX:(orientation == Horizontal) offsetY:(orientation == Vertical)];
        
    } else {
        [self.layer resizeToFitChildrenWithOption:1];
    }
    
    
    
    
    // If there was a locked layer reference, re-position back to what it was
    // Otherwise reset the position back to where it started
    if (anchor) {
        double xDiff = anchor.absolutePosition.x - anchorOrigin.x;
        double yDiff = anchor.absolutePosition.y - anchorOrigin.y;
        
        [PaddyManager log:@"Locked reference diff: (%g, %g)", xDiff, yDiff];

        position = CGPointMake(self.layer.frame.origin.x - xDiff, self.layer.frame.origin.y - yDiff);
        
        // De-offset all the layers we are ignoring
        for (MSLayer *layer in layers) {
            if ([PaddyStackGroup shouldLayerBeIgnored:layer]) {
                CGPoint newOrigin = CGPointMake(layer.frame.origin.x - xDiff, layer.frame.origin.y - yDiff);
                [layer.frame setOrigin:newOrigin];
            }
        }
    }
    
    [self.layer.frame setOrigin:position];
    
    
    if ([PaddyManager.shared shouldPixelFit]) {
        [self.layer makeOriginIntegral];
    }
    
    
    
    [PaddyManager log:@"RE-STACKED \n%@ \nIn %.2fms", self, [benchmark end]];
    // TODO: Make this actually calculate correctly
    return TRUE;
}


- (MSRect*)rectForContentLayers {
    
    NSMutableArray *contentLayers = [PaddyUtils filter:self.layer.layers withBlock:^BOOL(MSLayer *layer) {
        if ([PaddyStackGroup shouldLayerBeIgnored:layer]) {
            return false;
        }
        
        if (self.stackProperties && self.stackProperties.collapsing && !layer.isVisible){
            return false;
        }
        
        return true;
    }];
    
    return [PaddyLayerUtils boundingRectForLayers:contentLayers];
}


+ (PaddyStackGroup*)stackLayers:(NSArray*)layers withProps:(PaddyModelStack*)newProps creatingNewGroup:(BOOL)createNewGroup {
    
    if (layers.count < 1) {
        return nil;
    }
    
    if (!newProps) {
        newProps = [PaddyModelStack inferFromLayers:layers];
    }
    
    if (layers.count == 1) {
        // Either unstack the group, or turn it into a stack group, or group it into a stack group
        
        PaddyStackGroup *group = [PaddyStackGroup fromLayer:[layers firstObject]];
        if (group && group.stackProperties && !createNewGroup) {
            
            // De-stack it
            [group updateStackProperties:nil];
            
        } else if (group && !createNewGroup) {
            // Turn it into a stack group
            
            [group updateStackProperties:newProps];
        } else {
            
            MSLayerArray *newLayers = [NSClassFromString(@"MSLayerArray") arrayWithLayers:layers];
            MSLayerGroup *newGroup = [NSClassFromString(@"MSLayerGroup") groupFromLayers:newLayers];
            
            [PaddyManager log:@"NEW GROUP: %@", newGroup];
            group = [PaddyStackGroup fromLayer:newGroup];
            
            if (group) {
                [group updateStackProperties:newProps];
            }
        }
        
        return group;
    } else {
        
        // Stack all the selected groups
        // Group all the other layers
        MSLayerArray *newLayers = [NSClassFromString(@"MSLayerArray") arrayWithLayers:layers];
        MSLayerGroup *newGroup = [NSClassFromString(@"MSLayerGroup") groupFromLayers:newLayers];
        
        PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
        [document.selectionTracker addLayerToCache:newGroup];
        
        [PaddyManager log:@"NEW GROUP: %@", newGroup];
        PaddyStackGroup *group = [PaddyStackGroup fromLayer:newGroup];
        
        if (group) {
            [group updateStackProperties:newProps];
        }
        
        return group;
    }
}

@end
