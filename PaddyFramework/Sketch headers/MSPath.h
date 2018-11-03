//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

@class NSArray;

@interface MSPath : NSObject
{
    struct CGPath *_CGPath;
    long long _signedElementCount;
    NSArray *_contours;
}

+ (id)pathWithEllipseInRect:(struct CGRect)arg1;
+ (id)pathWithRect:(struct CGRect)arg1;
+ (id)pathWithSubPaths:(id)arg1;
@property(copy, nonatomic) NSArray *contours; // @synthesize contours=_contours;
@property(nonatomic) long long signedElementCount; // @synthesize signedElementCount=_signedElementCount;
@property(readonly, nonatomic) struct CGPath *CGPath; // @synthesize CGPath=_CGPath;
- (id)pathWithInset:(double)arg1;
- (id)debugQuickLookObject;
- (id)transformedPathUsingAffineTransform:(struct CGAffineTransform)arg1;
@property(readonly, nonatomic) unsigned long long elementCount;
@property(readonly, nonatomic) BOOL isEmpty;
@property(readonly, nonatomic) struct CGRect controlPointBounds;
@property(readonly, nonatomic) struct CGRect bounds;
@property(readonly, nonatomic) struct CGRect safeBounds;
- (id)init;
- (id)initWithEllipseInRect:(struct CGRect)arg1;
- (id)initWithRect:(struct CGRect)arg1;
- (id)initWithBezierPath:(id)arg1;
- (void)dealloc;
- (id)initWithCGPath:(struct CGPath *)arg1;
- (id)booleanExclusiveOrWith:(id)arg1;
- (id)booleanSubtractWith:(id)arg1;
- (id)booleanIntersectWith:(id)arg1;
- (id)booleanUnionWith:(id)arg1;
- (id)booleanOp:(long long)arg1 withPath:(id)arg2;
- (id)outlinePathWithLineWidth:(double)arg1 borderOptions:(id)arg2 context:(struct CGContext *)arg3;
- (id)pathByGrowingBy:(double)arg1;
- (id)insetPathBy:(double)arg1 borderOptions:(id)arg2 context:(struct CGContext *)arg3;
- (id)insetPathBy:(double)arg1;
- (id)pathWithOuterPathOfSize:(double)arg1;
- (id)outerPathWithRect:(struct CGRect)arg1;
- (void)addClipForWindingRule:(unsigned long long)arg1 context:(struct CGContext *)arg2;
- (void)clipContext:(struct CGContext *)arg1 windingRule:(unsigned long long)arg2 inBlock:(id)arg3;
- (struct CGContext *)createHelperContext;

@end

