//
//  PaddyModelAlignment.m
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyModelAlignment.h"

@implementation PaddyModelAlignment

+ (NSString*)shorthandStringFromAlignment:(PaddyAlignment)alignment {
    switch (alignment) {
        case NoAlignment:
            return @"";
        case Left:
            return @"l";
        case Right:
            return @"r";
        case Top:
            return @"t";
        case Bottom:
            return @"b";
        case Middle:
            return @"m";
        case Center:
            return @"c";
    }
}


+ (NSString*)stringFromAlignment:(PaddyAlignment)alignment {
    switch (alignment) {
        case NoAlignment:
            return @"None";
        case Left:
            return @"Left";
        case Right:
            return @"Right";
        case Top:
            return @"Top";
        case Bottom:
            return @"Bottom";
        case Middle:
            return @"Middle";
        case Center:
            return @"Center";
    }
}

+ (PaddyAlignment)alignmentFromString:(NSString*)string {
    
    NSString *alignment = [string lowercaseString];
    
    if ([alignment isEqualToString:@"left"] || [alignment isEqualToString:@"l"]) {
        return Left;
    }
    if ([alignment isEqualToString:@"right"] || [alignment isEqualToString:@"r"]) {
        return Right;
    }
    if ([alignment isEqualToString:@"top"] || [alignment isEqualToString:@"t"]) {
        return Top;
    }
    if ([alignment isEqualToString:@"bottom"] || [alignment isEqualToString:@"b"]) {
        return Bottom;
    }
    if ([alignment isEqualToString:@"center"] || [alignment isEqualToString:@"centre"] || [alignment isEqualToString:@"h"] || [alignment isEqualToString:@"horizontally"] || [alignment isEqualToString:@"c"]) {
        return Center;
    }
    if ([alignment isEqualToString:@"middle"] || [alignment isEqualToString:@"v"] || [alignment isEqualToString:@"vertically"] || [alignment isEqualToString:@"m"]) {
        return Middle;
    }
    return NoAlignment;
}

@end
