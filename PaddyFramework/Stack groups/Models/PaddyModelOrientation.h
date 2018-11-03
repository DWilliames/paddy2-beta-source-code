//
//  PaddyModelOrientation.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyOrientation) {
    NoOrientation = 0,
    Vertical = 1,
    Horizontal = 2
};

@interface PaddyModelOrientation : NSObject

+ (NSString*)stringFromOrientation:(PaddyOrientation)orientation;
+ (NSString*)shorthandStringFromOrientation:(PaddyOrientation)orientation;
+ (PaddyOrientation)orientationFromString:(NSString*)string;

@end
