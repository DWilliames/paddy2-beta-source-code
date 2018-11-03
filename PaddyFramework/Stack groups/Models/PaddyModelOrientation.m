//
//  PaddyModelOrientation.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyModelOrientation.h"

@implementation PaddyModelOrientation

+ (NSString*)shorthandStringFromOrientation:(PaddyOrientation)orientation {
    switch (orientation) {
        case NoOrientation:
            return @"";
        case Horizontal:
            return @"h";
        case Vertical:
            return @"v";
    }
}

+ (NSString*)stringFromOrientation:(PaddyOrientation)orientation {
    switch (orientation) {
        case NoOrientation:
            return @"None";
        case Horizontal:
            return @"Horizontal";
        case Vertical:
            return @"Vertical";
    }
}

+ (PaddyOrientation)orientationFromString:(NSString*)stringValue {
    
    NSString *string = [stringValue lowercaseString];
    
    if ([string isEqualToString:@"vertical"] || [string isEqualToString:@"v"]) {
        return Vertical;
    }
    if ([string isEqualToString:@"horizontal"] || [string isEqualToString:@"h"]) {
        return Horizontal;
    }
    
    return NoOrientation;
}

@end
