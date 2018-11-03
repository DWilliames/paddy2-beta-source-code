//
//  PaddyLayerListPreview.m
//  PaddyFramework
//
//  Created by David Williames on 4/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyLayerListPreview.h"
#import "PaddyNameGenerator.h"

@interface PaddyLayerListPreview ()

@property (nonatomic, strong) NSMutableDictionary *cachedLayerNames;
@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, strong) NSMutableDictionary *images;

@end

@implementation PaddyLayerListPreview

+ (instancetype)shared {
    static PaddyLayerListPreview *previews = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        previews = [[PaddyLayerListPreview alloc] init];
    });
    
    return previews;
}

- (instancetype)init {
    self = [super init];
    
    self.cache = [NSMutableDictionary dictionary];
    self.cachedLayerNames = [NSMutableDictionary dictionary];
    [self preloadImages];
    
    return self;
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [PaddySwizzle appendMethod:@"BCTableCellView_refreshPreviewImages" with:^(id cell, va_list args){
            static NSTimeInterval totalTime = 0;
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

            BCTableCellView *cellView = cell;
            [PaddyLayerListPreview updateLayerListPreviewFor:cellView];

            NSTimeInterval diff = ([[NSDate date] timeIntervalSince1970] - now) * 1000;
            totalTime += diff;

            [PaddyManager log:@"Time: %.4gms – Total: %.4gms", diff, totalTime];
        }];
        
//        [PaddySwizzle appendMethod:@"BCTableCellView_refreshPreviewImagesAlwaysDropPrimary:" with:^(id cell, va_list args){
//
//            BCTableCellView *cellView = cell;
//
//            if (cellView) {
//                NSLog(@"Refresh primary images: %@", cellView.previewImages);
//                [PaddyLayerListPreview updateLayerListPreviewFor:cellView];
//            }
//
//
//        }];
        
//        [PaddySwizzle appendMethod:@"MSLayer_previewImagesWithInterfaceTheme:" with:^(id layer, va_list args){
//            
////            MSLayer *layer = object;
//            
//            NSLog(@"Layer: %@", layer);
//            
//            
//        }];
    });
}

- (void)preloadImages {
    self.images = [NSMutableDictionary dictionary];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    NSArray *imageNames = @[@"layerlist_padding",
                            @"paddy_padding_layer_inverted",
                            @"paddy_padding_layer",
                            @"paddy_align_bottom_only",
                            @"paddy_align_left_only",
                            @"paddy_align_middle_only",
                            @"paddy_align_right_only",
                            @"paddy_align_top_only",
                            @"paddy_align_bottom_center",
                            @"paddy_align_bottom_left",
                            @"paddy_align_bottom_right",
                            @"paddy_align_middle_center",
                            @"paddy_align_middle_left",
                            @"paddy_align_middle_right",
                            @"paddy_align_top_center",
                            @"paddy_align_top_left",
                            @"paddy_align_top_right",
                            @"paddy_stack_view_horizontal_bottom",
                            @"paddy_stack_view_horizontal_middle",
                            @"paddy_stack_view_horizontal_top",
                            @"paddy_stack_view_vertical_center",
                            @"paddy_stack_view_vertical_left",
                            @"paddy_stack_view_vertical_right",
                            @"paddy_stack_view_horizontal",
                            @"paddy_stack_view_vertical",
                            @"paddy_stack_view"];
    
    for (NSString *name in imageNames) {
        NSImage *image = [bundle imageForResource:[NSString stringWithFormat:@"%@.pdf", name]];
        if (image) {
            [self.images setObject:image forKey:name];
        } else {
            [PaddyManager log:@"Unable to find image named: %@.pdf", name];
        }
    }
}

+ (void)clearCacheForLayer:(MSLayer*)layer {
    [PaddyLayerListPreview.shared.cache removeObjectForKey:layer.objectID];
    [PaddyLayerListPreview.shared.cachedLayerNames removeObjectForKey:layer.objectID];
}

+ (void)clearAllCaches; {
    [PaddyLayerListPreview.shared.cache removeAllObjects];
    [PaddyLayerListPreview.shared.cachedLayerNames removeAllObjects];
}

+ (NSString*)cachedImageNameForLayer:(MSLayer*)layer {
    id value = [PaddyLayerListPreview.shared.cache objectForKey:layer.objectID];
    NSString *name = [PaddyLayerListPreview.shared.cachedLayerNames objectForKey:layer.objectID];
    
    if ([value isEqual:[NSNull null]]) {
        return nil;
    }
    
    if (!value || ![name isEqualToString:layer.name]) {
        value = [self imageNameForLayer:layer];
        [PaddyLayerListPreview.shared.cache setObject:(value ? value : [NSNull null]) forKey:layer.objectID];
        [PaddyLayerListPreview.shared.cachedLayerNames setObject:layer.name forKey:layer.objectID];
    }
    
    return value;
}

+ (NSString*)imageNameForLayer:(MSLayer*)layer {
    NSMutableString *imageName = [NSMutableString string];
    
    PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
    PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
    
    if (!stackGroup && !paddingLayer) {
        return nil;
    }
    
    
    if (stackGroup && (stackGroup.stackProperties || stackGroup.alignments.count > 0)) {
        
        if (stackGroup.stackProperties) {
            [imageName appendString:@"paddy_stack_view"];
            
            switch (stackGroup.stackProperties.orientation) {
                case Horizontal:
                    [imageName appendString:@"_horizontal"];
                    break;
                case Vertical:
                    [imageName appendString:@"_vertical"];
                    break;
                case NoOrientation:
                    break;
            }
        } else {
            [imageName appendString:@"paddy_align"];
        }
        
        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
        NSArray *sortedAlignments = [stackGroup.alignments sortedArrayUsingDescriptors:@[highestToLowest]];
        
        for (NSNumber *alignmentValue in sortedAlignments) {
            PaddyAlignment alignment = [alignmentValue integerValue];
            switch (alignment) {
                case Left:
                    [imageName appendString:@"_left"];
                    break;
                case Center:
                    [imageName appendString:@"_center"];
                    break;
                case Right:
                    [imageName appendString:@"_right"];
                    break;
                case Top:
                    [imageName appendString:@"_top"];
                    break;
                case Middle:
                    [imageName appendString:@"_middle"];
                    break;
                case Bottom:
                    [imageName appendString:@"_bottom"];
                    break;
                case NoAlignment:
                    break;
            }
        }
        
        if (stackGroup.alignments.count == 1 && !stackGroup.stackProperties) {
            [imageName appendString:@"_only"];
        }
        
        
    } else if (paddingLayer && paddingLayer.paddingProperties) {
        [imageName appendString:@"paddy_padding_layer"];
    }
    
    if (imageName.length < 1) {
        return nil;
    }
    
    return imageName;
}


+ (void)updateLayerListPreviewFor:(BCTableCellView*)cellView {
    
    PaddyIconsPreference iconsPreference = [PaddyPreferences getIconsPreference];
    
    
    MSLayer *layer = cellView.objectValue;
    
    [PaddyCache clearForLayer:layer];
    [PaddyLayerListPreview clearCacheForLayer:layer];
    
    [PaddyNameGenerator updateNameForLayer:layer];
    
    if (iconsPreference != DefaultIcons) {
        
        NSString *imageName = [self cachedImageNameForLayer:layer];
        
        if (imageName.length > 13 && [[imageName substringToIndex:13] isEqualToString:@"paddy_padding"]) {
            if (cellView.isNodeSelected) {
                imageName = [imageName stringByAppendingString:@"_inverted"];
            }
        } else if (imageName && iconsPreference == SimplifiedIcons) {
            imageName = @"paddy_stack_view";
        }
        
        if (imageName) {
            NSImage *image = [PaddyLayerListPreview.shared.images objectForKey:imageName];
            
            
            if (image) {
                NSMutableDictionary *previewImages = [NSMutableDictionary dictionaryWithDictionary:cellView.previewImages];
                [previewImages setObject:image forKey:@"LayerListPreviewFocusedImage"];
                [previewImages setObject:image forKey:@"LayerListPreviewUnfocusedImage"];
                
                [cellView setPreviewImages:previewImages];
            } else {
//                NSLog(@"Cannot find image for: %@", imageName);
            }
        }
    }
    
    if ([cellView respondsToSelector:NSSelectorFromString(@"updatePreviews")]) {
        [cellView updatePreviews];
    }
    
//    else if ([cellView respondsToSelector:NSSelectorFromString(@"updatePreviewsPreferExistingPrimaryImageOverNil:")]) {
//        [cellView updatePreviewsPreferExistingPrimaryImageOverNil:false];
//    }
    
    
    
//    updatePreviewsPreferExistingPrimaryImageOverNil
}


@end
