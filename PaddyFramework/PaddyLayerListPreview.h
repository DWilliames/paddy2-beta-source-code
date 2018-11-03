//
//  PaddyLayerListPreview.h
//  PaddyFramework
//
//  Created by David Williames on 4/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@interface PaddyLayerListPreview : NSObject

+ (void)updateLayerListPreviewFor:(BCTableCellView*)cellView;
+ (void)clearCacheForLayer:(MSLayer*)layer;
+ (void)clearAllCaches;

@end
