//
//  PaddySymbolUtils.h
//  PaddyFramework
//
//  Created by David Williames on 14/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddySymbolUtils : NSObject

+ (MSLayerGroup*)createDetachedGroupFromSymbol:(MSSymbolInstance*)symbol withMaster:(MSSymbolMaster*)master;


@end
