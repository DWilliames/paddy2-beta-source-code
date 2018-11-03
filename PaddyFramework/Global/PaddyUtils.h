//
//  PaddyUtils.h
//  PaddyFramework
//
//  Created by David Williames on 28/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyUtils : NSObject

+ (NSMutableArray*)map:(NSArray*)array withBlock:(id (^)(id obj, NSUInteger idx))block;
+ (NSMutableArray*)filter:(NSArray*)array withBlock:(BOOL (^)(id obj))block;
+ (id)find:(NSArray*)array withBlock:(BOOL (^)(id obj))block;
+ (BOOL)every:(NSArray*)array withBlock:(BOOL (^)(id obj))block;

+ (BOOL)areAllEqual:(NSArray*)array;

@end
