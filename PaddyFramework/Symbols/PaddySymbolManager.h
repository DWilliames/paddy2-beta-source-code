//
//  PaddySymbolManager.h
//  PaddyFramework
//
//  Created by David Williames on 6/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@class PaddyDocument;
@class PaddySymbolDataManager;


@interface PaddySymbolManager : NSObject

@property (nonatomic, strong, readonly) PaddySymbolDataManager *dataManager;

- (instancetype)initWithPaddyDocument:(PaddyDocument*)document;

- (void)updateSizeForSymbolInstance:(MSSymbolInstance*)instance withMaster:(MSSymbolMaster*)master;
- (void)updateSizeForSymbolInstance:(MSSymbolInstance*)instance andInsert:(BOOL)insert withMaster:(MSSymbolMaster*)master;

- (void)symbolMasterUpdated:(MSSymbolMaster*)master;

@end
