//
//  PaddyModelStack.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#define kOrientationKey @"Orientation"
#define kSpacingKey @"Spacing"
#define kCollapsingKey @"Collapsing"

#import "PaddyModelStack.h"
#import "PaddyLayoutManager.h"

@interface PaddyModelStack ()

@end

@implementation PaddyModelStack

+ (id)inferFromLayers:(NSArray*)layers {
    
    if (layers.count < 1) {
        return nil;
    }
    
    [PaddyManager log:@"WILL INFER STACK FOR: %@", layers];
    PaddyBenchmark *benchmark = [PaddyBenchmark benchmark:@"Infer stack props"];
    
    // Remove layers that are 'Padding backgrounds'
    
    MSLayer *firstLayer = [layers firstObject];
    
    if (layers.count == 1 && [PaddyClass is:[layers firstObject] instanceOf:Group]) {
        layers = [(MSLayerGroup*)firstLayer layers];
        firstLayer = [layers firstObject];
    }
    
    NSMutableArray *filteredLayers = [NSMutableArray array];
    for (MSLayer *layer in layers) {
        if (![PaddyStackGroup shouldLayerBeIgnored:layer]) {
            [filteredLayers addObject:layer];
        }
    }

    double verticalSpacing = [PaddyLayoutManager totalSpacingForLayers:filteredLayers forOrientation:Vertical];
    double horizontalSpacing = [PaddyLayoutManager totalSpacingForLayers:filteredLayers forOrientation:Horizontal];
    
    BOOL isHorizontal = (horizontalSpacing > verticalSpacing);
    
    double totalSpacing = (isHorizontal ? horizontalSpacing : verticalSpacing);
    PaddyOrientation orientation = (isHorizontal ? Horizontal : Vertical);
    
    double spacing = filteredLayers.count > 1 ? round(totalSpacing / (filteredLayers.count - 1)) : 0;
    
    [PaddyManager log:@"ASSUMING STACK PROPS: Total spacing: %g, Spacing: %g", totalSpacing, spacing];
    [benchmark logEnd];

    return [PaddyModelStack stackOrientation:orientation withSpacing:spacing];
}

+ (id)stackFromDictionary:(NSDictionary*)dictionary {
    if (!dictionary) {
        return nil;
    }
    
    PaddyOrientation orientation = [[dictionary objectForKey:kOrientationKey] integerValue];
    double spacing = [[dictionary objectForKey:kSpacingKey] doubleValue];
    BOOL collapsing = [[dictionary objectForKey:kCollapsingKey] boolValue];
    
    return [PaddyModelStack stackOrientation:orientation withSpacing:spacing andCollapsing:collapsing];
}

+ (id)stackOrientation:(PaddyOrientation)orientation withSpacing:(double)spacing {
    return [PaddyModelStack stackOrientation:orientation withSpacing:spacing andCollapsing:TRUE];
}

+ (id)stackOrientation:(PaddyOrientation)orientation withSpacing:(double)spacing andCollapsing:(BOOL)collapsing {
    return [[PaddyModelStack alloc] initWithOrientation:orientation withSpacing:spacing andCollapsing:collapsing];
}

- (id)initWithOrientation:(PaddyOrientation)orientation withSpacing:(double)spacing andCollapsing:(BOOL)collapsing {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.orientation = orientation;
    self.spacing = spacing;
    self.collapsing = collapsing;
    
    return self;
}

+ (BOOL)canLayerStack:(MSLayer*)layer {
    if (!layer) {
        return false;
    }
    
    return ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:Artboard]);
}

- (NSString*)description {
    
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%g, %@", self.spacing, [PaddyModelOrientation stringFromOrientation:self.orientation]];
    
    if (self.collapsing) {
        [string appendString:@" (collapsing)"];
    }
    
    return string;
}

- (NSDictionary*)dictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:@(self.orientation) forKey:kOrientationKey];
    [dictionary setObject:@(self.spacing) forKey:kSpacingKey];
    [dictionary setObject:@(self.collapsing) forKey:kCollapsingKey];
    
    return dictionary;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return false;
    }
    
    PaddyModelStack *props = (PaddyModelStack*)object;
    
    return (props.spacing == self.spacing) && (props.orientation == self.orientation) && (props.collapsing == self.collapsing);
}

@end
