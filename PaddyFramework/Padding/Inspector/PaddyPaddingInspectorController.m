//
//  PaddyPaddingInspectorController.m
//  PaddyFramework
//
//  Created by David Williames on 15/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingInspectorController.h"
#import "PaddyPaddingHeaderInspectorView.h"
#import "PaddyPaddingLayer.h"
#import "PaddyPaddingEdgesOverlayButton.h"
#import "PaddyLayoutManager.h"

@interface PaddyPaddingInspectorController ()

@property (nonatomic, strong) MSDocument *document;

@property (nonatomic, strong) IBOutlet NSImageView *accessoryButton;
@property (nonatomic, strong, retain) IBOutlet PaddyPaddingHeaderInspectorView *headerView;
@property (nonatomic, strong, retain) IBOutlet NSView *contentView;

@property (nonatomic, strong) IBOutlet MSUpDownTextField *topTextField;
@property (nonatomic, strong) IBOutlet MSUpDownTextField *rightTextField;
@property (nonatomic, strong) IBOutlet MSUpDownTextField *bottomTextField;
@property (nonatomic, strong) IBOutlet MSUpDownTextField *leftTextField;

@property (strong) IBOutlet MSTextLabelForUpDownField *topLabel;
@property (strong) IBOutlet MSTextLabelForUpDownField *rightLabel;
@property (strong) IBOutlet MSTextLabelForUpDownField *bottomLabel;
@property (strong) IBOutlet MSTextLabelForUpDownField *leftLabel;

// Constraints
@property (weak) IBOutlet NSLayoutConstraint *topLeading;
@property (weak) IBOutlet NSLayoutConstraint *topTrailing;
@property (weak) IBOutlet NSLayoutConstraint *rightLeading;
@property (weak) IBOutlet NSLayoutConstraint *rightTrailing;
@property (weak) IBOutlet NSLayoutConstraint *bottomLeading;
@property (weak) IBOutlet NSLayoutConstraint *bottomTrailing;
@property (weak) IBOutlet NSLayoutConstraint *leftLeading;
@property (weak) IBOutlet NSLayoutConstraint *leftTrailing;

@property (strong) IBOutlet NSTextField *headerTitle;

@property (strong) IBOutlet NSButton *enabledCheckbox;

@property (strong) IBOutlet PaddyPaddingEdgesOverlayButton *buttonOverlayView;

@property (nonatomic) BOOL hasPadding;

@property (nonatomic) BOOL isChangingTextValues;

@property (nonatomic) PaddyPaddingViewInputCount inputCount;

@end

@implementation PaddyPaddingInspectorController

- (id)initWithDocument:(MSDocument *)document {
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    if (!(self = [super initWithNibName:@"PaddyPaddingInspectorController" bundle:bundle])) {
        return nil;
    }
    
    self.document = document;
    self.layers = [NSArray array];
    
    self.hasPadding = false;
    self.isChangingTextValues = false;
    
    self.inputCount = AllInputs;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topTextField.delegate = self;
    self.rightTextField.delegate = self;
    self.bottomTextField.delegate = self;
    self.leftTextField.delegate = self;
    
    NSTrackingArea *headerTrackingArea = [[NSTrackingArea alloc] initWithRect:self.headerView.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self.headerView addTrackingArea:headerTrackingArea];
    
    NSTrackingArea *buttonOverlayTrackingArea = [[NSTrackingArea alloc] initWithRect:self.buttonOverlayView.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self.buttonOverlayView userInfo:nil];
    [self.contentView addTrackingArea:buttonOverlayTrackingArea];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headerView.controller = self;
    
    ObserverBlock textFieldCallback = ^(id oldValue, id newValue) {
        [PaddyManager log:@"Spacing text change from %@ to: %@", oldValue, newValue];
        
        if (self.isChangingTextValues) {
            [PaddyManager log:@"Is currently setting the text value, so won't do anything"];
        } else if (oldValue != newValue) {
            [self updatePaddingProps];
        }
    };
    
    [PaddyObserver observeKeyPath:@"stringValue" ofObject:self.topTextField withCallback:textFieldCallback];
    [PaddyObserver observeKeyPath:@"stringValue" ofObject:self.rightTextField withCallback:textFieldCallback];
    [PaddyObserver observeKeyPath:@"stringValue" ofObject:self.bottomTextField withCallback:textFieldCallback];
    [PaddyObserver observeKeyPath:@"stringValue" ofObject:self.leftTextField withCallback:textFieldCallback];
    
    self.topLabel.upDownTextField = self.topTextField;
    self.rightLabel.upDownTextField = self.rightTextField;
    self.bottomLabel.upDownTextField = self.bottomTextField;
    self.leftLabel.upDownTextField = self.leftTextField;
    
    self.topLabel.tag = 99;
    self.rightLabel.tag = 99;
    self.bottomLabel.tag = 99;
    self.leftLabel.tag = 99;
}

- (void)dealloc {
    [PaddyObserver removeObserversOfObject:self.topTextField];
    [PaddyObserver removeObserversOfObject:self.rightTextField];
    [PaddyObserver removeObserversOfObject:self.bottomTextField];
    [PaddyObserver removeObserversOfObject:self.leftTextField];
}

- (BOOL)shouldShowForLayers:(NSArray*)layers {
    
    // Conditions
    // - More than one layer
    // - Each layer should be allowed to have padding
    // - Each layer needs to be the same – they all have padding, or none have padding
    
    if (layers.count < 1) {
        return false;
    }
    
    MSLayer *first = [layers firstObject];
    
    PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:first];
    
    if (!paddingLayer) {
        return false;
    }
    
    BOOL hasPadding = paddingLayer.paddingProperties != nil;
    
    for (int i = 1; i < layers.count; i++) {
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:[layers objectAtIndex:i]];
        if ((paddingLayer.paddingProperties != nil) != hasPadding) {
            return false;
        }
    }
    
    return true;
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    
    // @"inspector_options_hover.tiff"
    if (!self.hasPadding) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add_hover.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash_hover.tiff"]];
    }
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    
    // @"inspector_options.tiff"
    if (!self.hasPadding) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash.tiff"]];
    }
}

- (void)headerMouseDown {
    
    // @"inspector_text.tiff"
    if (!self.hasPadding) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add_pressed.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash_pressed.tiff"]];
    }
}

- (void)headerMouseUp {
    
    // Shouldn't be possible
    if (self.layers.count < 1) {
        return;
    }
    
    NSArray *paddingLayers = [PaddyUtils map:self.layers withBlock:^id(MSLayer *layer, NSUInteger idx) {
        return [PaddyPaddingLayer fromLayer:layer];
    }];
    
    [PaddyManager log:@"MOUSE UP: %@", self.layers];
    PaddyPaddingLayer *paddingLayer = [paddingLayers firstObject];
    
    // Shouldn't be possible
    if (!paddingLayer) {
        return;
    }
    
    self.hasPadding = (paddingLayer.paddingProperties != nil);
    
    // REMOVE PADDING
    if (self.hasPadding) {
        for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
            [paddingLayer updatePaddingProperties:nil andUpdateLayout:false];
        }
    }
    
    // ADD PADDING
    else {
        
        BOOL commandHeld = ([NSEvent modifierFlags] & NSEventModifierFlagCommand) != 0;
        BOOL optionHeld = ([NSEvent modifierFlags] & NSEventModifierFlagOption) != 0;
        
        for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
            PaddyModelPadding *paddingProperties = (commandHeld || optionHeld) ? [PaddyModelPadding defaultModel] : [PaddyModelPadding inferFromLayer:paddingLayer.layer];
            [paddingLayer updatePaddingProperties:paddingProperties andUpdateLayout:false];
        }
    }
    
    [PaddyLayoutManager updateForLayers:self.layers withReason:PaddingPropertiesChanged];
    [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
    
    if (!self.hasPadding) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add_hover.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash_hover.tiff"]];
    }
    
    MSInspectorController *inspectorController = [self.document inspectorController];
    MSNormalInspector *normalInspector = [inspectorController normalInspector];
    MSInspectorStackView *stackView = [normalInspector stackView];
    
    [stackView reloadSubviews];
}

- (void)toggleInputCount {
    self.inputCount++;
    if (self.inputCount > 2) {
        self.inputCount = 0;
    }
    [self inputCountUpdated];
    [self updatePaddingProps];
    
    PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:[self.layers firstObject]];
    if (paddingLayer) {
        [paddingLayer save];
    }
}

- (void)inputCountUpdated {
    
    switch (self.inputCount) {
        case AllInputs:
            // Top: 31 - 142
            // Right: 75 - 98
            // Bottom: 119 - 54
            // Left: 163 - 10
            
            self.topLeading.constant = 31;
            self.topTrailing.constant = 142;
            self.topLabel.stringValue = @"Top";
            
            self.rightTextField.hidden = NO;
            self.rightLabel.hidden = NO;
            self.rightLeading.constant = 75;
            self.rightTrailing.constant = 98;
            self.rightLabel.stringValue = @"Right";
            
            self.bottomTextField.hidden = NO;
            self.bottomLabel.hidden = NO;
            self.bottomLeading.constant = 119;
            self.bottomTrailing.constant = 54;
            
            self.leftTextField.hidden = NO;
            self.leftLabel.hidden = NO;
            self.leftLeading.constant = 163;
            self.leftTrailing.constant = 10;
            
            break;
        case TwoInputs:
            self.topLeading.constant = 31;
            self.topTrailing.constant = 98;
            self.topLabel.stringValue = @"Top / Bottom";
            
            self.rightTextField.hidden = NO;
            self.rightLabel.hidden = NO;
            self.rightLeading.constant = 119;
            self.rightTrailing.constant = 10;
            self.rightLabel.stringValue = @"Right / Left";
            
            self.bottomTextField.hidden = YES;
            self.bottomLabel.hidden = YES;
            
            self.leftTextField.hidden = YES;
            self.leftLabel.hidden = YES;
            break;
        case OneInput:
            self.topLeading.constant = 31;
            self.topTrailing.constant = 10;
            self.topLabel.stringValue = @"Top / Right / Bottom / Left";
            
            self.rightTextField.hidden = YES;
            self.rightLabel.hidden = YES;
            
            self.bottomTextField.hidden = YES;
            self.bottomLabel.hidden = YES;
            
            self.leftTextField.hidden = YES;
            self.leftLabel.hidden = YES;
            break;
    }
    
}

- (IBAction)toggleEnabled:(id)sender {
    
    [self.enabledCheckbox setAllowsMixedState:FALSE];
    
    BOOL enabled = (self.enabledCheckbox.state == NSControlStateValueOn);
    [PaddyManager log:@"Toggle enabled to: %@", enabled ? @"ON" : @"OFF"];
    
    for (MSLayer *layer in self.layers) {
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
        PaddyModelPadding *currentProps = paddingLayer.paddingProperties;
        PaddyModelPadding *newProps = [PaddyModelPadding paddingFromDictionary:[currentProps dictionary]];
        newProps.enabled = enabled;
        
        [paddingLayer updatePaddingProperties:newProps andUpdateLayout:false];
    }
    
    [PaddyLayoutManager updateForLayers:self.layers withReason:ShouldIgnorePropertyChanged];
    [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
    
    [self updateViews:self.view.subviews];
}

- (void)updateViews:(NSArray*)views {
    // Update the UI based on the selected groups
    
    if (self.layers.count < 1) {
        return;
    }
    
    NSArray *paddingLayers = [PaddyUtils map:self.layers withBlock:^id(MSLayer *layer, NSUInteger idx) {
        return [PaddyPaddingLayer fromLayer:layer];
    }];
    
    PaddyPaddingLayer *paddingLayer = [paddingLayers firstObject];
    self.hasPadding = (paddingLayer.paddingProperties != nil);
    
    if (paddingLayer.paddingProperties) {
        
        NSControlStateValue state = paddingLayer.paddingProperties.enabled ? NSControlStateValueOn : NSControlStateValueOff;
        PaddyPaddingViewInputCount inputCount = paddingLayer.paddingProperties.inputCount;
        
        for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
            
            if (state != NSControlStateValueMixed) {
                NSControlStateValue newState = paddingLayer.paddingProperties.enabled ? NSControlStateValueOn : NSControlStateValueOff;
                if (state != newState) {
                    state = NSControlStateValueMixed;
                }
            }
            
            if (inputCount != AllInputs && inputCount != paddingLayer.paddingProperties.inputCount) {
                inputCount = AllInputs;
            }
        }
        
        [self.enabledCheckbox setAllowsMixedState:(state == NSControlStateValueMixed)];
        [self.enabledCheckbox setState:state];
        
        self.isChangingTextValues = true;
        
        PaddyModelPadding *props = paddingLayer.paddingProperties;
        
        NSString *topString = props.top ? [NSString stringWithFormat:@"%g", [props.top doubleValue]] : @"";
        NSString *rightString = props.right ? [NSString stringWithFormat:@"%g", [props.right doubleValue]] : @"";
        NSString *bottomString = props.bottom ? [NSString stringWithFormat:@"%g", [props.bottom doubleValue]] : @"";
        NSString *leftString = props.left ? [NSString stringWithFormat:@"%g", [props.left doubleValue]] : @"";
        
        [self.topTextField setStringValue:topString];
        [self.rightTextField setStringValue:rightString];
        [self.bottomTextField setStringValue:bottomString];
        [self.leftTextField setStringValue:leftString];
        
        self.isChangingTextValues = false;
        self.inputCount = inputCount;
        [self inputCountUpdated];
    }

    if (!self.hasPadding) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash.tiff"]];
    }
}

- (void)updatePaddingProps {
    if (self.layers.count < 1) {
        return;
    }
    
    self.isChangingTextValues = true;
    
    if (self.inputCount == TwoInputs) {
        self.leftTextField.stringValue = self.rightTextField.stringValue;
        self.bottomTextField.stringValue = self.topTextField.stringValue;
    } else if (self.inputCount == OneInput) {
        self.rightTextField.stringValue = self.topTextField.stringValue;
        self.leftTextField.stringValue = self.topTextField.stringValue;
        self.bottomTextField.stringValue = self.topTextField.stringValue;
    }
    
    NSArray *paddingValues = @[self.topTextField.stringValue, self.rightTextField.stringValue, self.bottomTextField.stringValue, self.leftTextField.stringValue];
    
    NSMutableString *paddingString = [NSMutableString string];
    for (NSString *value in paddingValues) {
        if (value.length < 1 || [value isEqualToString:@""]) {
            [paddingString appendString:@"x "];
        } else {
            [paddingString appendFormat:@"%@ ", value];
        }
    }
    
    PaddyModelPadding *props = [PaddyModelPadding paddingFromString:[paddingString substringToIndex:paddingString.length - 1]];
    props.inputCount = self.inputCount;
    
    if (props) {
        NSString *topString = props.top ? [NSString stringWithFormat:@"%g", [props.top doubleValue]] : @"";
        NSString *rightString = props.right ? [NSString stringWithFormat:@"%g", [props.right doubleValue]] : @"";
        NSString *bottomString = props.bottom ? [NSString stringWithFormat:@"%g", [props.bottom doubleValue]] : @"";
        NSString *leftString = props.left ? [NSString stringWithFormat:@"%g", [props.left doubleValue]] : @"";
        
        [self.topTextField setStringValue:topString];
        [self.rightTextField setStringValue:rightString];
        [self.bottomTextField setStringValue:bottomString];
        [self.leftTextField setStringValue:leftString];
        
        
        for (MSLayer *layer in self.layers) {
            PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
            [paddingLayer updatePaddingProperties:props  andUpdateLayout:false];
        }
        
        [PaddyLayoutManager updateForLayers:self.layers withReason:PaddingPropertiesChanged];
        [[PaddyDocumentManager currentPaddyDocument] updateSelectedLayerListPreviews];
        
    }
    
    self.isChangingTextValues = false;
}

- (NSArray*)views {
    
    [self updateViews:self.view.subviews];
    
    if (self.hasPadding) {
        return @[self.headerView, self.contentView];
    } else {
        return @[self.headerView];
    }
}

#pragma mark - Text input manipulation

- (BOOL)control:(NSControl*)control textShouldEndEditing:(NSText*)fieldEditor {
    [self updatePaddingProps];
    
    return TRUE;
}

- (IBAction)buttonClick:(id)sender {
    [PaddyManager log:@"Button click"];
}

- (void)mouseMoved:(NSEvent *)event {
    [PaddyManager log:@"Moved: %@", event];
}

@end
