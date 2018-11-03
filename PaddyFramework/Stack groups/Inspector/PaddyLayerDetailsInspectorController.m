//
//  PaddyIgnoreLayerInspectorController.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayerDetailsInspectorController.h"
#import "PaddyData.h"
#import "PaddyLayoutManager.h"
#import "PaddySymbolDataManager.h"

@interface PaddyLayerDetailsInspectorController ()

@property (nonatomic, strong) MSDocument *document;
@property (strong) IBOutlet NSButton *ignoreCheckbox;
@property (weak) IBOutlet NSButton *autoResizeCheckbox;
@property (weak) IBOutlet NSButton *dynamicallyRenderCheckbox;
@end

@implementation PaddyLayerDetailsInspectorController

- (id)initWithDocument:(MSDocument *)document {
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    if (!(self = [super initWithNibName:@"PaddyLayerDetailsInspectorController" bundle:bundle])) {
        return nil;
    }
    
    self.document = document;
    self.layers = [NSArray array];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)toggledCheckbox:(id)sender {
    [self.ignoreCheckbox setAllowsMixedState:FALSE];
    
    BOOL shouldIgnore = (self.ignoreCheckbox.state == NSControlStateValueOn);
    for (MSLayer *layer in self.layers) {
        [PaddyData saveShouldBeIgnored:shouldIgnore toLayer:layer];
        
        // If it had the prefix '-'
        if (!shouldIgnore && layer.name.length > 0 && [[layer.name substringToIndex:1] isEqualToString:@"-"]) {
            layer.name = [layer.name substringFromIndex:1];
        }
    }
    
    [PaddyLayoutManager updateForLayers:self.layers withReason:ShouldIgnorePropertyChanged];
    
//    [PaddyLayoutManager layoutLayers:self.layers includingAncestors:TRUE];
}

- (IBAction)toggledAutoResize:(id)sender {
    
    [self.autoResizeCheckbox setAllowsMixedState:FALSE];
    
    BOOL shouldResize = (self.autoResizeCheckbox.state == NSControlStateValueOn);
    for (MSLayer *layer in self.layers) {
        
        if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
            [PaddyData shouldSymbolBeAutoResized:shouldResize toSymbolInstance:(MSSymbolInstance *)layer];
        }
    }
    
    if (shouldResize) {
        [PaddyLayoutManager updateForLayers:self.layers withReason:AutoResizeSymbolChanged];
    }
}

- (IBAction)toggledDynamicallyRender:(id)sender {
    
    [self.dynamicallyRenderCheckbox setAllowsMixedState:FALSE];
    
    BOOL shouldDynamicallyRender = (self.dynamicallyRenderCheckbox.state == NSControlStateValueOn);
    for (MSLayer *layer in self.layers) {
        
        if ([PaddyClass is:layer instanceOf:SymbolMaster]) {
            [PaddyData shouldSymbolBeDynamicallyRendered:shouldDynamicallyRender toSymbolInstance:(MSSymbolMaster *)layer];
        }
    }
    
    if (shouldDynamicallyRender) {
        [PaddyLayoutManager updateForLayers:self.layers withReason:AutoResizeSymbolChanged];
    }
}


- (BOOL)shouldLayerBeIgnored:(MSLayer*)layer {
    
    BOOL shouldIgnore = [PaddyData shouldLayerBeIgnored:layer];
    if (!shouldIgnore && layer.name.length > 0 && [[layer.name substringToIndex:1] isEqualToString:@"-"]) {
        // Should ignore, but hasn't been saved
        [PaddyData saveShouldBeIgnored:YES toLayer:layer];
        shouldIgnore = YES;
    }
    
    return shouldIgnore;
}

- (void)updateViews:(NSArray*)views {
    // Update the UI based on the selected layers, either checked, not, or mixed
    
    if (self.layers.count < 1) {
        return;
    }
    
    
    // Should ignore layer
    BOOL shouldIgnore = [self shouldLayerBeIgnored:self.layers.firstObject];
    NSControlStateValue switchValue = (shouldIgnore ? NSControlStateValueOn : NSControlStateValueOff);
    
    for (int i = 1; i < self.layers.count; i++) {
        BOOL shouldIgnoreLayer = [self shouldLayerBeIgnored:[self.layers objectAtIndex:i]];
        
        if (shouldIgnoreLayer != shouldIgnore) {
            switchValue = NSControlStateValueMixed;
            break;
        }
    }
    
    [self.ignoreCheckbox setAllowsMixedState:(switchValue == NSControlStateValueMixed)];
    [self.ignoreCheckbox setState:switchValue];
    
    
    // Resize symbol
    BOOL showAutoResize = false;
    BOOL showDynamicallyRender = false;
    
//    if ([PaddyClass is:self.layers.firstObject instanceOf:SymbolInstance]) {
    
        PaddyDocument *document = [PaddyDocumentManager paddyDocumentForDocument:self.document];
        PaddySymbolDataManager *symbolDataManager = document.symbolManager.dataManager;
        
        showAutoResize = [PaddyClass is:self.layers.firstObject instanceOf:SymbolInstance];
        showDynamicallyRender = [PaddyClass is:self.layers.firstObject instanceOf:SymbolMaster];
        
        NSControlStateValue autoResizeSwitchValue = -2;
        NSControlStateValue dynamicallyRenderSwitchValue = -2;
        
        // Only show this if every layer is a Symbol instance, and has padding
        for (MSLayer *layer in self.layers) {
            if (![PaddyClass is:layer instanceOf:SymbolInstance]) {
                showAutoResize = false;
            } else {
                MSSymbolMaster *master = [((MSSymbolInstance*)layer) symbolMaster];
                if (![symbolDataManager doesSymbolHavePadding:master]) {
                    showAutoResize = false;
                }
            }
            
            
            if (![PaddyClass is:layer instanceOf:SymbolMaster]) {
                showDynamicallyRender = false;
            } else {
                MSSymbolMaster *master = (MSSymbolMaster*)layer;
                
                if (!([symbolDataManager doesSymbolHavePadding:master] || [symbolDataManager doesSymbolHaveStacking:master])) {
                    showDynamicallyRender = false;
                }
            }
            
            
            if (showAutoResize) {
                BOOL shouldResize = [PaddyData shouldSymbolBeAutoResized:((MSSymbolInstance*)layer)];
                
                NSControlStateValue state = shouldResize ? NSControlStateValueOn : NSControlStateValueOff;
                if (autoResizeSwitchValue == -2) {
                    autoResizeSwitchValue = state;
                } else if (autoResizeSwitchValue != NSControlStateValueMixed && state != autoResizeSwitchValue) {
                    autoResizeSwitchValue = NSControlStateValueMixed;
                }
            }
            
            if (showDynamicallyRender) {
                BOOL shouldDynamicallyRender = [PaddyData shouldSymbolBeDynamicallyRendered:((MSSymbolMaster*)layer)];
                
                NSControlStateValue state = shouldDynamicallyRender ? NSControlStateValueOn : NSControlStateValueOff;
                if (dynamicallyRenderSwitchValue == -2) {
                    dynamicallyRenderSwitchValue = state;
                } else if (dynamicallyRenderSwitchValue != NSControlStateValueMixed && state != dynamicallyRenderSwitchValue) {
                    dynamicallyRenderSwitchValue = NSControlStateValueMixed;
                }
            }
            
        }
        
        [self.autoResizeCheckbox setAllowsMixedState:(autoResizeSwitchValue == NSControlStateValueMixed)];
        [self.autoResizeCheckbox setState:autoResizeSwitchValue];
        
        [self.dynamicallyRenderCheckbox setAllowsMixedState:(dynamicallyRenderSwitchValue == NSControlStateValueMixed)];
        [self.dynamicallyRenderCheckbox setState:dynamicallyRenderSwitchValue];
//    }
    
    self.autoResizeCheckbox.hidden = !showAutoResize;
    self.dynamicallyRenderCheckbox.hidden = !showDynamicallyRender;
    
    CGRect frame = self.view.frame;
    if (showAutoResize && showDynamicallyRender) {
        frame.size.height = 82;
    } else if (!showAutoResize && !showDynamicallyRender) {
        frame.size.height = 40;
    } else {
        frame.size.height = 58;
    }
    
    [self.view setFrame:frame];
}

- (NSArray*)views {
    [self updateViews:@[self.view]];
    
    return @[self.view];
}

@end
