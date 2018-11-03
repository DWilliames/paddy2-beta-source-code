//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSTextLayer.h"
#import "MSFirstLineTypesetterDelegate-Protocol.h"

@class MSColor, NSArray, NSAttributedString, NSBezierPath, NSDictionary, NSNumber, NSString;

@interface MSTextLayer : _MSTextLayer <MSFirstLineTypesetterDelegate>
{
    int ignoreDelegateNotificationsCounter;
    BOOL _isEditingText;
    id  _editingDelegate;
    NSNumber *_defaultLineHeightValue;
    NSArray *_baselineOffsetsValue;
    struct CGRect _previousRectCache;
}

+ (long long)menuItemStateForAlignment:(unsigned long long)arg1 forLayers:(id)arg2;
+ (void)setTextAlignment:(unsigned long long)arg1 forLayers:(id)arg2;
+ (BOOL)canSetTextAlignmentForLayers:(id)arg1;
+ (long long)menuItemStateForTextVerticalAlignment:(long long)arg1 forLayers:(id)arg2;
+ (void)setTextVerticalAlignment:(long long)arg1 forLayers:(id)arg2;
+ (BOOL)canSetTextVerticalAlignmentForLayers:(id)arg1;
+ (id)keyPathsForValuesAffectingHasFixedHeight;
+ (id)keyPathsForValuesAffectingCanFixHeight;
@property(copy, nonatomic) NSArray *baselineOffsetsValue; // @synthesize baselineOffsetsValue=_baselineOffsetsValue;
@property(retain, nonatomic) NSNumber *defaultLineHeightValue; // @synthesize defaultLineHeightValue=_defaultLineHeightValue;
@property(nonatomic) __weak id editingDelegate; // @synthesize editingDelegate=_editingDelegate;
@property(nonatomic) BOOL isEditingText; // @synthesize isEditingText=_isEditingText;
@property(nonatomic) struct CGRect previousRectCache; // @synthesize previousRectCache=_previousRectCache;
- (BOOL)canScale;
- (BOOL)canBeTransformed;
- (BOOL)constrainProportions;
- (void)checkTextBehaviourAndClippingAfterResizeFromCorner:(long long)arg1 mayClip:(BOOL)arg2;
- (void)resizeWithOldGroupSize:(struct CGSize)arg1;
- (void)layerDidResizeFromRect:(struct CGRect)arg1 corner:(long long)arg2;
- (void)replaceTextPreservingAttributeRanges:(id)arg1;
- (void)setTextTransform:(unsigned long long)arg1 range:(struct _NSRange)arg2;
- (void)makeLowercase:(id)arg1;
- (void)makeUppercase:(id)arg1;
- (void)multiplyBy:(double)arg1;
- (id)attributeForKey:(id)arg1;
- (void)addAttribute:(id)arg1 value:(id)arg2;
- (void)addAttributes:(id)arg1 forRange:(struct _NSRange)arg2;
- (void)setAttributes:(id)arg1 forRange:(struct _NSRange)arg2;
- (void)addAttribute:(id)arg1 value:(id)arg2 forRange:(struct _NSRange)arg3;
@property(copy, nonatomic) NSString *stringValue;
- (void)setAttributedString:(id)arg1;
@property(copy, nonatomic) NSAttributedString *attributedStringValue;
- (void)layerStyleDidChange;
- (BOOL)isEmpty;
@property(copy, nonatomic) NSDictionary *styleAttributes;
@property(copy, nonatomic) MSColor *textColor;
@property(nonatomic) double lineHeight;
- (double)baseLineHeight;
@property(retain, nonatomic) NSNumber *characterSpacing;
@property(retain, nonatomic) NSString *fontPostscriptName;
- (void)setFont:(id)arg1;
@property(nonatomic) double fontSize;
@property(nonatomic) long long verticalAlignment;
@property(nonatomic) unsigned long long textAlignment;
- (void)setLeading:(double)arg1;
- (double)leading;
- (id)paragraphStyle;
- (void)setKerning:(float)arg1;
- (float)kerning;
- (void)refreshOverlay;
- (id)bezierPathFromGlyphsInBounds;
- (id)bezierPathFromGlyphsInFrame;
@property(readonly, nonatomic) NSBezierPath *bezierPath;
- (struct CGPoint)drawingPointForText;
- (id)bezierPathWithTransforms;
- (double)startingPositionOnPath:(id)arg1;
- (double)defaultLineHeight:(id)arg1;
- (id)font;
- (void)changeFont:(id)arg1;
- (unsigned long long)selectionCornerMaskWithZoomValue:(double)arg1;
- (id)shapeToUseForTextOnPath;
- (void)updateNameFromStorage;
- (void)changeListType:(id)arg1;
- (void)setRectAccountingForClipped:(struct CGRect)arg1;
- (void)adjustFrameToFit;
- (void)finishEditing;
- (double)baselineAdjustmentForLayoutManager:(id)arg1;
- (void)replaceMissingFontsIfNecessary;
- (BOOL)compareAttributes:(id)arg1 withAttributes:(id)arg2;
- (void)syncTextStyleAttributes;
- (id)sharedObject;
- (id)baselineOffsets;
- (double)firstBaselineOffset;
- (void)setupBehaviour:(BOOL)arg1;
- (void)setTextBehaviour:(long long)arg1;
- (void)setTextBehaviour:(long long)arg1 mayAdjustFrame:(BOOL)arg2;
- (void)setStyle:(id)arg1;
- (void)object:(id)arg1 didChangeProperty:(id)arg2;
- (void)performInitWithImmutableModelObject:(id)arg1;
- (void)performInitEmptyObject;
- (void)objectDidInit;
- (id)initWithFrame:(struct CGRect)arg1 attributes:(id)arg2 type:(long long)arg3;
- (id)initWithAttributedString:(id)arg1 maxWidth:(double)arg2;
- (id)initWithFrame:(struct CGRect)arg1;
- (id)PDFPreview;
- (BOOL)shouldStorePDFPreviews;
- (struct CGRect)layerPositionDrawingRectWithModifierFlags:(unsigned long long)arg1;
- (long long)cornerRectType;
- (Class)overrideViewControllerClass;
- (BOOL)shouldDrawSelection;
- (id)handlerName;
- (void)layerDidResizeFromInspector:(unsigned long long)arg1;
- (id)inspectorViewControllerNames;
- (void)drawHoverWithZoom:(double)arg1 cache:(id)arg2;
- (void)copyStylePropertiesToShape:(id)arg1;
- (id)rawCopyOfStyle:(id)arg1;
- (void)copyTextPropertiesToShape:(id)arg1;
- (BOOL)canConvertToOutlines;
- (id)layersByConvertingToOutlines;
- (Class)layerSnapperObjectClass;
- (id)unselectedPreviewImage;
- (id)selectedPreviewImage;
- (void)changeTextColorTo:(id)arg1;
- (void)changeColor:(id)arg1;
- (BOOL)supportsInnerOuterBorders;
- (BOOL)acceptsOverrideValue:(id)arg1;
- (void)reapplyPreviousAttributesFromString:(id)arg1;
- (void)applyOverridesFromSource:(id)arg1;
- (unsigned long long)resizingConstraint;
- (BOOL)canFixHeight;
- (void)replaceFonts:(id)arg1;
- (void)writeStyleToPasteboard:(id)arg1;
- (id)CSSAttributes;
- (long long)layoutDirection;
- (id)setupWithLayerBuilderDictionary:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) Class superclass;

@end
