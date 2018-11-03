//
//  PaddyPreferences.h
//  PaddyFramework
//
//  Created by David Williames on 3/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyIconsPreference) {
    DefaultIcons = 0,
    DetailedIcons = 1,
    SimplifiedIcons = 2
};

typedef NS_ENUM(NSInteger, PaddyNamesPreference) {
    InferLayerName = 0,
    StripLayerNames = 1,
    ShowLayerNames = 2
};

@interface PaddyPreferences : NSObject

+ (void)setShowInInspector:(BOOL)showInInspector;
+ (BOOL)shouldShowInInspector;

+ (void)setIcons:(PaddyIconsPreference)iconsPreference;
+ (PaddyIconsPreference)getIconsPreference;

+ (void)setNames:(PaddyNamesPreference)namesPreference;
+ (PaddyNamesPreference)getNamesPreference;

@end
