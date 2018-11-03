//
//  PaddyPaddingLayer.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingLayer.h"
#import "PaddyLayoutManager.h"
#import "PaddyNameReader.h"
#import "PaddyNameGenerator.h"

@interface PaddyPaddingLayer ()

@property (nonatomic, strong) MSLayer *layer;
@property (nonatomic, strong) PaddyModelPadding *paddingProperties;

@end

@implementation PaddyPaddingLayer

+ (PaddyPaddingLayer*)fromLayer:(MSLayer*)layer ignoringCache:(BOOL)ignoreCache {
    PaddyPaddingLayer *layerCache = [PaddyCache paddingForLayer:layer];
    if (!layerCache || ignoreCache) {
        layerCache = [[PaddyPaddingLayer alloc] initWithLayer:layer];
        
        if (!ignoreCache) {
            [PaddyCache setPadding:layerCache forLayer:layer];
        }
    }

    return layerCache;
}

+ (PaddyPaddingLayer*)fromLayer:(MSLayer*)layer {
    return [self fromLayer:layer ignoringCache:NO];
}

+ (BOOL)canLayerHavePadding:(MSLayer*)layer {
    if (!layer) {
        return false;
    }
    return ([PaddyClass is:layer instanceOf:ShapeGroup] || [PaddyClass is:layer instanceOf:SymbolInstance] || [PaddyClass is:layer instanceOf:Group]);
}

+ (BOOL)shouldLayerBeIgnored:(MSLayer*)layer {
    if ([PaddyClass is:layer instanceOf:Artboard]) {
        return true;
    }
    if ([PaddyClass is:layer instanceOf:Slice]) {
        return true;
    }
    if ([PaddyData shouldLayerBeIgnored:layer]) {
        return true;
    }
    if ([layer isMasked]) {
        return true;
    }
    
    [PaddyManager log:@"Should layer be ignored: %@", layer];
    PaddyStackGroup *stack = [PaddyStackGroup fromLayer:[layer parentGroup]];
    if (stack.shouldIgnore) {
        return true;
    }
    if (stack.stackProperties && stack.stackProperties.collapsing) {
        return !layer.isVisible;
    }
    return false;
}

- (instancetype)initWithLayer:(MSLayer*)layer {
    
    if (![PaddyPaddingLayer canLayerHavePadding:layer]) {
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
        self.paddingProperties = nameReader.paddingProperties;
        
        // Override 'enabled'; because it isn't in the name
        PaddyModelPadding *paddingProps = [PaddyData paddingDataForLayer:self.layer];
//        NSLog(@"Padding props from layer: %@", paddingProps);
//        NSLog(@"Padding props from name: %@", nameReader.paddingProperties);
        
        if (paddingProps) {
            self.paddingProperties.enabled = paddingProps.enabled;
        }
        
        [PaddyData savePaddingData:self.paddingProperties toLayer:self.layer];
    } else if (namePreference != ShowLayerNames){
        self.paddingProperties = [PaddyData paddingDataForLayer:self.layer];
    }
    
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"(%@) %@", self.paddingProperties, self.layer];
}

- (void)updatePaddingProperties:(PaddyModelPadding*)paddingProperties andUpdateLayout:(BOOL)updateLayout {
    
    self.paddingProperties = paddingProperties;
    [PaddyData savePaddingData:self.paddingProperties toLayer:self.layer];
    
    [PaddyNameGenerator updateNameForLayer:self.layer];
    
    if (updateLayout) {
        [PaddyLayoutManager updateForLayer:self.layer withReason:PaddingPropertiesChanged];
        [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
    }
}

- (void)save {
    if (self.paddingProperties) {
        [PaddyData savePaddingData:self.paddingProperties toLayer:self.layer];
    }
}

@end
