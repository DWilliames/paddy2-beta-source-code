//
//  PaddyStackPromptWindow.m
//  PaddyFramework
//
//  Created by David Williames on 25/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyStackPromptWindow.h"
#import "PaddyDecimalTextField.h"

@interface PaddyStackPromptWindow ()

@property (weak) IBOutlet NSImageView *image;

@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSSegmentedControl *orientationToggle;
@property (weak) IBOutlet PaddyDecimalTextField *spacingInputField;

@property (weak) IBOutlet NSSegmentedControl *createUpdateToggle;

@property (nonatomic, strong) PaddyModelStack *updateStackProperties;
@property (nonatomic, strong) PaddyModelStack *createStackProperties;

@property (nonatomic, strong) PaddyModelStack *currentStackProperties;

@property (nonatomic) BOOL creating;

@end

@implementation PaddyStackPromptWindow

- (id)init {
    return [super initWithNibName:@"PaddyStackPromptWindow"];
}


#pragma mark - Styling

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Listen for keyboard 'v' / 'h' to set orientation
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *event) {
        
        if (self.window.isVisible) {
            NSString *characters = [event charactersIgnoringModifiers];
            
            if ([characters.lowercaseString isEqualToString:@"v"]){
                [self updateOrientation:Vertical];
                return (NSEvent *)nil;
            } else if ([characters.lowercaseString isEqualToString:@"h"]){
                [self updateOrientation:Horizontal];
                return (NSEvent *)nil;
            } else if ([event keyCode] == 13) {
                [self apply:nil];
                return (NSEvent *)nil;
            } else if ([event keyCode] == 53) {
                [self cancel:nil];
                return (NSEvent *)nil;
            } else if ([event keyCode] == 48 && !self.createUpdateToggle.hidden) {
                // Tab
                if (self.creating) {
                    [self.createUpdateToggle setSelectedSegment:1];
                } else {
                    [self.createUpdateToggle setSelectedSegment:0];
                }
                
                [self changedCreateUpdate];
                return (NSEvent *)nil;
            }
        }

        return event;
    }];
    
    
    NSArray *selection = [PaddyManager selectedLayers];
    if (selection.count < 1) {
        return;
    }
    
    
    
    self.createStackProperties = [PaddyModelStack inferFromLayers:selection];
    
    
    // Check if all stack properties from the selection are equal
    NSArray *properties = [PaddyUtils map:selection withBlock:^id(MSLayer *layer, NSUInteger idx) {
        PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
        return stackGroup ? stackGroup.stackProperties : nil;
    }];
    
//    NSLog(@"All properties: %@", properties);
    
    BOOL allEqual = [PaddyUtils areAllEqual:properties];
    
    if (allEqual) {
        self.updateStackProperties = [properties firstObject];
    } else {
        self.updateStackProperties = properties.count > 0 ? [properties firstObject] : [PaddyModelStack stackOrientation:Vertical withSpacing:20];
    }
    
//    NSLog(@"\nCREATE: %@\nUPDATE: %@", self.createStackProperties, self.updateStackProperties);
    
    
    BOOL allCanHaveStacking = [PaddyUtils every:selection withBlock:^BOOL(MSLayer *layer) {
        return [PaddyStackGroup canBeStackGroup:layer];
    }];
    
    
    
    if (allCanHaveStacking) {
        [self.createUpdateToggle setSelectedSegment:1];
        self.createUpdateToggle.hidden = false;
        self.creating = false;
    } else {
        [self.createUpdateToggle setSelectedSegment:0];
        self.createUpdateToggle.hidden = true;
        self.creating = true;
    }
    
    [self changedCreateUpdate];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    NSImage *verticalImage = [bundle imageForResource:@"paddy_stack_vertical.pdf"];
    NSImage *horizontalImage = [bundle imageForResource:@"paddy_stack_horizontal.pdf"];
    verticalImage.template = true;
    horizontalImage.template = true;
    
    [self.orientationToggle setImage:verticalImage forSegment:0];
    [self.orientationToggle setImage:horizontalImage forSegment:1];
    
    self.image.image = [bundle imageForResource:@"spacing.png"];

}

- (void)updateOrientation:(PaddyOrientation)orientation {
    self.currentStackProperties.orientation = orientation;
    
    switch (orientation) {
        case Horizontal:
            [self.orientationToggle setSelectedSegment:1];
            break;
        case Vertical:
            [self.orientationToggle setSelectedSegment:0];
            break;
        default:
            break;
    }
}

- (void)changedCreateUpdate {
    
    // Update the spacing value before changing the current stack props
    if (self.currentStackProperties) {
        self.currentStackProperties.spacing = [self.spacingInputField floatValue];
    }
    
    
    self.currentStackProperties = (self.createUpdateToggle.selectedSegment == 0) ? self.createStackProperties : self.updateStackProperties;
    
    self.spacingInputField.stringValue = self.currentStackProperties ? [NSString stringWithFormat:@"%g", self.currentStackProperties.spacing] : @"";
    [self updateOrientation:self.currentStackProperties ? self.currentStackProperties.orientation : Vertical];
    
    self.creating = (self.createUpdateToggle.selectedSegment == 0);
    
//    NSLog(@"CURRENT: %@", self.currentStackProperties);
    
}

- (IBAction)toggledCreateUpdate:(id)sender {
    [self changedCreateUpdate];
}

- (IBAction)apply:(id)sender {
    
    self.currentStackProperties.spacing = [self.spacingInputField floatValue];
    
    NSArray *layers = [PaddyManager selectedLayers];
    
    if (layers.count > 0) {
        
        if (self.creating) {
            [PaddyStackGroup stackLayers:layers withProps:self.currentStackProperties creatingNewGroup:YES];
        } else {
            
            for (MSLayer *layer in layers) {
                PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
//                NSLog(@"Update %@ with %@", stackGroup, self.currentStackProperties);
                if (stackGroup) {
                    [stackGroup updateStackProperties:self.currentStackProperties];
                } else {
                    [PaddyStackGroup stackLayers:@[layer] withProps:self.currentStackProperties creatingNewGroup:NO];
                }
            }
        }
    }

    
    [self.window close];
    
}

- (IBAction)changedOrientation:(id)sender {
    if (self.orientationToggle.selectedSegment == 0) {
        self.currentStackProperties.orientation = Vertical;
    } else {
        self.currentStackProperties.orientation = Horizontal;
    }
}

- (IBAction)cancel:(id)sender {
    [self.window close];
}


@end
