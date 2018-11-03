//
//  PaddySelectionTracker.m
//  PaddyFramework
//
//  Created by David Williames on 14/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySelectionTracker.h"
#import "PaddyLayoutManager.h"
#import "PaddyLayoutInstance.h"
#import "PaddySymbolDataManager.h"
#import "PaddySymbolManager.h"
#import "PaddyLayerListPreview.h"

@interface PaddySelectionTracker ()

@property (nonatomic, strong) PaddyDocument *document;
@property (nonatomic, strong) NSMutableDictionary *cachedSelectedModelObjects;
@property (nonatomic, strong) NSMutableDictionary *cachedAbsoluteFrames;
@property (nonatomic, strong) NSMutableDictionary *cachedParents;

@end


@implementation PaddySelectionTracker

- (instancetype)initWithPaddyDocument:(PaddyDocument*)document {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.document = document;
    self.cachedSelectedModelObjects = [NSMutableDictionary dictionary];
    self.cachedAbsoluteFrames = [NSMutableDictionary dictionary];
    self.cachedParents = [NSMutableDictionary dictionary];
    
    self.holdOffUntilNextSelection = false;
    self.holdOffChangesFromSelection = false;
    
    return self;
}

//- (void)insertNewLayerInCurrentGroup:(id)arg1

- (void)resetCacheToLayers:(NSArray*)layers {
    self.cachedSelectedModelObjects = [NSMutableDictionary dictionary];
    self.cachedParents = [NSMutableDictionary dictionary];
    
    for (MSLayer *layer in layers) {
        [self addLayerToCache:layer];
    }
}

- (void)addLayerToCache:(MSLayer*)layer {
    [self.cachedSelectedModelObjects setObject:layer.immutableModelObject forKey:layer.objectID];
    [self.cachedAbsoluteFrames setObject:[layer.absoluteRect copy] forKey:layer.objectID];
    
    MSLayerGroup *parent = [layer parentGroup];
    if (parent) {
        [self.cachedAbsoluteFrames setObject:[parent.absoluteRect copy] forKey:parent.objectID];
        [self.cachedParents setObject:parent forKey:layer.objectID];
    }
    
}

- (void)didLayoutLayers:(NSArray*)layers {
//    [PaddyManager log:@"Selection tracker, did layout layers: %@", layers];
    // Since they were just re-layed out; their model objects may not be changed, and should be updated, if they exist
    
    for (MSLayer *layer in layers) {
        if ([self.cachedSelectedModelObjects objectForKey:layer.objectID]) {
            [PaddyManager log:@"Resetting cached model for: %@", layer];
            [self addLayerToCache:layer];
        }
    }
}

- (void)updatedSelectionFrom:(NSArray*)oldSelection to:(NSArray*)newSelection {
    
    if (self.holdOffChangesFromSelection) {
        return;
    } else if (self.holdOffUntilNextSelection) {
        if (newSelection.count > 0) {
            self.holdOffUntilNextSelection = false;
        } else {
            [PaddyManager log:@"NEED TO HOLD OFF UNTIL NEW SELECTION, SO WILL WAIT"];
            return;
        }
    }
    
    PaddyBenchmark *benchmark = [PaddyBenchmark benchmark:@"SELECTION CHANGED - LAYOUT"];
    [PaddyManager log:@"Updated selection... \nFROM: %@ \nTO: %@", oldSelection, newSelection];
    
    [benchmark logIntermittent:@"Log"];
    
    NSMutableSet *finishedSelectedLayers = [NSMutableSet setWithArray:oldSelection];
    [finishedSelectedLayers minusSet:[NSSet setWithArray:newSelection]];
    
    NSMutableSet *newlySelectedLayers = [NSMutableSet setWithArray:newSelection];
    [newlySelectedLayers minusSet:[NSSet setWithArray:oldSelection]];
    
    [benchmark logIntermittent:@"New/Old sets"];
    
    
//    NSMutableArray *layersThatChanged = [NSMutableArray array];
    
    // All the layers that should be layed out
    NSMutableArray *layoutInstances = [NSMutableArray array];
    
    
    // Cache the NEW model objects
    for (MSLayer *layer in newlySelectedLayers.allObjects) {
        [self addLayerToCache:layer];
    }
    
    [benchmark logIntermittent:@"Cached new"];
    
    // Remove the DONE model objects from the cache – and keep track of which ones changed
    
    PaddySymbolManager *symbolManager = [[PaddyDocumentManager currentPaddyDocument] symbolManager];
    
    for (MSLayer *layer in finishedSelectedLayers.allObjects) {
        
//        [PaddyLayerListPreview clearCacheForLayer:layer];
        
        MSImmutableLayer *cachedModelObject = [self.cachedSelectedModelObjects objectForKey:layer.objectID];
        MSAbsoluteRect *cachedFrame = [self.cachedAbsoluteFrames objectForKey:layer.objectID];
        
        if (cachedModelObject) {
            
            PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer inferringReasonFromModelObject:cachedModelObject andFrame:cachedFrame];
            MSSymbolMaster *parentSymbol;
            
            MSLayerGroup *parent = [layer parentGroup];

            if (!parent) {
                // Check if layer deleted
                MSLayerGroup *cachedParent = [self.cachedParents objectForKey:layer.objectID];
                if (cachedParent) {
                    // Layer was deleted – so its parent should be updated
                    layoutInstance = [PaddyLayoutInstance fromLayer:cachedParent withReason:ChildWasDeleted];
                    
//                    [layersThatChanged addObject:cachedParent];
                    
                    if ([PaddyClass is:cachedParent instanceOf:SymbolMaster]) {
                        parentSymbol = (MSSymbolMaster*)cachedParent;
                    } else if ([cachedParent parentSymbol]) {
                        parentSymbol = [cachedParent parentSymbol];
                    }
                }
            } else {
                MSAbsoluteRect *parentFrame = [self.cachedAbsoluteFrames objectForKey:parent.objectID];
                layoutInstance.originalParentFrame = parentFrame;
            }
            

            if (layoutInstance) {
                [layoutInstances addObject:layoutInstance];
                
                // If it is in or was in a symbol master, the symbol should be updated
                if (!parentSymbol && [layer parentSymbol]) {
                    parentSymbol = [layer parentSymbol];
                }
                
                if (parentSymbol) {
                    [symbolManager.dataManager updateForSymbol:parentSymbol];
                }
            }

            [self.cachedSelectedModelObjects removeObjectForKey:layer.objectID];
            [self.cachedAbsoluteFrames removeObjectForKey:layer.objectID];
        }
        
        [self.cachedParents removeObjectForKey:layer.objectID];
        
        [PaddyCache clearForLayer:layer];
    }
    
    [benchmark logIntermittent:@"Found changed"];
    
    
    // Layout the new layers
    [PaddyManager log:@"LAYERS THAT CHANGED AND NEED UPDATING: %@", layoutInstances];
    [benchmark logIntermittent:@"Log"];
    
    if (layoutInstances.count > 0) {
        [PaddyLayoutManager updateForLayoutInstances:layoutInstances andSaveState:YES];
//        [PaddyLayoutManager layoutLayers:layersThatChanged includingAncestors:YES];
    }
    
    [benchmark logIntermittent:@"Layout layers"];
    
    [benchmark logEnd];
    
    if (newSelection.count == 0) {
        [self.cachedSelectedModelObjects removeAllObjects];
        [self.cachedAbsoluteFrames removeAllObjects];
        [self.cachedParents removeAllObjects];
    }
}


// Called after 'Layer position possibly changed'
- (void)updateLayers:(NSArray*)layers {
    
    if (layers.count < 1) {
        return;
    }
    
    NSMutableArray *layoutInstances = [NSMutableArray array];
    for (MSLayer *layer in layers) {
        MSImmutableLayer *cachedModelObject = [self.cachedSelectedModelObjects objectForKey:layer.objectID];
        MSAbsoluteRect *cachedFrame = [self.cachedAbsoluteFrames objectForKey:layer.objectID];
        
        PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer inferringReasonFromModelObject:cachedModelObject andFrame:cachedFrame];
        
        MSLayerGroup *parent = [layer parentGroup];
        MSAbsoluteRect *parentFrame = [self.cachedAbsoluteFrames objectForKey:parent.objectID];
        layoutInstance.originalParentFrame = parentFrame;
        
        [PaddyManager log:@"Cached: %@, Instance: %@", cachedModelObject, layoutInstance];
        
        if (layoutInstance) {
            [layoutInstances addObject:layoutInstance];
        }
        
//        [self addLayerToCache:layer];
    }
    
    if (layoutInstances.count > 0) {
        [PaddyLayoutManager updateForLayoutInstances:layoutInstances andSaveState:YES];
    }
}

- (void)updateLayer:(MSLayer*)layer withReason:(PaddyLayoutReason)reason {
    
    PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer withReason:reason];
    
    MSLayerGroup *parent = [layer parentGroup];
    MSAbsoluteRect *parentFrame = [self.cachedAbsoluteFrames objectForKey:parent.objectID];
    layoutInstance.originalParentFrame = parentFrame;
    
    if (layoutInstance) {
        [PaddyLayoutManager updateForLayoutInstances:@[layoutInstance] andSaveState:TRUE];
    }
    
}

@end
