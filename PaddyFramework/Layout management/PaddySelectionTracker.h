//
//  PaddySelectionTracker.h
//  PaddyFramework
//
//  Created by David Williames on 14/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayoutInstance.h"

@class PaddyDocument;

// The purpose is to keep track of selected layers and their properties, to figure out when we should re-lay them out
@interface PaddySelectionTracker : NSObject

@property (nonatomic) BOOL holdOffUntilNextSelection;
@property (nonatomic) BOOL holdOffChangesFromSelection;

- (instancetype)initWithPaddyDocument:(PaddyDocument*)document;

- (void)didLayoutLayers:(NSArray*)layers;
- (void)updatedSelectionFrom:(NSArray*)oldSelection to:(NSArray*)newSelection;

- (void)addLayerToCache:(MSLayer*)layer;
- (void)resetCacheToLayers:(NSArray*)layers;
- (void)updateLayers:(NSArray*)layers;

- (void)updateLayer:(MSLayer*)layer withReason:(PaddyLayoutReason)reason;

@end
