//
//  PaddySwizzle.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@interface PaddySwizzle : NSObject

+ (SEL)selectorForMethod:(NSString*)method;

+ (BOOL)replaceClassMethod:(NSString*)original withMethod:(SEL)selector onClass:(Class)newClass;
+ (void)replaceMethod:(NSString*)method onClass:(Class)newClass;

+ (void)appendMethod:(NSString*)method with:(void(^)(id, va_list))block;
+ (BOOL)appendCode:(void(^)(id, va_list))block intoMethodWithName:(NSString*)method ofClassWithName:(NSString*)className;

// Requires nil termination
+ (id)run:(NSString*)method on:(id)object with:(id)arg, ...;
+ (id)run:(NSString*)method on:(id)object;

@end
