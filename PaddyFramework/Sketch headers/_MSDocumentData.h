//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MSModelObject.h"

@class MSAssetCollection, MSSharedStyleContainer, MSSharedTextStyleContainer, MSSymbolContainer, NSArray, NSDictionary, NSMutableArray;

@interface _MSDocumentData : MSModelObject
{
    unsigned long long _currentPageIndex;
    BOOL _enableLayerInteraction;
    BOOL _enableSliceInteraction;
    NSDictionary *_userInfo;
    MSAssetCollection *_assets;
    NSMutableArray *_foreignSymbols;
    MSSharedStyleContainer *_layerStyles;
    MSSymbolContainer *_layerSymbols;
    MSSharedTextStyleContainer *_layerTextStyles;
    NSMutableArray *_pages;
}

+ (BOOL)allowsFaulting;
+ (Class)immutableClass;
- (void)syncPropertiesFromObject:(id)arg1;
- (BOOL)propertiesAreEqual:(id)arg1;
- (void)copyPropertiesToObject:(id)arg1 options:(unsigned long long)arg2;
- (void)setAsParentOnChildren;
- (void)movePageIndex:(unsigned long long)arg1 toIndex:(unsigned long long)arg2;
- (void)removeAllPages;
- (void)removePagesAtIndexes:(id)arg1;
- (void)removePageAtIndex:(unsigned long long)arg1;
- (void)removePage:(id)arg1;
- (void)insertPages:(id)arg1 afterPage:(id)arg2;
- (void)insertPage:(id)arg1 afterPage:(id)arg2;
- (void)insertPages:(id)arg1 beforePage:(id)arg2;
- (void)insertPage:(id)arg1 beforePage:(id)arg2;
- (void)insertPage:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)addPages:(id)arg1;
- (void)addPage:(id)arg1;
- (void)moveForeignSymbolIndex:(unsigned long long)arg1 toIndex:(unsigned long long)arg2;
- (void)removeAllForeignSymbols;
- (void)removeForeignSymbolsAtIndexes:(id)arg1;
- (void)removeForeignSymbolAtIndex:(unsigned long long)arg1;
- (void)removeForeignSymbol:(id)arg1;
- (void)insertForeignSymbols:(id)arg1 afterForeignSymbol:(id)arg2;
- (void)insertForeignSymbol:(id)arg1 afterForeignSymbol:(id)arg2;
- (void)insertForeignSymbols:(id)arg1 beforeForeignSymbol:(id)arg2;
- (void)insertForeignSymbol:(id)arg1 beforeForeignSymbol:(id)arg2;
- (void)insertForeignSymbol:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)addForeignSymbols:(id)arg1;
- (void)addForeignSymbol:(id)arg1;
- (void)initializeUnsetObjectPropertiesWithDefaults;
- (BOOL)hasDefaultValues;
- (void)performInitEmptyObject;
@property(retain, nonatomic) NSArray *pages; // @synthesize pages=_pages;
@property(retain, nonatomic) MSSharedTextStyleContainer *layerTextStyles; // @synthesize layerTextStyles=_layerTextStyles;
@property(retain, nonatomic) MSSymbolContainer *layerSymbols; // @synthesize layerSymbols=_layerSymbols;
@property(retain, nonatomic) MSSharedStyleContainer *layerStyles; // @synthesize layerStyles=_layerStyles;
@property(retain, nonatomic) NSArray *foreignSymbols; // @synthesize foreignSymbols=_foreignSymbols;
@property(retain, nonatomic) MSAssetCollection *assets; // @synthesize assets=_assets;
@property(copy, nonatomic) NSDictionary *userInfo; // @synthesize userInfo=_userInfo;
@property(nonatomic) BOOL enableSliceInteraction; // @synthesize enableSliceInteraction=_enableSliceInteraction;
@property(nonatomic) BOOL enableLayerInteraction; // @synthesize enableLayerInteraction=_enableLayerInteraction;
@property(nonatomic) unsigned long long currentPageIndex; // @synthesize currentPageIndex=_currentPageIndex;
- (void)performInitWithImmutableModelObject:(id)arg1;
- (void)enumerateChildProperties:(id)arg1;
- (void)enumerateProperties:(id)arg1;

@end

