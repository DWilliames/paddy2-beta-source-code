//
//  PaddyClass.m
//  PaddyFramework
//
//  Created by David Williames on 20/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyClass.h"

@implementation PaddyClass

+ (NSString*)classNameForClass:(PaddyClassType)classType {
    switch (classType) {
        case Layer:
            return @"MSLayer";
        case Group:
            return @"MSLayerGroup";
        case SymbolMaster:
            return @"MSSymbolMaster";
        case SymbolInstance:
            return @"MSSymbolInstance";
        case TextLayer:
            return @"MSTextLayer";
        case ShapePath:
            return @"MSShapePathLayer";
        case Page:
            return @"MSPage";
        case Artboard:
            return @"MSArtboardGroup";
        case Slice:
            return @"MSSliceLayer";
        case ShapeGroup:
            return @"MSShapeGroup";
    }
}

// Inherits from Class (isKindOfClass)
+ (BOOL)does:(NSObject*)object inheritFrom:(PaddyClassType)classType {
    NSString *className = [self classNameForClass:classType];
    return [self does:object inheritFromClassNamed:className];
}

+ (BOOL)does:(NSObject*)object inheritFromClassNamed:(NSString*)className {
    return [object isKindOfClass:NSClassFromString(className)];
}


// Is an instance of the class (isMemberOfClass)
+ (BOOL)is:(NSObject*)object instanceOf:(PaddyClassType)classType {
    NSString *className = [self classNameForClass:classType];
    return [self is:object instanceOfClassNamed:className];
}

+ (BOOL)is:(NSObject*)object instanceOfClassNamed:(NSString*)className {
    return [object isMemberOfClass:NSClassFromString(className)];
}

@end
