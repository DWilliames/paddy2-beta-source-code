//
//  PaddyPaddingLayer.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@interface PaddyPaddingLayer : NSObject

@property (nonatomic, strong, readonly) MSLayer *layer;
@property (nonatomic, strong, readonly) PaddyModelPadding *paddingProperties;

+ (PaddyPaddingLayer*)fromLayer:(MSLayer*)layer ignoringCache:(BOOL)ignoreCache;
+ (PaddyPaddingLayer*)fromLayer:(MSLayer*)layer;

+ (BOOL)canLayerHavePadding:(MSLayer*)layer;
+ (BOOL)shouldLayerBeIgnored:(MSLayer*)layer;

- (void)updatePaddingProperties:(PaddyModelPadding*)paddingProperties andUpdateLayout:(BOOL)updateLayout;

- (void)save;

@end
