//
//  PaddyStackGroup.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyModelStack.h"

@interface PaddyStackGroup : NSObject

@property (nonatomic, strong, readonly) MSLayerGroup *layer;

@property (nonatomic, strong, readonly) NSArray *alignments;
@property (nonatomic, strong, readonly) PaddyModelStack *stackProperties;

@property (nonatomic, readonly) BOOL shouldIgnore;

+ (PaddyStackGroup*)fromLayer:(MSLayer*)layer ignoringCache:(BOOL)ignoreCache;
+ (PaddyStackGroup*)fromLayer:(MSLayer*)layer;

+ (BOOL)canBeStackGroup:(MSLayer*)layer;
+ (BOOL)shouldLayerBeIgnored:(MSLayer*)layer;

- (void)updateStackProperties:(PaddyModelStack*)stackProperties;
- (void)updateAlignments:(NSArray*)alignments;

- (BOOL)recalculateSpacingAndAlignment;

- (MSRect*)rectForContentLayers;

+ (PaddyStackGroup*)stackLayers:(NSArray*)layers withProps:(PaddyModelStack*)newProps creatingNewGroup:(BOOL)createNewGroup;

@end
