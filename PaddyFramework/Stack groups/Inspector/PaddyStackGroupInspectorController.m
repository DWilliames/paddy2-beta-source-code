//
//  PaddyStackGroupInspectorController.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyStackGroupInspectorController.h"
#import "PaddyStackGroupHeaderInspectorView.h"

@interface PaddyStackGroupInspectorController ()

@property (nonatomic, strong) MSDocument *document;

@property (nonatomic, strong) IBOutlet NSImageView *accessoryButton;
@property (nonatomic, strong, retain) IBOutlet PaddyStackGroupHeaderInspectorView *headerView;
@property (nonatomic, strong, retain) IBOutlet NSView *contentView;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *orientationToggle;
@property (nonatomic, strong) IBOutlet MSUpDownTextField *spacingTextField;
@property (strong) IBOutlet NSButton *collapseViews;
@property (strong) IBOutlet NSTextField *headerTitle;

@property (nonatomic) BOOL isStacked;
@property (nonatomic) BOOL isChangingStringValues;

@end

@implementation PaddyStackGroupInspectorController

- (id)initWithDocument:(MSDocument *)document {
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    if (!(self = [super initWithNibName:@"PaddyStackGroupInspectorController" bundle:bundle])) {
        return nil;
    }
    
    self.document = document;
    self.layers = [NSArray array];
    
    self.isStacked = true;
    self.isChangingStringValues = false;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spacingTextField.delegate = self;
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.headerView.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self.headerView addTrackingArea:trackingArea];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headerView.controller = self;
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    NSImage *verticalImage = [bundle imageForResource:@"paddy_stack_vertical.pdf"];
    NSImage *horizontalImage = [bundle imageForResource:@"paddy_stack_horizontal.pdf"];
    verticalImage.template = true;
    horizontalImage.template = true;
    
    [self.orientationToggle setImage:verticalImage forSegment:0];
    [self.orientationToggle setImage:horizontalImage forSegment:1];
    
    [PaddyObserver observeKeyPath:@"stringValue" ofObject:self.spacingTextField withCallback:^(id oldValue, id newValue) {
        [PaddyManager log:@"Spacing text change from %@ to: %@", oldValue, newValue];
        if (self.isChangingStringValues) {
            [PaddyManager log:@"Is currently setting the text value, so won't do anything"];
        } else if (self.layers.count == 1 && oldValue != newValue) {
            PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:self.layers.firstObject];
            if (stackGroup) {
                PaddyModelStack *currentProps = stackGroup.stackProperties;
                PaddyModelStack *newProps = [PaddyModelStack stackOrientation:currentProps.orientation withSpacing:[newValue doubleValue] andCollapsing:currentProps.collapsing];
                
                [stackGroup updateStackProperties:newProps];
            }
        }
    }];
}

- (void)dealloc {
    [PaddyObserver removeObserversOfObject:self.spacingTextField];
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    
    if (self.isStacked) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash_hover.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add_hover.tiff"]];
    }
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    
    if (self.isStacked) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add.tiff"]];
    }
}

- (void)headerMouseDown {
    
    if (self.isStacked) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash_pressed.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add_pressed.tiff"]];
    }
}

- (void)headerMouseUp {
    [PaddyManager log:@"MOUSE UP: %@", self.layers];
    
    PaddyStackGroup *newStackGroup = [PaddyStackGroup stackLayers:self.layers withProps:nil creatingNewGroup:TRUE];
    
    if (!newStackGroup) {
        return;
    }
    
    
    if (self.isStacked) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash_hover.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add_hover.tiff"]];
    }
    
    MSInspectorController *inspectorController = [self.document inspectorController];
    MSNormalInspector *normalInspector = [inspectorController normalInspector];
    MSInspectorStackView *stackView = [normalInspector stackView];

    [stackView reloadSubviews];
}

- (IBAction)toggledOrientation:(id)sender {
    
    NSUInteger selectedOrientation = self.orientationToggle.selectedSegment;
    PaddyOrientation orientation = (selectedOrientation + 1);
    
    if (self.layers.count == 1) {
        PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:self.layers.firstObject];
        if (stackGroup) {
            PaddyModelStack *currentProps = stackGroup.stackProperties;
            
            PaddyModelStack *newProps = [PaddyModelStack stackOrientation:orientation withSpacing:currentProps.spacing andCollapsing:currentProps.collapsing];
            
            [stackGroup updateStackProperties:newProps];
        }
    }
    
}

- (IBAction)toggledCollapseViews:(id)sender {
    
    if (self.layers.count == 1) {
        PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:self.layers.firstObject];
        if (stackGroup) {
            
            BOOL collapsing = (self.collapseViews.state == NSControlStateValueOn);
            
            PaddyModelStack *currentProps = stackGroup.stackProperties;
            PaddyModelStack *newProps = [PaddyModelStack stackOrientation:currentProps.orientation withSpacing:currentProps.spacing andCollapsing:collapsing];
            
            [stackGroup updateStackProperties:newProps];
        }
        
    }
}

- (void)updateViews:(NSArray*)views {
    // Update the UI based on the selected groups
    
    self.isStacked = false;
    
    if (self.layers.count == 1) {
        PaddyStackGroup *group = [PaddyStackGroup fromLayer:[self.layers firstObject]];
        
        if (group && group.stackProperties) {
            self.isStacked = true;
            
            [self.orientationToggle setSelectedSegment:(group.stackProperties.orientation - 1)];
            
            self.isChangingStringValues = true;
            
            NSString *spacingValue = [NSString stringWithFormat:@"%g", group.stackProperties.spacing];
            [self.spacingTextField setStringValue:spacingValue];
            
            self.isChangingStringValues = false;
            
            [self.collapseViews setState:(group.stackProperties.collapsing ? NSControlStateValueOn : NSControlStateValueOff)];
        }
    }
    
    if (self.isStacked) {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_trash.tiff"]];
    } else {
        [self.accessoryButton setImage:[NSImage imageNamed:@"inspector_add.tiff"]];
    }
}

- (NSArray*)views {
    
    [self updateViews:self.view.subviews];
    
    if (self.isStacked) {
        return @[self.headerView, self.contentView];
    } else {
        return @[self.headerView];
    }
}

#pragma mark - Text input manipulation

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    
    self.isChangingStringValues = true;
    
    // Trim out any non-number characters
    NSString *newValue = [NSString stringWithFormat:@"%g", self.spacingTextField.floatValue];
    [self.spacingTextField setStringValue:newValue];
    [PaddyManager log:@"Spacing text did end: %@", newValue];
    
    self.isChangingStringValues = false;
    
    PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:self.layers.firstObject];
    if (stackGroup) {
        PaddyModelStack *currentProps = stackGroup.stackProperties;
        PaddyModelStack *newProps = [PaddyModelStack stackOrientation:currentProps.orientation withSpacing:[newValue doubleValue] andCollapsing:currentProps.collapsing];
        
        [stackGroup updateStackProperties:newProps];
    }
    
    return TRUE;
}


@end
