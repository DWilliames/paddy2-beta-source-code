//
//  PaddyLayoutInstance.h
//  PaddyFramework
//
//  Created by David Williames on 28/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyLayoutReason) {
    NoReason = 0,
    ChangedPosition = 1,
    ChangedSize = 2,
    ChangedOverrides = 3,
    ChangedTextValue = 4,
    ChangedName = 5,
    ChildWasDeleted = 6,
    SymbolMasterChanged = 7,
    ShouldIgnorePropertyChanged = 9,
    PaddingPropertiesChanged = 10,
    StackGroupPropertiesChanged = 11,
    LayerWasInserted = 12,
    CustomLayoutSelection = 13,
    ChangedVisibility = 14,
    AlignmentPropertiesChanged = 15,
    ChangedRotation = 16,
    AutoResizeSymbolChanged = 17
    
};



// An instance of 're-calculating' the layout for a layer

@interface PaddyLayoutInstance : NSObject

@property (nonatomic, strong, readonly) MSLayer *layer;
@property (nonatomic, strong, readonly) MSImmutableLayer *originalLayer;

@property (nonatomic, readonly) PaddyLayoutReason reason;

// For changed frame
@property (nonatomic, strong, readonly) MSAbsoluteRect *originalFrame;
@property (nonatomic, strong, readonly) MSAbsoluteRect *updatedFrame;
@property (nonatomic, strong) MSAbsoluteRect *originalParentFrame;

// For overrides
@property (nonatomic, strong, readonly) NSDictionary *originalOverrides;
@property (nonatomic, strong, readonly) NSDictionary *updatedOverrides;

// For String value
@property (nonatomic, strong, readonly) NSString *originalStringValue;
@property (nonatomic, strong, readonly) NSString *updatedStringValue;

@property (nonatomic) BOOL includeAncestors;

@property (nonatomic, readonly) NSUInteger depth;

@property (nonatomic, strong, readonly) NSArray *ancestors;


+ (PaddyLayoutInstance*)fromLayer:(MSLayer*)layer inferringReasonFromModelObject:(MSImmutableLayer*)originalLayer andFrame:(MSAbsoluteRect*)rect;
+ (PaddyLayoutInstance*)fromLayer:(MSLayer*)layer withReason:(PaddyLayoutReason)reason;

- (NSArray*)layersToUpdate;

@end
