//
//  PaddyCache.m
//  PaddyFramework
//
//  Created by David Williames on 1/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyCache.h"


#define kPaddingCache @"Padding"
#define kStackGroupCache @"StackGroup"

@interface PaddyCache ()

@property (nonatomic, strong) NSMutableDictionary *layersCache;

@end

@implementation PaddyCache

#pragma mark - Singleton

+ (instancetype)shared {
    static PaddyCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[PaddyCache alloc] init];
    });
    
    return cache;
}

- (instancetype)init {
    self = [super init];
    
    self.layersCache = [NSMutableDictionary dictionary];
    
    return self;
}

+ (NSMutableDictionary*)cacheForLayer:(MSLayer*)layer {
    NSMutableDictionary *layerCache = [PaddyCache.shared.layersCache objectForKey:layer.objectID];
    if (!layerCache) {
        layerCache = [NSMutableDictionary dictionary];
    }
    return layerCache;
}

+ (id)getValueForKey:(NSString*)key andLayer:(MSLayer*)layer {
    NSMutableDictionary *layerCache = [self cacheForLayer:layer];
    return [layerCache objectForKey:key];
}

+ (void)setValue:(id)value forKey:(NSString*)key andLayer:(MSLayer*)layer {
    NSMutableDictionary *layerCache = [self cacheForLayer:layer];
    [layerCache setObject:value forKey:key];
    [PaddyCache.shared.layersCache setObject:layerCache forKey:layer.objectID];
}



+ (PaddyPaddingLayer*)paddingForLayer:(MSLayer*)layer {
    id value = [self getValueForKey:kPaddingCache andLayer:layer];
    return [value isEqual:[NSNull null]] ? nil : value;
}

+ (PaddyStackGroup*)stackGroupForLayer:(MSLayer*)layer {
    id value = [self getValueForKey:kStackGroupCache andLayer:layer];
    return [value isEqual:[NSNull null]] ? nil : value;
}


+ (void)setPadding:(PaddyPaddingLayer*)padding forLayer:(MSLayer*)layer {
    if (layer) {
        [self setValue:(padding ? padding : [NSNull null]) forKey:kPaddingCache andLayer:layer];
    }
}

+ (void)setStackGroup:(PaddyStackGroup*)stackGroup forLayer:(MSLayer*)layer {
    if (layer) {
        [self setValue:(stackGroup ? stackGroup : [NSNull null]) forKey:kStackGroupCache andLayer:layer];
    }
}



+ (void)clear {
    PaddyCache *cache = [self shared];
    [cache.layersCache removeAllObjects];
}

+ (void)clearForLayer:(MSLayer*)layer {
    PaddyCache *cache = [self shared];
    [cache.layersCache removeObjectForKey:layer.objectID];
}

@end
