//
//  PaddyLayoutInstance.m
//  PaddyFramework
//
//  Created by David Williames on 28/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayoutInstance.h"

@interface PaddyLayoutInstance ()

@property (nonatomic, strong) MSLayer *layer;
@property (nonatomic, strong) MSImmutableLayer *originalLayer;

@property (nonatomic) PaddyLayoutReason reason;

// For changed frame
@property (nonatomic, strong) MSAbsoluteRect *originalFrame;
@property (nonatomic, strong) MSAbsoluteRect *updatedFrame;

// For overrides
@property (nonatomic, strong) NSDictionary *originalOverrides;
@property (nonatomic, strong) NSDictionary *updatedOverrides;

// For String value
@property (nonatomic, strong) NSString *originalStringValue;
@property (nonatomic, strong) NSString *updatedStringValue;

@property (nonatomic) NSUInteger depth;

@property (nonatomic, strong) NSArray *ancestors;

@end

@implementation PaddyLayoutInstance

+ (PaddyLayoutInstance*)fromLayer:(MSLayer*)layer withReason:(PaddyLayoutReason)reason {
    return [[PaddyLayoutInstance alloc] initWithLayer:layer andReason:reason];
}

+ (PaddyLayoutInstance*)fromLayer:(MSLayer*)layer inferringReasonFromModelObject:(MSImmutableLayer*)originalLayer andFrame:(MSAbsoluteRect*)rect {
    return [[PaddyLayoutInstance alloc] initWithLayer:layer andModelObject:originalLayer andFrame:rect];
}

- (instancetype)initWithLayer:(MSLayer*)layer andReason:(PaddyLayoutReason)reason {
    if (!layer || reason == NoReason) {
        return nil;
    }
    
    if (!(self = [super init])) {
        return nil;
    }
    
    self.layer = layer;
    self.reason = reason;
    
    self.includeAncestors = TRUE;
    
    self.ancestors = [self.layer ancestors];
    self.depth = [self.ancestors count];
    
    return self;
}

- (instancetype)initWithLayer:(MSLayer*)layer andModelObject:(MSImmutableLayer*)originalLayer andFrame:(MSAbsoluteRect*)rect {
    if (!originalLayer || !layer) {
        return nil;
    }
    
    if (!(self = [super init])) {
        return nil;
    }
    
    
    // Let's see how they changed
    PaddyLayoutReason reason = NoReason;
    
    if (reason == NoReason && [PaddyClass is:layer instanceOf:SymbolInstance]) {
        MSSymbolInstance *originalInstance = [self.originalLayer newMutableCounterpart];
        MSSymbolInstance *instance = (MSSymbolInstance*)self.layer;
        
        if (instance.overrides && ![instance.overrides isEqualToDictionary:originalInstance.overrides]) {
            reason = ChangedOverrides;
            
            [PaddyManager log:@"Changed overrides \nFrom: %@ \nTo: %@", originalInstance.overrides, instance.overrides];
            
            self.originalOverrides = originalInstance.overrides;
            self.updatedOverrides = instance.overrides;
        }
    }
    
    if (reason == NoReason && [PaddyClass is:layer instanceOf:TextLayer]) {
        MSTextLayer *originalTextLayer = [self.originalLayer newMutableCounterpart];
        MSTextLayer *textLayer = (MSTextLayer*)self.layer;
        
        if (![originalTextLayer.stringValue isEqualToString:textLayer.stringValue]) {
            reason = ChangedTextValue;
            
            self.originalStringValue = originalTextLayer.stringValue;
            self.updatedStringValue = textLayer.stringValue;
        }
    }
    
    if (reason == NoReason && ![layer.name isEqualToString:originalLayer.name]) {
        reason = ChangedName;
    }
    

    MSAbsoluteRect *originalFrame = rect;
    MSAbsoluteRect *frame = [layer absoluteRect];
    
    if (reason == NoReason && (originalFrame.width != frame.width || originalFrame.height != frame.height)) {
        // RESIZED
        reason = ChangedSize;
    }
    
    if (reason == NoReason && (frame.x != originalFrame.x || frame.y != originalFrame.y)) {
        // MOVED
        reason = ChangedPosition;
    }
    
    
//    if (reason == NoReason && layer.rotation != originalLayer.rotation) {
//        // ROTATED
//        reason = ChangedRotation;
//    }
    
    
    if (reason == NoReason) {
        return nil;
    }
    
    self.originalLayer = originalLayer;
    self.layer = layer;
    
    self.originalFrame = originalFrame;
    self.updatedFrame = frame;
    
    self.reason = reason;
    self.includeAncestors = TRUE;
    
    return self;
}

- (NSArray*)layersToUpdate {
    
    MSLayer *layer = self.layer;
    NSMutableArray *layers = [NSMutableArray arrayWithArray:[layer ancestors]];
    if (!self.includeAncestors) {
        MSLayerGroup *parent = [layer parentGroup];
        layers = parent ? [NSMutableArray arrayWithObject:parent] : [NSMutableArray array];
    }
    
    switch (self.reason) {
        case ChangedSize:
        case AutoResizeSymbolChanged:
//            if ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:SymbolInstance]) {
//                [layers addObject:layer];
//            }
            
            if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
                [layers addObject:layer];
            }
            break;
        case ChangedName:
            if ([PaddyClass is:layer instanceOf:Group]) {
                [layers addObject:layer];
            }
        case ChangedOverrides:
        case ChildWasDeleted:
        case SymbolMasterChanged:
        case StackGroupPropertiesChanged:
        case AlignmentPropertiesChanged:
        case CustomLayoutSelection:
            if ([PaddyClass is:layer instanceOf:Group] || [PaddyClass is:layer instanceOf:SymbolInstance] || [PaddyClass is:layer instanceOf:SymbolMaster] || [PaddyClass is:layer instanceOf:Artboard]) {
                [layers addObject:layer];
            }
            break;
        default:
            break;
    }
    
    return layers;
}

- (NSString*)descriptionForReason:(PaddyLayoutReason)reason {
    switch (reason) {
        case NoReason:
            return @"None";
        case ChangedPosition:
            return @"Changed position";
        case ChangedSize:
            return @"Changed size";
        case ChangedOverrides:
            return @"Changed overrides";
        case ChangedTextValue:
            return @"Changed Text value";
        case ChangedName:
            return @"Changed name";
        case ChildWasDeleted:
            return @"Child was deleted";
        case SymbolMasterChanged:
            return @"Symbol Master Changed";
        case ShouldIgnorePropertyChanged:
            return @"Should ignore property changed";
        case PaddingPropertiesChanged:
            return @"Padding properties changed";
        case StackGroupPropertiesChanged:
            return @"Stack group properties changed";
        case LayerWasInserted:
            return @"Layer was inserted";
        case CustomLayoutSelection:
            return @"Custom layout selection";
        case ChangedVisibility:
            return @"Changed visibility";
        case AlignmentPropertiesChanged:
            return @"Alignment properties changed";
        case ChangedRotation:
            return @"Changed rotation";
        case AutoResizeSymbolChanged:
            return @"Auto resize symbol proprety changed";
    }
}

- (NSString*)description {
    
    return [NSString stringWithFormat:@"%@ (%@) - %@", self.layer.name, self.layer.className, [self descriptionForReason:self.reason]];
    
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[PaddyLayoutInstance class]]) {
        PaddyLayoutInstance *instance = (PaddyLayoutInstance*)object;
        return ([instance.layer isEqual:self.layer] && instance.reason == self.reason);
    }
    return false;
}

- (NSUInteger)hash {
    return (self.layer.hash * 100 + self.reason);
}

@end
