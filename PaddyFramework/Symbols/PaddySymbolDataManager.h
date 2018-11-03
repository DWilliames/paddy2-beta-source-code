//
//  PaddySymbolDataManager.h
//  PaddyFramework
//
//  Created by David Williames on 14/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddySymbolDataManager : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *cachedSymbolSizes;

// Cache if a symbol has padding or stack groups
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedSymbolHasPadding;
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedSymbolHasStacking;


// Cached size
- (void)saveCachedSize:(CGSize)size forSymbolInstance:(MSSymbolInstance*)instance andMaster:(MSSymbolMaster*)master;
- (NSValue*)cachedSizeForSymbolInstance:(MSSymbolInstance*)instance andMaster:(MSSymbolMaster*)master;
- (void)clearSizingCacheForSymbol:(MSSymbolMaster*)master;


// Symbol has padding / stacking
- (NSDictionary*)updateForSymbol:(MSSymbolMaster*)master;
- (BOOL)doesSymbolHavePadding:(MSSymbolMaster*)master;
- (BOOL)doesSymbolHaveStacking:(MSSymbolMaster*)master;

@end
