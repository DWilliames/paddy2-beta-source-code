//
//  PaddyNameReader.h
//  PaddyFramework
//
//  Created by David Williames on 12/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyNameReader : NSObject

@property (nonatomic, strong, readonly) MSLayer *layer;

@property (nonatomic, strong, readonly) NSArray *alignments;
@property (nonatomic, strong, readonly) PaddyModelStack *stackProperties;
@property (nonatomic, strong, readonly) PaddyModelPadding *paddingProperties;

@property (nonatomic, readonly) BOOL shouldIgnore;

+ (PaddyNameReader*)readFromLayer:(MSLayer*)layer;

@end
