//
//  PaddyData.m
//  PaddyFramework
//
//  Created by David Williames on 14/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyData.h"
#import "PaddyModelStack.h"

#define kPaddingData @"Padding"
#define kStackData @"Stack"
#define kAlignmentData @"Alignment"
#define kShouldIgnoreData @"Ignore"
#define kShouldAutoResize @"AutoResize"
#define kShouldDynamicallyRender @"DynamicallyRender"
#define kHasPadding @"HasPadding"

@implementation PaddyData

+ (void)saveValue:(NSObject*)value withKey:(NSString*)key toLayer:(MSLayer*)layer {
    MSPluginBundle *plugin = [PaddyManager.shared plugin];
    MSPluginCommand *command = [PaddyManager.shared command];
    
    [command setValue:value forKey:key onLayer:layer forPluginIdentifier:plugin.identifier];
}

+ (NSObject*)getValueWithKey:(NSString*)key fromLayer:(MSLayer*)layer {
    MSPluginBundle *plugin = [PaddyManager.shared plugin];
    MSPluginCommand *command = [PaddyManager.shared command];
    
    return [command valueForKey:key onLayer:layer forPluginIdentifier:plugin.identifier];
}


#pragma mark - Stack

+ (PaddyModelStack*)stackDataForLayer:(MSLayer*)layer {
    NSDictionary *dictionary = (NSDictionary*)[self getValueWithKey:kStackData fromLayer:layer];
    return [PaddyModelStack stackFromDictionary:dictionary];
}

+ (void)saveStackData:(PaddyModelStack*)stackModel toLayer:(MSLayer*)layer {
    if (stackModel) {
        NSDictionary *dictionary = [stackModel dictionary];
        [self saveValue:dictionary withKey:kStackData toLayer:layer];
    } else {
        [self saveValue:nil withKey:kStackData toLayer:layer];
    }
}


#pragma mark - Alignment

+ (NSArray*)alignmentDataForLayer:(MSLayer*)layer {
    return (NSArray*)[self getValueWithKey:kAlignmentData fromLayer:layer];
}

+ (void)saveAlignmentData:(NSArray*)alignments toLayer:(MSLayer*)layer {
    if (alignments) {
        [self saveValue:alignments withKey:kAlignmentData toLayer:layer];
    } else {
        [self saveValue:nil withKey:kAlignmentData toLayer:layer];
    }
}


#pragma mark - Padding

+ (PaddyModelPadding*)paddingDataForLayer:(MSLayer*)layer {
    NSDictionary *dictionary = (NSDictionary*)[self getValueWithKey:kPaddingData fromLayer:layer];
    return [PaddyModelPadding paddingFromDictionary:dictionary];
}

+ (void)savePaddingData:(PaddyModelPadding*)paddingModel toLayer:(MSLayer*)layer {
    NSLog(@"Save data: %@ to layer: %@", paddingModel, layer);
    if (paddingModel) {
        NSDictionary *dictionary = [paddingModel dictionary];
        [self saveValue:dictionary withKey:kPaddingData toLayer:layer];
    } else {
        [self saveValue:nil withKey:kPaddingData toLayer:layer];
    }
}


#pragma mark - Ignore layer

+ (BOOL)shouldLayerBeIgnored:(MSLayer*)layer {
    NSNumber *value = (NSNumber*)[self getValueWithKey:kShouldIgnoreData fromLayer:layer];
    if (!value) {
        return (layer.name.length > 0 && [[layer.name substringToIndex:1] isEqualToString:@"-"]);
    }
    
    return [value boolValue];
}

+ (void)saveShouldBeIgnored:(BOOL)ignore toLayer:(MSLayer*)layer {
    [self saveValue:@(ignore) withKey:kShouldIgnoreData toLayer:layer];
}


# pragma mark - Auto resize symbol instance

+ (BOOL)shouldSymbolBeAutoResized:(MSSymbolInstance*)symbolInstance {
    NSNumber *value = (NSNumber*)[self getValueWithKey:kShouldAutoResize fromLayer:symbolInstance];
    return value ? [value boolValue] : TRUE;
}

+ (void)shouldSymbolBeAutoResized:(BOOL)autoResize toSymbolInstance:(MSSymbolInstance*)symbolInstance {
    [self saveValue:@(autoResize) withKey:kShouldAutoResize toLayer:symbolInstance];
}


# pragma mark - Dynamically render symbol instance

+ (BOOL)shouldSymbolBeDynamicallyRendered:(MSSymbolMaster*)symbolMaster {
    NSNumber *value = (NSNumber*)[self getValueWithKey:kShouldDynamicallyRender fromLayer:symbolMaster];
    return value ? [value boolValue] : FALSE;
}

+ (void)shouldSymbolBeDynamicallyRendered:(BOOL)dynamicallyRendered toSymbolInstance:(MSSymbolMaster *)symbolMaster {
    [self saveValue:@(dynamicallyRendered) withKey:kShouldDynamicallyRender toLayer:symbolMaster];
}



# pragma mark – Symbol Master has Padding

//+ (BOOL)doesSymbolHavePadding:(MSSymbolMaster*)master {
//    NSNumber *value = (NSNumber*)[self getValueWithKey:kHasPadding fromLayer:master];
//    if (!value) {
//        return [PaddySymbolManager updateIfSymbolhasPadding:master];
//    }
//    
//    return [value boolValue];
//}
//
//+ (void)saveHasPadding:(BOOL)hasPadding toSymbol:(MSSymbolMaster*)master {
//    [self saveValue:@(hasPadding) withKey:kHasPadding toLayer:master];
//}


@end
