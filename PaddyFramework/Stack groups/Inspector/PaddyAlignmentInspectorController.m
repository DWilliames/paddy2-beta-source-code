//
//  PaddyAlignmentInspectorController.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyAlignmentInspectorController.h"

@interface PaddyAlignmentInspectorController ()

@property (nonatomic, strong) MSDocument *document;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *horizontalAlignmentToggle;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *verticalAlignmentToggle;

@end

@implementation PaddyAlignmentInspectorController

- (id)initWithDocument:(MSDocument *)document {
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    if (!(self = [super initWithNibName:@"PaddyAlignmentInspectorController" bundle:bundle])) {
        return nil;
    }
    
    self.document = document;
    self.groups = [NSArray array];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    NSArray *horizontalImageNames = @[@"left", @"center", @"right"];
    NSArray *verticalImageNames = @[@"top", @"middle", @"bottom"];
    
    for (int i = 0; i < horizontalImageNames.count; i++) {
        NSString *imageName = [NSString stringWithFormat:@"paddy_align_%@.pdf", [horizontalImageNames objectAtIndex:i]];
        NSImage *image = [bundle imageForResource:imageName];
        image.template = true;
        
        [self.horizontalAlignmentToggle setImage:image forSegment:i];
    }
    
    for (int i = 0; i < verticalImageNames.count; i++) {
        NSString *imageName = [NSString stringWithFormat:@"paddy_align_%@.pdf", [verticalImageNames objectAtIndex:i]];
        NSImage *image = [bundle imageForResource:imageName];
        image.template = true;
        
        [self.verticalAlignmentToggle setImage:image forSegment:i];
    }
}


- (void)updateViews:(NSArray*)views {
    // Update the UI based on the selected groups
    
    [self.horizontalAlignmentToggle setSelectedSegment:-1];
    [self.verticalAlignmentToggle setSelectedSegment:-1];
    
    [self.horizontalAlignmentToggle setEnabled:TRUE];
    [self.verticalAlignmentToggle setEnabled:TRUE];
    
    if (self.groups.count < 1) {
        // Shouldn't be possible
        [self.horizontalAlignmentToggle setEnabled:FALSE];
        [self.verticalAlignmentToggle setEnabled:FALSE];
        return;
    }
    
    // If all the groups have the same alignments, show them
    // If any alignments differ in the same orientation, show no alignment
    
    NSMutableArray *alignmentArray;
    
    for (MSLayer *groupLayer in self.groups) {
        PaddyStackGroup *group = [PaddyStackGroup fromLayer:groupLayer];
        if (!group) {
            [PaddyManager log:@"GROUP DOESN'T EXIST, BUT IT SHOULD: %@", group];
            continue;
        }
        
        if (group.stackProperties) {
            switch (group.stackProperties.orientation) {
                case Vertical:
                    [self.verticalAlignmentToggle setEnabled:FALSE];
                    break;
                case Horizontal:
                    [self.horizontalAlignmentToggle setEnabled:FALSE];
                    break;
                default:
                    break;
            }
        }
        
        // Set the alignment array for the first object
        if (!alignmentArray) {
            alignmentArray = [NSMutableArray arrayWithArray:group.alignments];
        } else if (![alignmentArray isEqualToArray:group.alignments]) {
            // If future alignments don't match, then set it to be nothing
            alignmentArray = [NSMutableArray array];
        }
    }
    
    for (int i = 0; i < alignmentArray.count; i++) {
        PaddyAlignment alignment = [[alignmentArray objectAtIndex:i] integerValue];
        
        if (alignment >= 3) {
            [self.verticalAlignmentToggle setSelected:true forSegment:alignment - 3];
        } else {
            [self.horizontalAlignmentToggle setSelected:true forSegment:alignment];
        }
    }
}

- (IBAction)toggledAlignment:(id)sender {
    
    NSSegmentedControl *toggle = (NSSegmentedControl*)sender;
    if ([toggle isSelectedForSegment:toggle.selectedSegment]) {
        NSUInteger selectedSegment = toggle.selectedSegment;
        
        for (int i = 0; i < toggle.segmentCount; i++) {
            if (i != selectedSegment) {
                [toggle setSelected:false forSegment:i];
            }
        }
    }
    
    [PaddyManager log:@"Toggled: %li – %@", (long)toggle.selectedSegment, [toggle isSelectedForSegment:toggle.selectedSegment] ? @"ON" : @"OFF"];
    
    NSMutableArray *newAlignments = [NSMutableArray array];
    
    for (int i = 0; i < self.horizontalAlignmentToggle.segmentCount; i++) {
        if ([self.horizontalAlignmentToggle isSelectedForSegment:i]) {
            [newAlignments addObject:@(i)];
        }
    }
    
    for (int i = 0; i < self.verticalAlignmentToggle.segmentCount; i++) {
        if ([self.verticalAlignmentToggle isSelectedForSegment:i]) {
            [newAlignments addObject:@(i + 3)];
        }
    }
    
    [PaddyManager log:@"New alignments: %@", newAlignments];
    
    for (MSLayer *groupLayer in self.groups) {
        PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:groupLayer];
        if (stackGroup) {
            [stackGroup updateAlignments:newAlignments];
        }
    }
    
//    if (self.groups.count == 1) {
//        PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:self.groups.firstObject];
//        if (stackGroup) {
//            [stackGroup updateAlignments:newAlignments];
//        }
//    }
}

- (NSArray*)views {
    [self updateViews:@[self.view]];
    
    return @[self.view];
}
@end
