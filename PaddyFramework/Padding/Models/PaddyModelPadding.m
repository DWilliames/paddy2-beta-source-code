//
//  PaddyModelPadding.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#define kTopPaddingKey @"Top"
#define kRightPaddingKey @"Right"
#define kBottomPaddingKey @"Bottom"
#define kLeftPaddingKey @"Left"

#define kPaddingIsEnabledKey @"Enabled"

#define kPaddingInputCountKey @"InputCount"


#import "PaddyModelPadding.h"
#import "PaddyPaddingLayer.h"
#import "PaddyPaddingManager.h"

@interface PaddyModelPadding()

@property (nonatomic) NSNumber *top;
@property (nonatomic) NSNumber *right;
@property (nonatomic) NSNumber *bottom;
@property (nonatomic) NSNumber *left;

@end

@implementation PaddyModelPadding

+ (id)defaultModel {
    return [PaddyModelPadding paddingFromString:@"10 20"];
}

+ (id)inferFromLayer:(MSLayer*)backgroundLayer {
    
    MSLayerGroup *parent = [backgroundLayer parentGroup];
    NSArray *layers = parent ? [parent layers] : @[backgroundLayer];
    
    // Container rect for everything that isn't a Padding layer
    MSRect *containerRect = [PaddyLayerUtils boundingRectForLayers:layers withFilter:^BOOL(MSLayer *layer) {
        if ([layer isEqual:backgroundLayer] || [PaddyPaddingLayer shouldLayerBeIgnored:layer]) {
            return false;
        }
        
        // Ignore layers already with padding
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
        if (paddingLayer && paddingLayer.paddingProperties) {
            return false;
        }
        
        return true;
    }];
    
    
    if (!containerRect || (parent && [PaddyClass is:parent instanceOf:Page] && ((MSPage*)parent).cachedArtboards.count > 0)) {
        return [self defaultModel];
    }
    
    MSRect *frame = backgroundLayer.frame;
    
    float top = containerRect.top - frame.top;
    float right = (frame.width + frame.x) - (containerRect.width + containerRect.x);
    float bottom = (frame.height + frame.y) - (containerRect.height + containerRect.y);
    float left = containerRect.left - frame.left;
    
    PaddyPaddingViewInputCount inputCount = AllInputs;
    
    if (top == bottom && left == right) {
        if (top == left) {
            inputCount = OneInput;
        } else {
            inputCount = TwoInputs;
        }
    }
    
    [PaddyManager log:@"Infer padding from: %@ – container: %@", frame, containerRect];
    [PaddyManager log:@"%g %g %g %g", top, right, bottom, left];
    
    return [[PaddyModelPadding alloc] initWithTop:@(top) right:@(right) bottom:@(bottom) andLeft:@(left) inputCount:inputCount];
}

+ (id)paddingFromString:(NSString*)string {
    
    if (!string || string.length < 1) {
        return nil;
    }
    
    NSArray *splitValues = [string componentsSeparatedByString:@" "];
    
//    double top = 10, bottom = 10, left = 20, right = 20;
    
    NSString *top, *bottom, *left, *right;
    PaddyPaddingViewInputCount inputCount = AllInputs;
    
    switch (splitValues.count) {
        case 1:
            top = bottom = left = right = splitValues[0];
            inputCount = OneInput;
            break;
        case 2:
            top = bottom = splitValues[0];
            left = right = splitValues[1];
            inputCount = TwoInputs;
            break;
        case 3:
            top = splitValues[0];
            left = right = splitValues[1];
            bottom = splitValues[2];
            inputCount = AllInputs;
            break;
        case 4:
            top = splitValues[0];
            right = splitValues[1];
            bottom = splitValues[2];
            left = splitValues[3];
            inputCount = AllInputs;
            break;
        default:
            return nil;
            break;
    }

    NSNumber *topValue = ([top isEqualToString:@"x"] || top.length < 1) ? nil : @([top doubleValue]);
    NSNumber *rightValue = ([right isEqualToString:@"x"] || right.length < 1) ? nil : @([right doubleValue]);
    NSNumber *bottomValue = ([bottom isEqualToString:@"x"] || bottom.length < 1) ? nil : @([bottom doubleValue]);
    NSNumber *leftValue = ([left isEqualToString:@"x"] || left.length < 1) ? nil : @([left doubleValue]);

    return [[PaddyModelPadding alloc] initWithTop:topValue right:rightValue bottom:bottomValue andLeft:leftValue inputCount:inputCount];
}

+ (id)paddingFromDictionary:(NSDictionary*)dictionary {
    if (!dictionary) {
        return nil;
    }
    
    NSNumber *top = [dictionary objectForKey:kTopPaddingKey];
    NSNumber *right = [dictionary objectForKey:kRightPaddingKey];
    NSNumber *bottom = [dictionary objectForKey:kBottomPaddingKey];
    NSNumber *left = [dictionary objectForKey:kLeftPaddingKey];
    
    NSNumber *enabledObject = [dictionary objectForKey:kPaddingIsEnabledKey];
    BOOL enabled = enabledObject ? [enabledObject boolValue] : true;
    
    NSNumber *inputCountObject = [dictionary objectForKey:kPaddingInputCountKey];
    PaddyPaddingViewInputCount inputCount = inputCountObject ? [inputCountObject integerValue] : AllInputs;
    
    PaddyModelPadding *model = [[PaddyModelPadding alloc] initWithTop:top right:right bottom:bottom andLeft:left inputCount:inputCount];
    model.enabled = enabled;

    return model;
}

- (id)initWithTop:(NSNumber*)top right:(NSNumber*)right bottom:(NSNumber*)bottom andLeft:(NSNumber*)left inputCount:(PaddyPaddingViewInputCount)inputCount {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.top = top;
    self.right = right;
    self.bottom = bottom;
    self.left = left;
    
    self.enabled = true;
    
    self.inputCount = inputCount;
    
    return self;
}

- (NSString*)description {
    
    NSString *input;
    switch (self.inputCount) {
        case AllInputs:
            input = @"All inputs";
            break;
        case TwoInputs:
            input = @"Two inputs";
            break;
        case OneInput:
            input = @"One input";
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@ %@ – %@ (%@)", self.top, self.right, self.bottom, self.left, (self.enabled ? @"Enabled" : @"Disabled"), input];
}

- (NSString*)propertiesString {
    
    NSString *top = self.top ? [NSString stringWithFormat:@"%g", [self.top doubleValue]] : @"x";
    NSString *right = self.right ? [NSString stringWithFormat:@"%g", [self.right doubleValue]] : @"x";
    NSString *bottom = self.bottom ? [NSString stringWithFormat:@"%g", [self.bottom doubleValue]] : @"x";
    NSString *left = self.left ? [NSString stringWithFormat:@"%g", [self.left doubleValue]] : @"x";
    
    switch (self.inputCount) {
        case AllInputs:
            return [NSString stringWithFormat:@"%@ %@ %@ %@", top, right, bottom, left];
        case TwoInputs:
            return [NSString stringWithFormat:@"%@ %@", top, right];
        case OneInput:
            return [NSString stringWithFormat:@"%@", top];
    }
}

- (NSDictionary*)dictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[kTopPaddingKey] = self.top;
    dictionary[kRightPaddingKey] = self.right;
    dictionary[kBottomPaddingKey] = self.bottom;
    dictionary[kLeftPaddingKey] = self.left;
    
    [dictionary setObject:@(self.enabled) forKey:kPaddingIsEnabledKey];
    [dictionary setObject:@(self.inputCount) forKey:kPaddingInputCountKey];
    
    return dictionary;
}

- (BOOL)isEqual:(id)object {
    
    if (!object) {
        return false;
    }
    
    if ([object isKindOfClass:[self class]]) {
        PaddyModelPadding *model = (PaddyModelPadding*)object;
        
        if (self.enabled != model.enabled) {
            return false;
        }
        
        if (self.top && model.top && ![self.top isEqualToNumber:model.top]) {
            return false;
        }
        
        if (self.right && model.right && ![self.right isEqualToNumber:model.right]) {
            return false;
        }
        
        if (self.bottom && model.bottom && ![self.bottom isEqualToNumber:model.bottom]) {
            return false;
        }
        
        if (self.left && model.left && ![self.left isEqualToNumber:model.left]) {
            return false;
        }
        
        return true;
    }
    return false;
}

@end
