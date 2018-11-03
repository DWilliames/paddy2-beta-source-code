//
//  PaddyManager.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyManager.h"
#import "PaddyLayoutManager.h"
#import "PaddySettingsWindow.h"
#import "PaddyLayerListPreview.h"
#import "PaddyStackPromptWindow.h"
#import "PaddyPromptWindowManager.h"
#import "PaddyPaddingManager.h"

@interface PaddyManager ()

@end

@implementation PaddyManager

#pragma mark - Singleton

+ (instancetype)shared {
    static PaddyManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PaddyManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    [PaddyManager loadBundles];
    
    return self;
}

+ (void)loadBundles {
    NSArray *bundles = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"framework" subdirectory:nil];
    for (NSURL *bundleURL in bundles){
        NSBundle *child = [NSBundle bundleWithURL:bundleURL];
        [child load];
    }
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [PaddySwizzle appendMethod:@"MSPluginManager_disablePlugin:" with:^(id sender, va_list args) {
            MSPluginBundle *plugin = (__bridge MSPluginBundle*)args;
            
            if ([plugin.identifier isEqualToString:PaddyManager.shared.plugin.identifier]) {
                [PaddyManager setEnabled:false];
            }
        }];
        
        [PaddySwizzle appendMethod:@"MSPluginManager_enablePlugin:" with:^(id sender, va_list args) {

            MSPluginBundle *plugin = (__bridge MSPluginBundle*)args;
            
            if ([plugin.identifier isEqualToString:PaddyManager.shared.plugin.identifier]) {
                [PaddyManager setEnabled:true];
            } else if ([plugin.identifier isEqualToString:kAnimaBundleIdentifier]) {
                [PaddyManager presentAnimaUltimatum];
            } else if ([plugin.identifier isEqualToString:kPaddy1BundleIdentifier]) {
                AppController *appController = [NSClassFromString(@"AppController") sharedInstance];
                MSPluginManagerWithActions *pluginManager = appController.pluginManager;
                
                [pluginManager disablePlugin:plugin];
                [[PaddyManager currentDocument] showMessage:@"Cannot enable Paddy 1 whilst Paddy 2 is enabled"];
            }
        }];
        
        [PaddySwizzle appendMethod:@"MSPluginsPreferencePane_togglePluginEnabled:" with:^(id sender, va_list args) {
            [PaddyManager log:@"Toggle plugin enabled"];
        }];
    });
}

+ (void)setEnabled:(BOOL)enabled {
    PaddyManager.shared.enabled = enabled;
    
    [PaddyManager log:@"PLUGIN ENABLED: %@", (enabled ? @"YES" : @"NO")];
    
    if (enabled) {
        
        AppController *appController = [NSClassFromString(@"AppController") sharedInstance];
        MSPluginManagerWithActions *pluginManager = appController.pluginManager;
        
        MSPluginBundle *paddy1Plugin = [pluginManager.plugins objectForKey:kPaddy1BundleIdentifier];
        if (paddy1Plugin && paddy1Plugin.isEnabled) {
            [pluginManager disablePlugin:paddy1Plugin];
            [[PaddyManager currentDocument] showMessage:@"Automatically disabled Paddy 1"];
        }
        
        // Setup Document manager for all open documents
        MSDocumentController *documentController = [NSClassFromString(@"MSDocumentController") sharedDocumentController];
        
        [PaddyManager log:@"Setup for existing documents: %@", documentController.documents];
        
        for (MSDocument *document in documentController.documents) {
            [PaddyDocumentManager setupForDocument:document];
        }
    } else {
        [PaddyDocumentManager tearDownAll];
        [PaddyLayerListPreview clearAllCaches];
    }
}

#pragma mark - Setup

+ (void)updateContext:(NSDictionary*)context {
    MSDocument *document = [NSClassFromString(@"MSDocument") currentDocument];
    
    PaddyManager.shared.document = document;
    PaddyManager.shared.plugin = [context objectForKey:@"plugin"];
    PaddyManager.shared.command = [context objectForKey:@"command"];
}

+ (void)start {
    
    AppController *appController = [NSClassFromString(@"AppController") sharedInstance];
    MSPluginManagerWithActions *pluginManager = appController.pluginManager;
    
    [PaddyManager setEnabled:true];
    
    if ([self isVersion52Plus]) {
        // Version 52+ is unsupported
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"Paddy 2 is broken in this version of Sketch 😱🤖😢"];
        [alert setInformativeText:@"Unfortunately Paddy 2 doesn't work with with Sketch 52+ — I'm looking into it, but can't give any timeframe right now. Sorry."];
        [alert addButtonWithTitle:@"Got it"];
        
        NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
        NSImage *icon = [bundle imageForResource:@"icon_rounded.png"];
        [alert setIcon:icon];
        
        [alert runModal];
        [PaddyManager setEnabled:false];
        [pluginManager disablePlugin:PaddyManager.shared.plugin];
        return;
    }
    
    
    NSString *currentVersion = PaddyManager.shared.plugin.version;
    
//    var pluginManager = AppController.sharedInstance().pluginManager()
//    var plugin = pluginManager.plugins().objectForKey('com.animaapp.stc-sketch-plugin')

    
    
    
    // If anima is installed and enabled... we're going to have to ask the user to disable it
    MSPluginBundle *animaPlugin = [pluginManager.plugins objectForKey:kAnimaBundleIdentifier];
    if (animaPlugin && animaPlugin.isEnabled) {
        [self presentAnimaUltimatum];
        return;
    }
    
    MSPluginBundle *paddy1Plugin = [pluginManager.plugins objectForKey:kPaddy1BundleIdentifier];
    if (paddy1Plugin && paddy1Plugin.isEnabled) {
        [pluginManager disablePlugin:paddy1Plugin];
        [[PaddyManager currentDocument] showMessage:@"Automatically disabled Paddy 1"];
    }
    
    NSString *lastUsedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kPaddyLastUsedVersionKey];
    
    // If the current version is different to the 'last used version'
    if (!lastUsedVersion) {
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kPaddyLastUsedVersionKey];
    } else if (![lastUsedVersion isEqualToString:currentVersion]) {
        // Save the current version
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kPaddyLastUsedVersionKey];
        
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"Thank you for updating Paddy 🎉"];
        [alert setInformativeText:@"The updated version of Paddy won't work until you restart Sketch.\n\nDon't worry, it should reopen your current documents for you. 🙌"];
        [alert addButtonWithTitle:@"Restart now"];
        [alert addButtonWithTitle:@"Later"];
        
        NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
        NSImage *icon = [bundle imageForResource:@"icon_rounded.png"];
        [alert setIcon:icon];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            [self restart];
        } else {
            // Disable the plugin
//            AppController *appController = [NSClassFromString(@"AppController") sharedInstance];
//            MSPluginManagerWithActions *pluginManager = appController.pluginManager;
//            [pluginManager disablePlugin:PaddyManager.shared.plugin];
        }
    }
}

// Return TRUE if restarting
+ (BOOL)presentAnimaUltimatum {
    
    if (!PaddyManager.shared.plugin.isEnabled) {
        return false;
    }
    
    AppController *appController = [NSClassFromString(@"AppController") sharedInstance];
    MSPluginManagerWithActions *pluginManager = appController.pluginManager;
    
    MSPluginBundle *animaPlugin = [pluginManager.plugins objectForKey:kAnimaBundleIdentifier];
    
    NSString *currentVersion = PaddyManager.shared.plugin.version;
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kPaddyLastUsedVersionKey];
    
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:@"Conflict for Paddy and Anima Toolkit 🙈"];
    [alert setInformativeText:@"Unfortunately, Paddy doesn't play nice with Anima Toolkit; so you're going to have to make the difficult choice of using one over the other...\n\nTo use Paddy instead, Anima will be disabled and Sketch will restart (don't worry, it should repon your current documents for you.)\n\n"];
    [alert addButtonWithTitle:@"Disable Anima and restart"];
    [alert addButtonWithTitle:@"Use Anima instead of Paddy"];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    NSImage *icon = [bundle imageForResource:@"icon_rounded.png"];
    [alert setIcon:icon];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [pluginManager disablePlugin:animaPlugin];
        [self restart];
        return true;
    } else {
        [pluginManager disablePlugin:PaddyManager.shared.plugin];
        return false;
    }
}


// For testing purposes
+ (void)restart {
    
    MSDocumentController *documentController = [NSClassFromString(@"MSDocumentController") sharedDocumentController];
    
    // Remember the URLs of all the documents that are currently open
    NSMutableSet *documentURLStrings = [NSMutableSet set];
    
    NSArray *documents = documentController.documents;
    for (MSDocument *document in documents) {
        
        if (document.fileURL && document.fileURL.absoluteString) {
            [documentURLStrings addObject:document.fileURL.absoluteString];
        }
        
        [document close];
    }
    
    for (NSWindow *window in [NSApp windows]) {
        [window close];
    }
    
    float seconds = 1; // Delay before restart
    
    NSMutableString *command = [NSMutableString string];
    [command appendFormat:@"sleep %f;", seconds];
    [command appendFormat:@"open \"%@\";", [[NSBundle mainBundle] bundlePath]];
    
    for (NSString *documentURLString in documentURLStrings) {
        [command appendFormat:@"open \"%@\";", documentURLString];
    }

    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"%@", command]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    
    [NSApp terminate:nil];
}


+ (void)showSettings {
    [PaddyManager log:@"SHOW SETTINGS!"];
    [PaddySettingsWindow show];
}

+ (void)layoutSelection {
    [PaddyManager log:@"LAYOUT SELECTION"];
    
    [PaddyLayoutManager updateForLayers:[self selectedLayers] withReason:CustomLayoutSelection];
    
    PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
    document.selectionTracker.holdOffChangesFromSelection = FALSE;
}

+ (void)holdOffUntilNextSelection {
    [PaddyManager log:@"Hold off until nest selection"];
    PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
    document.selectionTracker.holdOffUntilNextSelection = TRUE;
}

+ (void)holdOffChangesFromSelection {
    [PaddyManager log:@"Hold off changes from selection"];
    PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
    document.selectionTracker.holdOffChangesFromSelection = TRUE;
}

+ (void)layoutLayers:(NSArray*)layers {
    [PaddyManager log:@"LAYOUT LAYERS"];
    
    NSMutableArray *validLayers = [NSMutableArray array];
    for (id layer in layers) {
        if ([PaddyClass does:layer inheritFrom:Layer]) {
            [validLayers addObject:layer];
        }
    }
    
    [PaddyLayoutManager updateForLayers:validLayers withReason:CustomLayoutSelection];
}


#pragma mark - Helpers

+ (void)log:(NSString *)formatString, ... NS_FORMAT_FUNCTION(1,2)  {
    
    if (PRODUCTION || !LOGGING_ENABLED) {
        return;
    }
    
    va_list args;
    va_start(args, formatString);
    NSString *newString = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    NSLog(@"%@", newString);
    
//    [PaddyManager.shared.command print:newString];
}

+ (MSDocument*)currentDocument {
    return [NSClassFromString(@"MSDocument") currentDocument];
}

+ (NSArray*)selectedLayers {
    MSDocument *currentDocument = [self currentDocument];
    MSLayerArray *layerArray = [currentDocument selectedLayers];
    return layerArray.layers;
}

- (BOOL)shouldPixelFit {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tryToFitToPixelBounds"];
}


#pragma mark - Actions

+ (void)promptToApplyPadding {
//    [[PaddyManager currentDocument] showMessage:@"Prompt coming soon – in next release"];
    
    [self applyPaddingToSelectionWithPrompt:true];
    
//    [PaddyPromptWindowManager show:PaddingPrompt];
}

+ (void)autoApplyPadding {
    
    [self applyPaddingToSelectionWithPrompt:false];
    
//    NSArray *paddingLayers = [PaddyUtils map:[self selectedLayers] withBlock:^id(MSLayer *layer, NSUInteger idx) {
//        return [PaddyPaddingLayer fromLayer:layer];
//    }];
//
//    for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
//        PaddyModelPadding *paddingProperties = [PaddyModelPadding inferFromLayer:paddingLayer.layer];
//        [paddingLayer updatePaddingProperties:paddingProperties andUpdateLayout:false];
//    }
//
//    [PaddyLayoutManager updateForLayers:[self selectedLayers] withReason:PaddingPropertiesChanged];
//
//    [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
//    [[PaddyDocumentManager currentPaddyDocument] refreshInspector];
}

+ (void)applyPaddingToSelectionWithPrompt:(BOOL)prompt {
    
    NSArray *selectedLayers = [self selectedLayers];
    
    NSMutableArray *uniqueLayers = [NSMutableArray array];
    
    for (MSLayer *layer in selectedLayers) {
        if ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:Artboard]) {
            [uniqueLayers addObject:layer];
        } else if (![PaddyLayerUtils doesArray:uniqueLayers containSiblingToLayer:layer]) {
            [uniqueLayers addObject:layer];
        }
    }
    
    NSArray *backgrounds = [PaddyUtils map:uniqueLayers withBlock:^id(MSLayer *layer, NSUInteger idx) {
        return [PaddyPaddingManager getBackgroundForLayer:layer];
    }];
    
    
    MSLayer *background = [PaddyUtils find:backgrounds withBlock:^BOOL(MSLayer *layer) {
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
        return (paddingLayer != nil && paddingLayer.paddingProperties != nil);
    }];
    
    PaddyPaddingLayer *backgroundWithPadding;
    if (background) {
        backgroundWithPadding = [PaddyPaddingLayer fromLayer:background];
    }
    
    __block PaddyModelPadding *padding = [PaddyModelPadding defaultModel];
    
    if (backgroundWithPadding && backgroundWithPadding.paddingProperties) {
        padding = backgroundWithPadding.paddingProperties;
    }
    
    
    void (^modelCompletion)(PaddyModelPadding*) = ^(PaddyModelPadding *model) {
        
        NSMutableArray *layersToUpdate = [NSMutableArray array];
        
        for (MSLayer *layer in uniqueLayers) {
            MSLayer *backgroundLayer = [PaddyPaddingManager getBackgroundForLayer:layer];
            
            PaddyModelPadding *layerPadding = model;
            
            if (!backgroundLayer) {
                MSShapeGroup *bg = [NSClassFromString(@"MSShapeGroup") shapeWithRect:NSMakeRect(0, 0, 100, 100)];
                bg.style = [NSClassFromString(@"MSDefaultStyle") defaultStyle];
                bg.name = @"Background";
                
                NSArray *selectedSiblings = [PaddyLayerUtils getSiblingsToLayer:layer fromArray:selectedLayers];
                
                MSRect *frame = [PaddyLayerUtils boundingRectForLayers:selectedSiblings];
                bg.frame.x = frame.x;
                bg.frame.y = frame.y;
                bg.frame.width = frame.width;
                bg.frame.height = frame.height;
                
                backgroundLayer = bg;
                
                if ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:Artboard]) {

                    // It's a group, so insert the new BG within it
                    MSLayerGroup *group = (MSLayerGroup*)layer;
                    
                    bg.frame.x -= group.frame.x;
                    bg.frame.y -= group.frame.y;
                    
                    [group insertLayer:bg atIndex:0];
                } else {
                    MSLayerGroup *parent = [layer parentGroup];
                    if (!parent) {
                        return;
                    }
                    
                    if ([PaddyClass is:parent instanceOf:Page] || selectedSiblings.count > 1) {
                        // All siblings to place in the new group
                        
                        MSLayerGroup *group = [NSClassFromString(@"MSLayerGroup") new];
                        group.name = @"Group";
                        [group addLayers:@[bg]];
                        
                        for (MSLayer *layer in selectedSiblings) {
                            [layer removeFromParent];
                            [group addLayers:@[layer]];
                        }
                        
                        [parent addLayers:@[group]];
                    } else {
                        [parent insertLayer:bg atIndex:0];
                    }
                    
                    [parent resizeToFitChildrenWithOption:1];
                }
                
            } else if (!prompt) {
                layerPadding = [PaddyModelPadding inferFromLayer:backgroundLayer];
            }
            
            PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:backgroundLayer];
            
            [paddingLayer updatePaddingProperties:layerPadding andUpdateLayout:false];
            
            [layersToUpdate addObject:paddingLayer.layer];
        }
        
        PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
        
        [PaddyLayoutManager updateForLayers:layersToUpdate withReason:PaddingPropertiesChanged];
        [document updateAllLayerListPreviews];
        [document refreshInspector];
        
        [document.selectionTracker resetCacheToLayers:selectedLayers];
    };
    
    
    if (prompt) {
        [PaddyPromptWindowManager showPaddingPromptWithModel:padding andCallback:^(PaddyModelPadding *model) {
            modelCompletion(model);
        }];
    } else {
        modelCompletion(padding);
    }
    
}

+ (void)applySpacing {
    
    NSArray *selectedLayers = [self selectedLayers];
    BOOL valid = (selectedLayers.count > 0);
    
    for (MSLayer *layer in selectedLayers) {
        if (valid) {
            valid = !([PaddyClass is:layer instanceOf:Artboard] || [PaddyClass is:layer instanceOf:Page]);
        }
    }
    
    if (valid) {
        [PaddyPromptWindowManager show:SpacingPrompt];
    }
}

+ (BOOL)isVersion52Plus {
    NSInteger buildNumber = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];

    return buildNumber >= 66869;
}

@end
