//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSImmutableTextLayer.h"

#import "MSColorUser.h"
#import "MSFirstLineTypesetterDelegate.h"
#import "NSLayoutManagerDelegate.h"

@class NSArray, NSAttributedString, NSObject, NSString;

@interface MSImmutableTextLayer : _MSImmutableTextLayer <MSColorUser, NSLayoutManagerDelegate, MSFirstLineTypesetterDelegate>
{
    struct CGRect _lineFragmentBounds;
    double _firstLineCapOffset;
    NSObject *_calculateBaselineOffsetsAtomicity;
    NSObject *_calculateInfluenceRectForBoundsAtomicity;
    struct CGRect _calculatedInfluenceRectForBounds;
    BOOL _didAlreadyCalculateInfluenceRect;
    BOOL _isEditingText;
    NSArray *_baselineOffsetsValue;
}

+ (unsigned long long)traitsForPropertyName:(id)arg1;
+ (id)calculateBaselineOffsets:(id)arg1 lineFragmentBounds:(struct CGRect *)arg2 firstLineCapOffset:(double *)arg3;
+ (unsigned long long)traits;
+ (id)defaultName;
@property(readonly, copy, nonatomic) NSArray *baselineOffsetsValue; // @synthesize baselineOffsetsValue=_baselineOffsetsValue;
@property(readonly, nonatomic) BOOL isEditingText; // @synthesize isEditingText=_isEditingText;
- (void).cxx_destruct;
- (double)baselineAdjustmentForLayoutManager:(id)arg1;
- (id)createTextStorage;
- (id)keysDifferingFromObject:(id)arg1;
- (BOOL)isEqualForDiffToObject:(id)arg1;
- (BOOL)hasDefaultValues;
@property(readonly, nonatomic) double firstBaselineOffset;
@property(readonly, nonatomic) double firstLineCapOffset;
@property(readonly, nonatomic) struct CGRect lineFragmentBounds;
@property(readonly, copy, nonatomic) NSArray *baselineOffsets;
- (double)lineHeight;
@property(readonly, copy, nonatomic) NSString *stringValue;
@property(readonly, copy, nonatomic) NSAttributedString *attributedStringValue;
- (double)defaultLineHeight:(id)arg1;
- (id)font;
@property(readonly, nonatomic) double fontSize;
@property(readonly, nonatomic) unsigned long long textAlignment;
- (id)usedFontNames;
- (double)startingPositionOnPath:(id)arg1;
- (id)bezierPathFromGlyphsInBoundsWithParentGroup:(id)arg1 layoutManager:(id)arg2;
- (id)firstUnderlyingShapePathWithParentGroup:(id)arg1 usingCache:(id)arg2;
- (id)shapeToUseForTextOnPathWithParentGroup:(id)arg1;
@property(readonly, nonatomic) BOOL shouldUseBezierRepresentationForRendering;
- (struct CGRect)capHeightBounds;
@property(readonly, nonatomic) struct CGPoint drawingPointForText;
- (struct CGSize)textContainerSize;
- (double)totalHeightOfFont:(id)arg1;
- (struct CGRect)calculateInfluenceRectForBounds;
- (void)performInitWithUnarchiver:(id)arg1;
- (void)performInitWithMutableModelObject:(id)arg1;
- (id)possibleOverridesInDocument:(id)arg1 actualOverrides:(id)arg2 skipping:(id)arg3;
- (void)updateColorCounter:(id)arg1;
- (void)migratePropertiesFromV80OrEarlierWithUnarchiver:(id)arg1;
- (void)migratePropertiesFromV77OrEarlierWithUnarchiver:(id)arg1;
- (void)migratePropertiesFromV76OrEarlierWithUnarchiver:(id)arg1;
- (void)migratePropertiesFromV44OrEarlierWithUnarchiver:(id)arg1;
- (void)trackColors:(id)arg1;
- (BOOL)shouldSkipDrawingInContext:(id)arg1;
- (BOOL)shouldRenderInTransparencyLayer;
- (id)textStoragePoolInCache:(id)arg1;
- (void)addDefaultFillAttributes:(id)arg1 exporter:(id)arg2;
- (id)addContentToElement:(id)arg1 attributes:(id)arg2 exporter:(id)arg3;
- (void)addPathDefinitionToDocument:(id)arg1;
- (void)addContentToTextElement:(id)arg1 exporter:(id)arg2 textStorage:(id)arg3;
- (struct CGPoint)originForCharacterAttributes:(id)arg1 exporter:(id)arg2 layoutManager:(id)arg3;
- (id)elementForSpan:(id)arg1 origin:(struct CGPoint)arg2 exporter:(id)arg3 text:(id)arg4;
- (id)spanInfoForRun:(struct _NSRange)arg1 charAttributes:(id)arg2 text:(id)arg3 layoutManager:(id)arg4;
- (void)addSVGAttributes:(id)arg1 forCharacterAttributes:(id)arg2 exporter:(id)arg3;
- (void)appendBaseTranslation:(id)arg1 exporter:(id)arg2;
- (id)svgStyle:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
