//
//  PaddySymbolDataManager.m
//  PaddyFramework
//
//  Created by David Williames on 14/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySymbolDataManager.h"
#import "PaddyPaddingLayer.h"

#define PaddyHasPaddingKey @"Padding"
#define PaddyHasStackingKey @"Stacking"

@interface PaddySymbolDataManager ()

@property (nonatomic, strong) NSMutableDictionary *cachedSymbolSizes;

// Cache if a symbol has padding or stack groups
@property (nonatomic, strong) NSMutableDictionary *cachedSymbolHasPadding;
@property (nonatomic, strong) NSMutableDictionary *cachedSymbolHasStacking;


@end

@implementation PaddySymbolDataManager

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.cachedSymbolSizes = [NSMutableDictionary dictionary];
    self.cachedSymbolHasPadding = [NSMutableDictionary dictionary];
    self.cachedSymbolHasStacking = [NSMutableDictionary dictionary];
    
    return self;
}


#pragma mark - Cached sizes

- (void)saveCachedSize:(CGSize)size forSymbolInstance:(MSSymbolInstance*)instance andMaster:(MSSymbolMaster*)master {
    if (!instance || !master || (size.width == 0 && size.height == 0)) {
        return;
    }
    
    NSArray *overrides = [instance overrideValues];
    NSString *overridesString = [overrides componentsJoinedByString:@","];
    [PaddyManager log:@"Saving cached size, with overrides: %@", overridesString];
    
    NSValue *sizeToCache = [NSValue valueWithSize:size];
    
    NSMutableDictionary *symbolSizeDictionary = [self.cachedSymbolSizes objectForKey:master.objectID];
    if (!symbolSizeDictionary) {
        symbolSizeDictionary = [NSMutableDictionary dictionary];
    }
    
    [symbolSizeDictionary setObject:sizeToCache forKey:overridesString];
    [self.cachedSymbolSizes setObject:symbolSizeDictionary forKey:master.objectID];
}

- (NSValue*)cachedSizeForSymbolInstance:(MSSymbolInstance*)instance andMaster:(MSSymbolMaster*)master {
    if (!instance || !master) {
        return nil;
    }
    
    NSMutableDictionary *symbolSizeDictionary = [self.cachedSymbolSizes objectForKey:master.objectID];
    if (symbolSizeDictionary) {
        
        NSArray *overrides = [instance overrideValues];
        NSString *overridesString = [overrides componentsJoinedByString:@","];
        [PaddyManager log:@"OVERRIDES: %@", overridesString];
        
        NSValue *cachedSize = [symbolSizeDictionary objectForKey:overridesString];
        if (cachedSize) {
            [PaddyManager log:@"FOUND CACHED SIZE"];
            return cachedSize;
        }
    }
    
    
    return nil;
}

- (void)clearSizingCacheForSymbol:(MSSymbolMaster*)master {
    [self.cachedSymbolSizes removeObjectForKey:master.objectID];
    [self.cachedSymbolHasPadding removeObjectForKey:master.objectID];
    [self.cachedSymbolHasStacking removeObjectForKey:master.objectID];
}



#pragma mark - Symbol props

- (NSDictionary*)updateForSymbol:(MSSymbolMaster*)master {
    
    if (!master) {
        return @{PaddyHasPaddingKey: @(FALSE), PaddyHasStackingKey: @(FALSE)};
    }
    
    // Loop through the layers in the symbol to see if has padding or stacking
    // Then save it in the cache and to the layer itself
    
    BOOL hasPadding = false;
    BOOL hasStacking = false;
    
    for (MSLayer *layer in master.children) {
        // Check for padding
        if (!hasPadding && ![PaddyPaddingLayer shouldLayerBeIgnored:layer]) {
            
            PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
            if (paddingLayer && paddingLayer.paddingProperties) {
                hasPadding = true;
            }
        }
        
        // Check for stacking
        if (!hasStacking && ![PaddyStackGroup shouldLayerBeIgnored:layer]) {
            
            PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
            if (stackGroup && stackGroup.stackProperties) {
                hasStacking = true;
            }
        }
        
        if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
            MSSymbolInstance *instance = (MSSymbolInstance*)layer;
            MSSymbolMaster *instanceMaster = [instance symbolMaster];
            
            NSDictionary *props = [self updateForSymbol:instanceMaster];
            if ([[props objectForKey:PaddyHasPaddingKey] boolValue]) {
                hasPadding = TRUE;
            }
            if ([[props objectForKey:PaddyHasStackingKey] boolValue]) {
                hasStacking = TRUE;
            }
        }
        
        if (hasStacking && hasPadding) {
            break;
        }
    }
    
    [self.cachedSymbolHasPadding setObject:@(hasPadding) forKey:master.objectID];
    [self.cachedSymbolHasStacking setObject:@(hasStacking) forKey:master.objectID];
    
    [PaddyManager log:@"Save cache: %@ \nPadding: %@, Stack: %@", master, (hasPadding ? @"YES" : @"NO"), (hasStacking ? @"YES" : @"NO")];
    
//    NSLog(@"Save cache: %@ \nPadding: %@, Stack: %@", master, (hasPadding ? @"YES" : @"NO"), (hasStacking ? @"YES" : @"NO"));
    
    return @{PaddyHasPaddingKey: @(hasPadding), PaddyHasStackingKey: @(hasStacking)};
   
}

- (BOOL)doesSymbolHavePadding:(MSSymbolMaster*)master {
    NSNumber *hasPadding = [self.cachedSymbolHasPadding objectForKey:master];
    if (!hasPadding) {
        NSDictionary *props = [self updateForSymbol:master];
        return [[props objectForKey:PaddyHasPaddingKey] boolValue];
    } else {
        return [hasPadding boolValue];
    }
}

- (BOOL)doesSymbolHaveStacking:(MSSymbolMaster*)master {
    NSNumber *hasStacking = [self.cachedSymbolHasStacking objectForKey:master];
    if (!hasStacking) {
        NSDictionary *props = [self updateForSymbol:master];
        return [[props objectForKey:PaddyHasStackingKey] boolValue];
    } else {
        return [hasStacking boolValue];
    }
}

@end
