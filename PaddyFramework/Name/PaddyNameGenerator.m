//
//  PaddyNameGenerator.m
//  PaddyFramework
//
//  Created by David Williames on 12/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyNameGenerator.h"

@implementation PaddyNameGenerator

+ (void)updateNameForLayer:(MSLayer*)layer {
    layer.name = [self generateNameStringForLayer:layer];
}

+ (NSString*)generateNameStringForLayer:(MSLayer*)layer {

    PaddyNamesPreference namePreference = [PaddyPreferences getNamesPreference];
    
    NSString *name = layer.name;
    
    NSTextCheckingResult *matchedInfo = [self getInfoFromName:name];
    BOOL shouldIgnore = [PaddyData shouldLayerBeIgnored:layer];
    
    // Strip out existing matching
    if (matchedInfo && matchedInfo.numberOfRanges > 1) {
        NSRange matchRange = [matchedInfo rangeAtIndex:1];
        NSRange removeRange = NSMakeRange(matchRange.location - 1, matchRange.length + 2);
        
        name = [name stringByReplacingCharactersInRange:removeRange withString:@""];
    }
    
    // Stripped all references from the layer
    if (namePreference == StripLayerNames) {
        if (name.length > 0 && shouldIgnore && [[name substringToIndex:1] isEqualToString:@"-"]) {
            name = [name substringFromIndex:1];
        }
        
        return [self stripTrailingSpaces:name];
    } else if (namePreference == InferLayerName) {
        if (!matchedInfo || matchedInfo.numberOfRanges <= 1) {
            
            if (name.length > 0) {
                if (!shouldIgnore && [[name substringToIndex:1] isEqualToString:@"-"]) {
                    name = [name substringFromIndex:1];
                } else if (shouldIgnore && ![[name substringToIndex:1] isEqualToString:@"-"]) {
                    name = [@"-" stringByAppendingString:name];
                }
            }
            
            return [self stripTrailingSpaces:name];
        }
    }
    
    
    PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
    PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
    
    // Recreate name
    NSMutableString *newProperties = [NSMutableString string];
    
    if (stackGroup) {
        
        if (stackGroup.stackProperties) {
            NSString *orientationString = [PaddyModelOrientation shorthandStringFromOrientation:stackGroup.stackProperties.orientation];
            [newProperties appendFormat:@"%g%@", stackGroup.stackProperties.spacing, orientationString];
            
            if (stackGroup.alignments.count > 0) {
                [newProperties appendString:@" "];
            }
        }
        
        for (int i = 0; i < stackGroup.alignments.count; i++) {
            PaddyAlignment alignment = [[stackGroup.alignments objectAtIndex:i] integerValue];
            [newProperties appendString:[PaddyModelAlignment shorthandStringFromAlignment:alignment]];
            
            if (i < stackGroup.alignments.count - 1) {
                [newProperties appendString:@" "];
            }
        }
        
        if (paddingLayer && paddingLayer.paddingProperties) {
            [newProperties appendString:@";"];
            [newProperties appendString:[paddingLayer.paddingProperties propertiesString]];
        }
    } else if (paddingLayer && paddingLayer.paddingProperties) {
        [newProperties appendString:[paddingLayer.paddingProperties propertiesString]];
    }
    
    NSString *props = newProperties.length > 0 ? [NSMutableString stringWithFormat:@"[%@]", newProperties] : @"";
    
    if (matchedInfo && matchedInfo.numberOfRanges > 1) {
        NSRange matchRange = [matchedInfo rangeAtIndex:1];
        NSRange replacementRange = NSMakeRange(matchRange.location - 1, 0);
        
        name = [name stringByReplacingCharactersInRange:replacementRange withString:props];
    } else if (newProperties.length > 0) {
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", props]];
    }
    
    if (name > 0) {
        if (!shouldIgnore && [[name substringToIndex:1] isEqualToString:@"-"]) {
            name = [name substringFromIndex:1];
        } else if (shouldIgnore && ![[name substringToIndex:1] isEqualToString:@"-"]) {
            name = [@"-" stringByAppendingString:name];
        }
    }
    
    // Strip trailing space
    name = [self stripTrailingSpaces:name];
    
    return name;
}


+ (NSTextCheckingResult*)getInfoFromName:(NSString*)name {
    
    // Override values from name
    NSString *regexPattern = @".*\\[(.*?)\\]";
    
    NSError *regError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:NSRegularExpressionCaseInsensitive error:&regError];
    if (regError) {
        [PaddyManager log:@"%@", regError.localizedDescription];
    }
    
    NSArray *matches = [regex matchesInString:name options:kNilOptions range:NSMakeRange(0, name.length)];
    if (matches.count > 0) {
        return [matches firstObject];
    } else {
        return nil;
    }
}

+ (NSString*)stripTrailingSpaces:(NSString*)string {
    while (string.length > 0 && [[string substringFromIndex:string.length - 1] isEqualToString:@" "]) {
        string = [string substringToIndex:string.length - 1];
    }
    return string;
}

@end
