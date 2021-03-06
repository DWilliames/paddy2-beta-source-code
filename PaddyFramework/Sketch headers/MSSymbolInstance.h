//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSSymbolInstance.h"

@class NSDictionary, NSSet;

@interface MSSymbolInstance : _MSSymbolInstance
{
}

+ (id)keyPathsForValuesAffectingPreviewImages;
- (void)applyOverride:(id)arg1 toPoint:(id)arg2;
- (void)applyOverrides:(id)arg1;
- (void)setValue:(id)arg1 forOverridePoint:(id)arg2;
- (void)mapOverridesUnderOverridePoint:(id)arg1 inBlock:(id)arg2;
- (void)mapOverrides:(id)arg1 forOverridePoint:(id)arg2;
- (void)internalSetValue:(id)arg1 forOverridePointNamed:(id)arg2;
- (id)availableOverridesUnderPoint:(id)arg1;
- (void)updateOverridesWithObjectIDMap:(id)arg1;
@property(readonly, nonatomic) NSSet *influencingSymbolIDs;
- (BOOL)canScale;
- (BOOL)canBeTransformed;
- (struct CGSize)naturalSize;
- (void)multiplyBy:(double)arg1;
- (double)scale;
- (void)resetSizeToMaster;
- (void)updateOverrides:(id)arg1 withMapping:(id)arg2;
- (void)resizeInstanceToFitSymbol:(id)arg1;
- (BOOL)shouldWrapDetachedSymbolMasterInGroup:(id)arg1;
- (id)detachByReplacingWithGroup;
- (BOOL)canInsertIntoGroupWithoutInfiniteRecursion:(id)arg1 visitedSymbols:(id)arg2 symbolInstancesBySymbolID:(id)arg3;
- (BOOL)canInsertIntoGroupWithoutInfiniteRecursion:(id)arg1 symbolInstancesBySymbolID:(id)arg2;
- (unsigned long long)numberOfVisibleCells;
- (void)changeInstanceToSymbol:(id)arg1;
- (BOOL)isInstanceForMaster:(id)arg1;
- (id)symbolMaster;
- (BOOL)shouldRefreshOverlayForFlows;
- (id)inspectorViewControllerNames;
- (id)unselectedPreviewImage;
- (id)selectedPreviewImage;
- (id)replaceWithInstanceOfSymbol:(id)arg1;
- (BOOL)canMoveToLayer:(id)arg1 beforeLayer:(id)arg2;
@property(copy, nonatomic) NSDictionary *overrides;
- (id)availableOverrides;
- (id)overridePoints;
- (id)setupWithLayerBuilderDictionary:(id)arg1;

@end

