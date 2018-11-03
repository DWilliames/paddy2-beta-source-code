//
//  PaddyModelAlignment.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyAlignment) {
    NoAlignment = -1,
    Left = 0,
    Center = 1,
    Right = 2,
    Top = 3,
    Middle = 4,
    Bottom = 5
};

@interface PaddyModelAlignment : NSObject

+ (NSString*)shorthandStringFromAlignment:(PaddyAlignment)alignment;
+ (NSString*)stringFromAlignment:(PaddyAlignment)alignment;
+ (PaddyAlignment)alignmentFromString:(NSString*)string;

@end
