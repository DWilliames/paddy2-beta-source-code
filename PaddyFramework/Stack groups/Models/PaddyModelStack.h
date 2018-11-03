//
//  PaddyModelStack.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyModelOrientation.h"

@interface PaddyModelStack : NSObject

@property (nonatomic) PaddyOrientation orientation;
@property (nonatomic) double spacing;
@property (nonatomic) BOOL collapsing;

+ (id)inferFromLayers:(NSArray*)layers;

+ (id)stackFromDictionary:(NSDictionary*)dictionary;

+ (id)stackOrientation:(PaddyOrientation)orientation withSpacing:(double)spacing;
+ (id)stackOrientation:(PaddyOrientation)orientation withSpacing:(double)spacing andCollapsing:(BOOL)collapsing;

+ (BOOL)canLayerStack:(MSLayer*)layer;

- (NSDictionary*)dictionary;

@end
