//
//  PaddyData.h
//  PaddyFramework
//
//  Created by David Williames on 14/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyData : NSObject

+ (PaddyModelStack*)stackDataForLayer:(MSLayer*)layer;
+ (void)saveStackData:(PaddyModelStack*)stackModel toLayer:(MSLayer*)layer;

+ (NSArray*)alignmentDataForLayer:(MSLayer*)layer;
+ (void)saveAlignmentData:(NSArray*)alignments toLayer:(MSLayer*)layer;

+ (PaddyModelPadding*)paddingDataForLayer:(MSLayer*)layer;
+ (void)savePaddingData:(PaddyModelPadding*)paddingModel toLayer:(MSLayer*)layer;

+ (BOOL)shouldLayerBeIgnored:(MSLayer*)layer;
+ (void)saveShouldBeIgnored:(BOOL)ignore toLayer:(MSLayer*)layer;

+ (BOOL)shouldSymbolBeAutoResized:(MSSymbolInstance*)symbolInstance;
+ (void)shouldSymbolBeAutoResized:(BOOL)autoResize toSymbolInstance:(MSSymbolInstance*)symbolInstance;

+ (BOOL)shouldSymbolBeDynamicallyRendered:(MSSymbolMaster*)symbolMaster;
+ (void)shouldSymbolBeDynamicallyRendered:(BOOL)dynamicallyRendered toSymbolInstance:(MSSymbolMaster*)symbolMaster;

@end
