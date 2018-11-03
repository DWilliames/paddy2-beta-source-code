//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSImmutableDocumentData.h"

#import "MSDocumentData.h"
#import "MSLayerContainment-Protocol.h"

@class MSImmutablePage, NSArray, NSDictionary;

@interface MSImmutableDocumentData : _MSImmutableDocumentData
{
    NSDictionary *_metadata;
    NSDictionary *_symbolsIndexedByID;
}

+ (unsigned long long)traitsForPropertyName:(id)arg1;
+ (id)loadDocumentDataWithMetadata:(id)arg1 loadBlock:(id)arg2;
@property(retain, nonatomic) NSDictionary *symbolsIndexedByID; // @synthesize symbolsIndexedByID=_symbolsIndexedByID;
@property(retain, nonatomic) NSDictionary *metadata; // @synthesize metadata=_metadata;
- (id)pagesAndArtboardsMetadata;
- (id)allSymbols;
- (id)localSymbols;
- (id)allArtboards;
- (BOOL)wasSavedByTestVersion;
- (BOOL)wasSavedByOldVersion;
- (id)usedFontNames;
- (void)decodePropertiesWithUnarchiver:(id)arg1;
@property(readonly, nonatomic) MSImmutablePage *currentPage;
- (id)symbolWithID:(id)arg1;
- (id)pageWithID:(id)arg1;
- (void)objectDidInit;
- (id)defaultPagesArray;
- (void)performInitEmptyObject;
- (void)performInitWithMutableModelObject:(id)arg1;
- (id)newPageForMigratedSymbols:(id)arg1;
- (void)arrangeMigratedSymbolsInGrid:(id)arg1;
- (void)stripRedundantOverridesFromInstances:(id)arg1 ofSymbol:(id)arg2;
- (void)stripRedundantOverridesFromInstancesOfSymbols:(id)arg1;
- (id)migratedSymbolFromSymbol:(id)arg1 group:(id)arg2;
- (id)migratedSymbolsFromOldSymbols:(id)arg1;
- (void)migratePropertiesFromV91OrEarlierWithUnarchiver:(id)arg1;
- (void)regenerateObjectIDOnSymbolMaster:(id)arg1;
- (void)migratePropertiesFromV78OrEarlierWithUnarchiver:(id)arg1;
- (void)migratePropertiesFromV62OrEarlierWithUnarchiver:(id)arg1;
- (void)migratePropertiesFromV60OrEarlierWithUnarchiver:(id)arg1;
- (void)migratePropertiesFromV54OrEarlierWithUnarchiver:(id)arg1;
- (BOOL)enumerateLayersWithOptions:(unsigned long long)arg1 block:(id)arg2;
- (void)enumerateLayers:(id)arg1;
- (id)lastLayer;
- (id)firstLayer;
- (BOOL)canContainLayer:(id)arg1;
- (unsigned long long)indexOfLayer:(id)arg1;
- (id)layerAtIndex:(unsigned long long)arg1;
- (BOOL)containsNoOrOneLayers;
- (BOOL)containsLayers;
- (BOOL)containsMultipleLayers;
- (BOOL)containsOneLayer;
- (unsigned long long)containedLayersCount;
- (id)containedLayers;
- (BOOL)canBeContainedByDocument;
- (BOOL)canBeContainedByGroup;
- (id)subObjectsForTreeDiff;
- (void)trackColors:(id)arg1;
- (id)colorFinderQueue;
- (void)findFrequentColorsWithCompletionBlock:(id)arg1;

// Remaining properties
@property(readwrite, nonatomic) NSArray *pages;

@end

