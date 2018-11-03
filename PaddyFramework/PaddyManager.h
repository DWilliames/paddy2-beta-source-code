//
//  PaddyManager.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyManager : NSObject

@property (nonatomic, strong) MSDocument *document;
@property (nonatomic, strong) MSPluginBundle *plugin;
@property (nonatomic, strong) MSPluginCommand *command;

@property (nonatomic) BOOL enabled;

+ (instancetype)shared;

+ (void)updateContext:(NSDictionary*)context;
+ (void)showSettings;
+ (void)start;
+ (void)restart;

+ (void)layoutSelection;
+ (void)holdOffUntilNextSelection;
+ (void)holdOffChangesFromSelection;

+ (void)layoutLayers:(NSArray*)layers;


// Actions
+ (void)promptToApplyPadding;
+ (void)autoApplyPadding;
+ (void)applySpacing;


+ (MSDocument*)currentDocument;
+ (NSArray*)selectedLayers;

+ (void)setEnabled:(BOOL)enabled;

+ (void)log:(NSString *)formatString, ... NS_FORMAT_FUNCTION(1,2);

- (BOOL)shouldPixelFit;


// Version control
+ (BOOL)isVersion52Plus;

@end
