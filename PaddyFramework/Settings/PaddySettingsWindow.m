//
//  PaddySettingsWindow.m
//  PaddyFramework
//
//  Created by David Williames on 3/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySettingsWindow.h"
#import "PaddyPreferences.h"

@interface PaddySettingsWindow ()

@property (weak) IBOutlet NSPopUpButton *iconsDropdownButton;
@property (weak) IBOutlet NSImageView *iconsImageView;
@property (weak) IBOutlet NSTextField *iconsDropdownExplanation;
@property (weak) IBOutlet NSPopUpButton *layerNamesDropdownButton;
@property (weak) IBOutlet NSTextField *layerNamesDropdownExplanation;
@property (weak) IBOutlet NSButton *showInInspectorCheckbox;

@end

@implementation PaddySettingsWindow

+ (instancetype)shared {
    static PaddySettingsWindow *window = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[PaddySettingsWindow alloc] init];
    });
    
    return window;
}

- (id)init {
    //    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    if (!(self = [super initWithWindowNibName:@"PaddySettingsWindow"])) {
        return nil;
    }
    
    [self styleWindow];
    return self;
}

+ (void)show {
    
    PaddySettingsWindow *windowController = [PaddySettingsWindow shared];
    
    NSWindow* window = [windowController window];
    // Close it, just in case it is already open
    [window close];
    
    NSWindow* keyWindow = [[NSApplication sharedApplication] keyWindow];
    
    [keyWindow addChildWindow:window ordered:NSWindowAbove];
    [window makeKeyWindow];
    
    MSDocument *document = [PaddyManager currentDocument];
    
    [self centerWindow:window comparedToExistingWindow:document.window];
    
}

+ (void)centerWindow:(NSWindow*)window comparedToExistingWindow:(NSWindow*)existingWindow {
    NSRect frame = window.frame;
    NSRect existingFrame = existingWindow.frame;
    
    CGFloat newX = (existingFrame.size.width - frame.size.width) / 2.0 + existingFrame.origin.x;
    CGFloat newY = (existingFrame.size.height - frame.size.height) / 2.0 + existingFrame.origin.y;
    
    [window setFrameOrigin:NSMakePoint(newX, newY)];
}

+ (void)hide {
    [[[PaddySettingsWindow shared] window] close];
}



#pragma mark - Styling

- (void)windowDidLoad {
    [super windowDidLoad];
    
    PaddyIconsPreference iconPref = [PaddyPreferences getIconsPreference];
    [self.iconsDropdownButton selectItemWithTag:iconPref];
    [self setIconsPreference:iconPref];
    
    PaddyNamesPreference namesPref = [PaddyPreferences getNamesPreference];
    [self.layerNamesDropdownButton selectItemWithTag:namesPref];
    [self setLayerNamePreference:namesPref];
    
    BOOL showInInspector = [PaddyPreferences shouldShowInInspector];
    [self.showInInspectorCheckbox setState:(showInInspector ? NSControlStateValueOn : NSControlStateValueOff)];
}

- (void)awakeFromNib {
    
}

- (void)styleWindow {
    NSWindow* window = [self window];
    
    NSWindowStyleMask mask = NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
    
    [window setLevel:NSFloatingWindowLevel];
    [window setStyleMask:mask];
    [window setTitleVisibility:NSWindowTitleHidden];
    [window setTitlebarAppearsTransparent:YES];
    [[window standardWindowButton:NSWindowCloseButton] setHidden:NO];
    [[window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    [[window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [window setHasShadow:TRUE];
    [window setMovableByWindowBackground:FALSE];
    [window setHidesOnDeactivate:FALSE];
}

- (void)setIconsPreference:(PaddyIconsPreference)iconsPref {
    
    NSString *exampleImageName;
    NSMutableString *explanationString = [NSMutableString stringWithString:@"For groups with spacing or alignment. "];
    
    switch (iconsPref) {
        case DefaultIcons:
            exampleImageName = @"example_default.png";
            [explanationString appendString:@"\nShow the Sketch's default group icons."];
            break;
        case DetailedIcons:
            exampleImageName = @"example_detailed.png";
            [explanationString appendString:@"Show a custom icon, \nincluding the alignment and/or orientation."];
            break;
        case SimplifiedIcons:
            exampleImageName = @"example_simplified.png";
            [explanationString appendString:@"\nShow simplified custom icons."];
            break;
    }
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    NSImage *image = [bundle imageForResource:exampleImageName];
    
    [self.iconsImageView setImage:image];
    [self.iconsDropdownExplanation setStringValue:explanationString];
}

- (void)setLayerNamePreference:(PaddyNamesPreference)namePref {
    
    NSMutableString *explanationString = [NSMutableString stringWithString:@"For each layer's name in the layer list, "];
    
    switch (namePref) {
        case InferLayerName:
            [explanationString appendString:@"\ndon't change it."];
            break;
        case StripLayerNames:
            [explanationString appendString:@"\nalways remove any Paddy properties from it."];
            break;
        case ShowLayerNames:
            [explanationString appendString:@"\nalways show properties in it."];
            break;
    }

    [self.layerNamesDropdownExplanation setStringValue:explanationString];
}

#pragma mark - UI interactions

- (IBAction)changedIconPreference:(id)sender {
    
    PaddyIconsPreference newPref = self.iconsDropdownButton.selectedTag;
    [PaddyPreferences setIcons:newPref];
    
    [self setIconsPreference:newPref];
    [self updateLayerList];
}

- (IBAction)changedLayerNamePreference:(id)sender {
    
    PaddyNamesPreference newPref = self.layerNamesDropdownButton.selectedTag;
    [PaddyPreferences setNames:newPref];
    
    [self setLayerNamePreference:newPref];
    [self updateLayerList];
}

- (IBAction)changedInspectorCheckbox:(id)sender {
    
    BOOL showInInspector = self.showInInspectorCheckbox.state == NSControlStateValueOn;
    
    [PaddyPreferences setShowInInspector:showInInspector];
    [self updateInspectorView];
}

- (void)updateLayerList {
    // Update the layer list
    MSDocumentController *documentController = [NSClassFromString(@"MSDocumentController") sharedDocumentController];
    
    for (MSDocument *document in documentController.documents) {
        PaddyDocument *paddyDoc = [PaddyDocumentManager paddyDocumentForDocument:document];
        if (paddyDoc) {
            [paddyDoc updateAllLayerListPreviews];
        }
    }
}

- (void)updateInspectorView {
    
    MSDocumentController *documentController = [NSClassFromString(@"MSDocumentController") sharedDocumentController];
    
    for (MSDocument *document in documentController.documents) {
        [document reloadInspector];
    }
}

@end
