//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSBezierPath.h"

@interface NSBezierPath (CHBezierPathAdditions)
+ (id)bezierCurveFromPoint:(struct CGPoint)arg1 toPoint:(struct CGPoint)arg2 controlPoint1:(struct CGPoint)arg3 controlPoint2:(struct CGPoint)arg4;
+ (id)bezierPathFromPoint:(struct CGPoint)arg1 toPoint:(struct CGPoint)arg2;
- (void)writeDebugFileNamed:(id)arg1;
- (BOOL)isClosed;
- (struct CGRect)safeBounds;
- (id)bezierPathByGrowingBy:(double)arg1;
- (void)drawInnerShadow:(id)arg1;
- (id)bezierPathWithOuterPathOfSize:(double)arg1;
- (struct CGPath *)mutableCGPathCopy;
- (struct CGPath *)createCGPath_bc;
- (id)outlinePath;
- (void)applyPropertiesToContext:(struct CGContext *)arg1;
- (void)clipInBlock:(CDUnknownBlockType)arg1;
- (void)strokeInside;
- (void)strokeOutside;
@end

