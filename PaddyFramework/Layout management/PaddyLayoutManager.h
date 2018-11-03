//
//  PaddyLayoutManager.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayoutInstance.h"

@interface PaddyLayoutManager : NSObject

+ (void)updateForLayer:(MSLayer*)layer withReason:(PaddyLayoutReason)reason;
+ (void)updateForLayers:(NSArray*)layers withReason:(PaddyLayoutReason)reason;

+ (void)updateForLayoutInstance:(PaddyLayoutInstance*)instance andSaveState:(BOOL)saveState;
+ (void)updateForLayoutInstances:(NSArray*)instances andSaveState:(BOOL)saveState;

+ (NSArray*)sortedLayers:(NSArray*)layers inOrientation:(PaddyOrientation)orientation;
+ (double)totalSpacingForLayers:(NSArray*)layers forOrientation:(PaddyOrientation)orientation;

+ (void)resizeGroup:(MSLayerGroup*)group withOldFrame:(MSAbsoluteRect*)oldFrame;

@end
