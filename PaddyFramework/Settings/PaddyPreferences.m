//
//  PaddyPreferences.m
//  PaddyFramework
//
//  Created by David Williames on 3/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPreferences.h"


#define kPrefLayerListIcons @"LayerListIcons"
#define kPrefLayerNames @"UpdateLayerNames"
#define kPrefShowInInspector @"ShowInInspector"

@implementation PaddyPreferences

+ (void)setPreference:(NSObject*)value forKey:(NSString*)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *values = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:kBundleIdentifier]];
    if (!values) {
        values = [NSMutableDictionary dictionary];
    }
    
    [values setObject:value forKey:key];
    
    [defaults setValue:values forKey:kBundleIdentifier];
}

+ (NSObject*)getPreferenceForKey:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *values = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:kBundleIdentifier]];
    if (!values) {
        values = [NSMutableDictionary dictionary];
    }
    
    return [values objectForKey:key];
}


// Show in inspector
+ (void)setShowInInspector:(BOOL)showInInspector {
    [self setPreference:@(showInInspector) forKey:kPrefShowInInspector];
}

+ (BOOL)shouldShowInInspector {
    if ([PaddyManager isVersion52Plus]) { // Sketch 52+
        return FALSE;
    }
    
    NSNumber *inspectorPref = (NSNumber*)[self getPreferenceForKey:kPrefShowInInspector];
    return inspectorPref ? [inspectorPref boolValue] : TRUE;
}



// Layer list icons

+ (void)setIcons:(PaddyIconsPreference)iconsPreference {
    [self setPreference:@(iconsPreference) forKey:kPrefLayerListIcons];
}

+ (PaddyIconsPreference)getIconsPreference {
    NSNumber *iconsPref = (NSNumber*)[self getPreferenceForKey:kPrefLayerListIcons];
    return iconsPref ? [iconsPref integerValue] : DetailedIcons;
}


// Layer names

+ (void)setNames:(PaddyNamesPreference)namesPreference {
    [self setPreference:@(namesPreference) forKey:kPrefLayerNames];
}

+ (PaddyNamesPreference)getNamesPreference {
    NSNumber *namesPref = (NSNumber*)[self getPreferenceForKey:kPrefLayerNames];
    return namesPref ? [namesPref integerValue] : InferLayerName;
}

@end
