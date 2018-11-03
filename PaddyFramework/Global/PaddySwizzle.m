//
//  PaddySwizzle.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySwizzle.h"

#import <objc/runtime.h>

@implementation PaddySwizzle

#pragma mark - Replace method implementations

+ (SEL)selectorForMethod:(NSString*)method {
    NSString *replacementName = [NSString stringWithFormat:@"%@%@", kSwizzlePrefix, method];
    return NSSelectorFromString(replacementName);
}

+ (void)replaceMethod:(NSString*)method onClass:(Class)newClass {
    NSString *originalMethod = [[method componentsSeparatedByString:@"_"] objectAtIndex:1];
    [self replaceClassMethod:method withMethod:NSSelectorFromString(originalMethod) onClass:newClass];
}

+ (BOOL)replaceClassMethod:(NSString*)original withMethod:(SEL)selector onClass:(Class)newClass {
    
    // From the string, get the original values
//    rbx = [[arg2 componentsSeparatedByString:@"_"] retain];
    NSArray *originalSignature = [original componentsSeparatedByString:@"_"];
    

//    var_58 = rbx;
//    r13 = [[rbx objectAtIndexedSubscript:0x0] retain];
    NSString *class = [originalSignature objectAtIndex:0];
    
//    rax = [rbx objectAtIndexedSubscript:0x1];
    NSString *method = [originalSignature objectAtIndex:1];
    
//    rax = [rax retain];
//    var_50 = rax;
//    r15 = NSSelectorFromString(rax);
    SEL oldSelector = NSSelectorFromString(method);
    
//    r12 = [self class];
    
//    var_48 = r13;
//    r14 = NSClassFromString(r13);
    Class oldClass = NSClassFromString(class);
//    var_38 = r14;
//    var_30 = [[NSString stringWithFormat:@"dlmidnight%@_", r13] retain];
//    NSString *replacementName = [NSString stringWithFormat:@"%@%@", kSwizzlePrefix, class];
    
//    rbx = class_getInstanceMethod(r14, r15);
    Method oldMethod = class_getInstanceMethod(oldClass, oldSelector);
    
//    r14 = class_getInstanceMethod(r12, arg3);
    Method newMethod = class_getInstanceMethod(newClass, selector);
    
//    class_addMethod(r12, r15, method_getImplementation(r14), method_getTypeEncoding(r14));
    class_addMethod(newClass, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
//    method_exchangeImplementations(rbx, r14);
    method_exchangeImplementations(oldMethod, newMethod);
    
//    rbx = [NSStringFromSelector(r15) retain];
//    NSString *originalMethodString = NSStringFromSelector(oldSelector);
//    r15 = [[var_30 stringByAppendingString:rbx] retain];
//    NSString *replacementMethodString = [replacementName stringByAppendingString:originalMethodString];
    SEL originalMethodReference = NSSelectorFromString([NSString stringWithFormat:@"%@%@", kSwizzlePrefix, method]);
//    [rbx release];
//    class_addMethod(var_38, NSSelectorFromString(r15), method_getImplementation(r14), method_getTypeEncoding(r14));
    class_addMethod(oldClass, originalMethodReference, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
//    [r15 release];

    
    
    
    
    
//    BOOL methodAdded = class_addMethod(oldClass, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
//
//    if (methodAdded) {
//        // Not sure which class :/
//        class_replaceMethod(newClass, selector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
//    } else {
//        method_exchangeImplementations(oldMethod, newMethod);
//    }
//
//    SEL originalMethodReference = NSSelectorFromString([NSString stringWithFormat:@"%@%@", kSwizzlePrefix, method]);
//    class_addMethod(oldClass, originalMethodReference, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    
//    BOOL methodAdded = class_addMethod(oldClass, oldSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//
//    [PaddyManager log:@"SWIZZLE – Adding method: %@_%@", NSStringFromClass(originalClass), NSStringFromSelector(originalSelector)];
//
//    if (methodAdded) {
//
//    } else {
//
//    }
//    method_exchangeImplementations(originalMethod, swizzledMethod);
//
//    [PaddyManager log:@"SWIZZLE – Exchanging implementations: %@_%@ and %@_%@", NSStringFromClass(originalClass), NSStringFromSelector(originalSelector), NSStringFromClass(newClass), NSStringFromSelector(selector)];
//
//    class_addMethod(originalClass, originalMethodReference, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//
//    [PaddyManager log:@"SWIZZLE – Adding method: %@_%@", NSStringFromClass(originalClass), NSStringFromSelector(originalMethodReference)];
    
    return true;
}

+ (void)appendMethod:(NSString*)method with:(void(^)(id, va_list))block {
    NSArray *components = [method componentsSeparatedByString:@"_"];
    NSString *methodName = [components objectAtIndex:1];
    NSString *className = [components objectAtIndex:0];
    [PaddySwizzle appendCode:block intoMethodWithName:methodName ofClassWithName:className];
}

+ (BOOL)appendCode:(void(^)(id, va_list))block intoMethodWithName:(NSString*)method ofClassWithName:(NSString*)className {
    
    Class class = NSClassFromString(className);
    if (!class) {
        return false;
    }
    
    SEL from = NSSelectorFromString(method);
    Method original = class_getInstanceMethod(class, from);
    if (!original) {
        return false;
    }
    
    __block IMP originalImp = NULL;
    IMP replacement = imp_implementationWithBlock(^(__unsafe_unretained id _self, va_list argp) {
        
        // Original implementation
        if(originalImp) {
            ((void(*)(id, SEL, va_list))originalImp)(_self, _cmd, argp);
        }
        
        if (PaddyManager.shared.enabled) {
            block(_self, argp);
        }
        
    });
    
    originalImp = class_replaceMethod(class, from, replacement, method_getTypeEncoding(original));
    if (!originalImp) {
        return false;
    }
    
    return true;
}


#pragma mark - Run method implementations

+ (id)run:(NSString*)method on:(id)object {
    return [self run:method on:object with:nil];
}

//    NS_REQUIRES_NIL_TERMINATION;
+ (id)run:(NSString*)method on:(id)object with:(id)arg, ... {
    NSMutableArray *arguments = [NSMutableArray array];
    
    id argument;
    va_list args;
    if (arg) {
        [arguments addObject: arg];
        va_start(args, arg);
        while ((argument = va_arg(args, id))) {
            [arguments addObject: argument];
        }
        va_end(args);
    }
    
    return [self performSelector:method onObject:object withArguments:arguments];
}

+ (id)performSelector:(NSString*)selectorString onObject:(id)object withArguments:(NSArray*)args {
    
    SEL selector = [PaddySwizzle selectorForMethod:selectorString];
    
    if ([object respondsToSelector:selector]) {
        NSMethodSignature *signature = [object methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:object];
        
        if (args) {
            for (int i = 0; i < args.count; i++) {
                id arg = [args objectAtIndex:i];
                [invocation setArgument:&arg atIndex:(i + 2)];
            }
        }
        
        [invocation invoke];
        
        if (signature.methodReturnLength > 0) {
            id __unsafe_unretained response;
            [invocation getReturnValue:&response];
            
            id returnValue = response;
            return returnValue;
        } else {
            return nil;
        }
        
        
    } else {
        [PaddyManager log:@"Issue performing selector: %@", NSStringFromSelector(selector)];
        return nil;
    }
}




@end
