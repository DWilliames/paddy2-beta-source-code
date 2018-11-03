//
//  PaddyClass.h
//  PaddyFramework
//
//  Created by David Williames on 20/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyClassType) {
    Layer = 0, // MSLayer
    Group = 1, // MSLayerGroup
    SymbolMaster = 2, // MSSymbolMaster
    SymbolInstance = 3, // MSSymbolInstanc
    TextLayer = 4, // MSTextLayer
    ShapePath = 5, // MSShapePathLayer
    Page = 6, // MSPage
    Artboard = 7, // MSArtboardGroup
    Slice = 8, // MSSliceLayer
    ShapeGroup = 9, // MSShapeGroup
};

@interface PaddyClass : NSObject

// Inherits from (isKindOfClass)
+ (BOOL)does:(NSObject*)object inheritFrom:(PaddyClassType)classType;
+ (BOOL)does:(NSObject*)object inheritFromClassNamed:(NSString*)className;

// Is an instance of the class (isMemberOfClass)
+ (BOOL)is:(NSObject*)object instanceOf:(PaddyClassType)classType;
+ (BOOL)is:(NSObject*)object instanceOfClassNamed:(NSString*)className;

@end
