//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSSymbolMaster.h"

@class NSArray, NSSet, NSString;

@interface MSSymbolMaster : _MSSymbolMaster
{
    long long _changeIdentifier;
}

+ (void)copyPropertiesFrom:(id)arg1 to:(id)arg2;
+ (id)convertSymbolToArtboard:(id)arg1;
+ (id)convertArtboardToSymbol:(id)arg1;
@property(nonatomic) long long changeIdentifier; // @synthesize changeIdentifier=_changeIdentifier;
- (BOOL)limitsSelectionToBounds;
- (void)object:(id)arg1 didChangeProperty:(id)arg2;
- (id)parentSymbol;
- (id)rootForNameUniquing;
- (id)ancestorIDsForLayerNamed:(id)arg1 skip:(id)arg2;
- (id)ancestorIDsForLayerNamed:(id)arg1;
- (BOOL)isSafeToDelete;
- (void)multiplyBy:(double)arg1;
- (id)ungroup;
- (void)removeFromParentAndDetachAllInstances;
- (void)detachAllInstances;
- (BOOL)ensureSymbolIDUniqueInDocument:(id)arg1;
- (BOOL)hasInstances;
@property(readonly, nonatomic) NSArray *allInfluencedInstances;
- (id)nestedSymbolsSkipping:(id)arg1;
@property(readonly, nonatomic) NSSet *nestedSymbols;
@property(readonly, nonatomic) NSArray *allInstances;
- (id)newSymbolInstance;
- (id)copyWithIDMapping:(id)arg1;
- (void)moveChildrenToIdenticalPositionAfterResizeFromRect:(struct CGRect)arg1;
- (void)copyPropertiesToObject:(id)arg1 options:(unsigned long long)arg2;
- (void)syncPropertiesFromObject:(id)arg1;
- (void)performInitWithImmutableModelObject:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)generatePreviewWithImageSize:(struct CGSize)arg1 previewSize:(struct CGSize)arg2 colorSpace:(id)arg3 completionBlock:(id)arg4;
- (id)unselectedPreviewImage;
- (id)selectedPreviewImage;
- (struct CGRect)optimalBoundingBox;
- (BOOL)canSnapSizeToLayer:(id)arg1;
- (BOOL)canSnapToLayer:(id)arg1;
- (Class)shareableObjectReferenceClass_bc;
- (void)applyStyleToMenuItem:(id)arg1 withColorSpace:(id)arg2;
- (id)generatePreviewForManageSheetWithCompletionBlock:(id)arg1;
- (id)generatePreviewForPopup:(id)arg1 completionBlock:(id)arg2;
- (id)generatePreviewForMenuItem:(id)arg1 withColorSpace:(id)arg2 completionBlock:(id)arg3;
- (void)generateShadowedPreviewWithImageSize:(struct CGSize)arg1 previewSize:(struct CGSize)arg2 withColorSpace:(id)arg3 completionBlock:(id)arg4;
- (void)applyOverrides:(id)arg1;
- (id)availableOverrides;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readwrite, copy, nonatomic) NSString *name;
@property(readonly) Class superclass;

@end

