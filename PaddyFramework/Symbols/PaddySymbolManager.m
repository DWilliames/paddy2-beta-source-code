//
//  PaddySymbolManager.m
//  PaddyFramework
//
//  Created by David Williames on 6/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySymbolManager.h"
#import "PaddyLayoutManager.h"
#import "PaddyPaddingManager.h"
#import "PaddySymbolUtils.h"
#import "PaddySymbolDataManager.h"

@interface PaddySymbolManager ()

@property (nonatomic, strong) PaddyDocument *document;
@property (nonatomic, strong) PaddySymbolDataManager *dataManager;

@end


@implementation PaddySymbolManager

- (instancetype)initWithPaddyDocument:(PaddyDocument*)document {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.document = document;
    self.dataManager = [[PaddySymbolDataManager alloc] init];
    
    return self;
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [PaddySwizzle replaceMethod:@"MSImmutableSymbolMaster_modifiedMasterByApplyingInstance:inDocument:" onClass:[self class]];
        
        [PaddySwizzle appendMethod:@"MSOverrideViewController_applyOverrideToSelectedLayers:" with:^(id _self, va_list args) {
            MSLayerArray *layers = [[PaddyManager currentDocument] selectedLayers];
            [PaddyManager log:@"APPLY OVERRIDES TO: %@", layers];
            [PaddyLayoutManager updateForLayers:[PaddyManager selectedLayers] withReason:ChangedOverrides];
        }];
    });
}

- (MSImmutableSymbolMaster*)modifiedMasterByApplyingInstance:(MSImmutableSymbolInstance*)instance inDocument:(MSImmutableDocumentData*)doc {
    
    [PaddyManager log:@"> WILL MODIFIER: %@ ", instance];
    
//    MSSymbolInstance *instanceCopy = [[instance newMutableCounterpart] copyWithOptions:1];
//    NSLog(@"Instance: %@", instanceCopy);
//    NSLog(@"Doc data: %@", instanceCopy.documentData);
//    NSLog(@"Overrides: %@", [instanceCopy overrideValues]);
//    NSLog(@"Frame: %@", [instanceCopy frame]);
//    NSLog(@"Master: %@", [instanceCopy symbolMaster]);
//
//    [[[PaddyManager currentDocument] currentPage] insertLayer:instanceCopy atIndex:0];
    
    NSString *methodString = [NSString stringWithFormat:@"%@%@", kSwizzlePrefix, @"modifiedMasterByApplyingInstance:inDocument:"];
    SEL selector = NSSelectorFromString(methodString);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation setArgument:&instance atIndex:2];
    [invocation setArgument:&doc atIndex:3];
    [invocation retainArguments];
    [invocation invoke];
    
    id __unsafe_unretained response;
    [invocation getReturnValue:&response];
    
    MSImmutableSymbolMaster *master = response;
    
    
    BOOL dynamicallyRender = [PaddyData shouldSymbolBeDynamicallyRendered:[master newMutableCounterpart]];
//    NSLog(@"Dynamically render: %@ – %@", master.name, (dynamicallyRender ? @"YES" : @"NO"));
    
    if (PaddyManager.shared.enabled && dynamicallyRender) {
        MSSymbolMaster *mutableMaster = [master newMutableCounterpart];
        
//        NSLog(@"WIll dynamically render: %@", instance);
        
//        [PaddyManager log:@"MUTABLE: %@", mutableMaster];
        
//        NSLog(@"Master tree: %@", master.simpleTreeStructure);
        
//        MSSymbolInstance *instanceCopy = [instance newMutableCounterpart];
//        NSLog(@"> Overrides: %@", [instanceCopy overrideValues]);
        
//        MSSymbolMaster *mutableMaster = [[doc symbolWithID:instance.symbolID] newMutableCounterpart];
//        NSLog(@"Root master tree: %@", mutableMaster.simpleTreeStructure);
//
//        [mutableMaster applyOverrides:[instanceCopy overrideValues]];

        
//        NSArray *children = mutableMaster.children;
//        [PaddyManager log:@"LAYERS: %@", children];
        
        
        // Don't layout a symbol if it doesn't have padding or stacking
        
        PaddySymbolDataManager *dataManager = [[[PaddyDocumentManager currentPaddyDocument] symbolManager] dataManager];
        NSDictionary *props = [dataManager updateForSymbol:mutableMaster];
        
        BOOL hasPadding = [[props objectForKey:@"Padding"] boolValue];
        BOOL hasStacking = [[props objectForKey:@"Stacking"] boolValue];
        
        if (!hasPadding && !hasStacking) {
            [PaddyManager log:@"Doesn't have padding or stacking"];
            return master;
        }
        
//        NSLog(@"> Children: %@", mutableMaster.children);

        for (MSLayer *layer in mutableMaster.children) {
            if ([PaddyClass is:layer instanceOf:TextLayer]) {
                [PaddyManager log:@"TEXT %@: %@", layer.name, ((MSTextLayer*)layer).stringValue];
                [PaddyManager log:@"BEHAVIOUR %@: %lld", layer, ((MSTextLayer*)layer).textBehaviour];

//                MSTrailingLayerInfo *trailingInfo = [NSClassFromString(@"MSTrailingLayersMover") trailingLayerInfoForLayer:layer];
//                [PaddyManager log:@"TRAILING INFO: %@", trailingInfo.trailingLayers];

//                float hue = ((double)arc4random() / 0x100000000);
//                MSColor *color = (MSColor*)[NSClassFromString(@"MSColor") colorWithHue:hue saturation:1 brightness:1 alpha:1];
//                [((MSTextLayer*)layer) setTextColor:color];

            }
            else if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
                [PaddyManager log:@"INSTANCE: %@", layer.name];
                //                [PaddyLayoutManager updateSymbolInstanceSize:(MSSymbolInstance*)layer withMaster:mutableMaster];
                MSSymbolInstance *instance = [(MSSymbolInstance*)layer copyWithOptions:1];
                instance = (MSSymbolInstance*)layer;
                
                
//                NSLog(@"Overrides: %@", [instance overrideValues]);

                MSSymbolMaster *master = [[doc symbolWithID:instance.symbolID] newMutableCounterpart];
//                [instance.frame setHeight:20];
//                [PaddyManager log:@"MASTER: %@", master];
                
//                [instance setDocumentData:[doc newMutableCounterpart]];


//                MSRect *originalFrame = [instance.frame copy];
//                [document.symbolManager updateSizeForSymbolInstance:instance withMaster:master];
                
//                NSLog(@"Updated instance: %@ \nFrom: %@ \nTo: %@", instance, originalFrame, instance.frame);
                MSLayerGroup *replacementInstance = [PaddySymbolUtils createDetachedGroupFromSymbol:instance withMaster:master];
                MSLayerGroup *parent = [layer parentGroup];
                [parent addLayer:replacementInstance];
                [replacementInstance.frame setOrigin:instance.frame.origin];
                
                replacementInstance.isVisible = instance.isVisible;

                [instance removeFromParent];
                
            }
        }
        
        //        NSMutableArray *frames = [NSMutableArray array];
        //
        //        for (MSLayer *layer in mutableMaster.layers) {
        //            [frames addObject:layer.frame];
        //        }
        
        //        MSRect *totalFrame = [NSClassFromString(@"MSRect") rectWithUnionOfRects:frames];
        
        //        [PaddyManager log:@"BEGIN FRAME: %@", totalFrame];
        
        // CHANGE STUFF
        
//        MSShapeGroup *shapeGroup = [NSClassFromString(@"MSShapeGroup") shapeWithRect:NSMakeRect(0, 0, 10, 10)];
//        shapeGroup.style = [NSClassFromString(@"MSDefaultStyle") defaultStyle];
//
//        [mutableMaster insertLayer:shapeGroup afterLayer:mutableMaster.layers.lastObject];
        
        
//        var ovalShape = MSOvalShape.alloc().init();
//        ovalShape.frame = MSRect.rectWithRect(NSMakeRect(0,0,100,100));
//
//        var shapeGroup=MSShapeGroup.shapeWithPath(ovalShape);
//        var fill = shapeGroup.style().addStylePartOfType(0);
//        fill.color = MSColor.colorWithRGBADictionary({r: 0.8, g: 0.1, b: 0.1, a: 1});
//
//        context.document.currentPage().addLayers([shapeGroup]);
        
        
//        [PaddyLayoutManager layoutLayers:mutableMaster.children includingAncestors:NO];
        
        
        MSLayerGroup *newGroup = [PaddySymbolUtils createDetachedGroupFromSymbol:[instance newMutableCounterpart] withMaster:mutableMaster];
        
        newGroup.hasFixedTop = TRUE;
        newGroup.hasFixedRight = TRUE;
        newGroup.hasFixedBottom = TRUE;
        newGroup.hasFixedLeft = TRUE;
        

        [mutableMaster removeAllLayers];
//        [mutableMaster addLayers:newGroup.layers];
        [mutableMaster addLayer:newGroup];
        
//        NSLog(@"Children: %@", newGroup.children);
        
        // Save all the text behaviours before we resize the whole group; so that we can set them back – so they won't all be 'fixed'
        NSMutableDictionary *textBehaviours = [NSMutableDictionary dictionary];
        
        for (MSLayer *layer in newGroup.children) {
            if ([PaddyClass is:layer instanceOf:TextLayer]) {
                MSTextLayer *textLayer = (MSTextLayer*)layer;
                [textBehaviours setValue:@(textLayer.textBehaviour) forKey:layer.objectID];
            }
        }
        
        [newGroup resizeToFitChildrenWithOption:1];
        
        [newGroup.frame setOrigin:CGPointZero];
        [newGroup.frame setSize:instance.frame.size];
        
        
        NSMutableArray *layoutInstances = [NSMutableArray array];
        
        for (MSLayer *layer in newGroup.children) {
            
            if ([PaddyClass is:layer instanceOf:TextLayer]) {
                MSTextLayer *textLayer = (MSTextLayer*)layer;
                textLayer.textBehaviour = [[textBehaviours valueForKey:layer.objectID] longLongValue];
            }
            
            PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer withReason:CustomLayoutSelection];
            layoutInstance.includeAncestors = FALSE;
            
            [layoutInstances addObject:layoutInstance];
        }
        
        [PaddyLayoutManager updateForLayoutInstances:layoutInstances andSaveState:FALSE];
        
        
        
        [mutableMaster setResizesContent:FALSE];
        
//        NSLog(@"New group tree: %@", [newGroup simpleTreeStructure]);
        
        
        
        //        frames = [NSMutableArray array];
        //
        //        for (MSLayer *layer in mutableMaster.layers) {
        //            [frames addObject:layer.frame];
        //        }
        //
        //        totalFrame = [NSClassFromString(@"MSRect") rectWithUnionOfRects:frames];
        //
        //        [PaddyManager log:@"POST FRAME: %@", totalFrame];
        
        //    // TEST
        //    if ([[layer parentArtboard] isKindOfClass:NSClassFromString(@"MSSymbolMaster")]) {
        //        MSSymbolMaster *master = [layer parentArtboard];
        //        [master.frame setWidth:50];
        //        //        [master resizeToFitChildren];
        //    }
        
        //        [mutableMaster.frame setWidth:totalFrame.width];
        master = mutableMaster.immutableModelObject;
        
        //        MSSymbolInstance *mutableInstance = [instance newMutableCounterpart];
        //    [mutableInstance.frame setWidth:100];
        
        //        instance = mutableInstance.immutableModelObject;
        
        [PaddyManager log:@"Modified master by applying instance: %@ to doc: %@ – %@", instance, doc, master];
        [PaddyManager log:@"TREE: %@", master.simpleTreeStructure];
        
//        NSLog(@"MUTABLE TREE: %@", mutableMaster.simpleTreeStructure);
//        NSLog(@"TREE: %@", master.simpleTreeStructure);
    }
    
    return master;
}

- (void)updateSizeForSymbolInstance:(MSSymbolInstance*)instance withMaster:(MSSymbolMaster*)master  {
    [self updateSizeForSymbolInstance:instance andInsert:false withMaster:master];
}

- (void)updateSizeForSymbolInstance:(MSSymbolInstance*)instance andInsert:(BOOL)insert withMaster:(MSSymbolMaster*)master {
    [PaddyManager log:@"*** UPDATE INSTANCE SIZE: %@", instance];
    
    
    if (insert) {
        [PaddyManager log:@"*** INSERTING"];
    }
    
    if (!master) {
        master = [[instance documentData] symbolWithID:instance.symbolID];
    }
    
    
    [PaddyManager log:@"*** MASTER: %@", master];
    
    NSValue *sizeValue = [self.dataManager cachedSizeForSymbolInstance:instance andMaster:master];
    sizeValue = nil;
    
    if (sizeValue && !insert) {
        
        CGSize size = [sizeValue sizeValue];
        [PaddyManager log:@"Resize from cache!"];
        
//        [instance.frame setRectByIgnoringProportions:<#(struct CGRect)#> ]
        [instance.frame setSize:size];
        return;
    }
    
    if (!master) {
        [PaddyManager log:@"No master"];
        return;
    }
    
    // Only update if the symbol has a padding layer
    // TODO: Make this work!!
    
    PaddySymbolManager *symbolManager = [[PaddyDocumentManager currentPaddyDocument] symbolManager];
    BOOL hasPadding = [symbolManager.dataManager doesSymbolHavePadding:master];
    if (!hasPadding) {
        [PaddyManager log:@"Does not have Padding: %@", master];
        return;
    }
    
    
    MSLayerGroup *newGroup = [PaddySymbolUtils createDetachedGroupFromSymbol:instance withMaster:master];
    
//    if (insert) {
//        [[instance parentPage] insertLayer:newGroup atIndex:0];
//    }
    
    newGroup.hasFixedTop = TRUE;
    newGroup.hasFixedRight = TRUE;
    newGroup.hasFixedBottom = TRUE;
    newGroup.hasFixedLeft = TRUE;
    

    
    // Save all the text behaviours before we resize the whole group; so that we can set them back – so they won't all be 'fixed'
    NSMutableDictionary *textBehaviours = [NSMutableDictionary dictionary];
    
    for (MSLayer *layer in newGroup.children) {
        if ([PaddyClass is:layer instanceOf:TextLayer]) {
            MSTextLayer *textLayer = (MSTextLayer*)layer;
            [textBehaviours setValue:@(textLayer.textBehaviour) forKey:layer.objectID];
        }
    }
    
    BOOL commandHeld = ([NSEvent modifierFlags] & NSEventModifierFlagCommand) != 0;
    
    if (commandHeld) {
        [newGroup.frame setSize:instance.frame.size];
    }
    
    
    
    NSMutableArray *layoutInstances = [NSMutableArray array];
    
    float widestValue = 0;
    MSTextLayer *widestTextLayer;
    
    for (MSLayer *layer in newGroup.children) {
        
        if ([PaddyClass is:layer instanceOf:TextLayer]) {
            MSTextLayer *textLayer = (MSTextLayer*)layer;
            textLayer.textBehaviour = [[textBehaviours valueForKey:layer.objectID] longLongValue];
            
            if (textLayer.frame.width > widestValue) {
                widestTextLayer = textLayer;
                widestValue = textLayer.frame.width;
            }
        }
        
        PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer withReason:CustomLayoutSelection];
        layoutInstance.includeAncestors = FALSE;
        
        [layoutInstances addObject:layoutInstance];
    }
    
    [PaddyLayoutManager updateForLayoutInstances:layoutInstances andSaveState:NO];
    
//    [PaddyLayoutManager layoutLayers:newGroup.children includingAncestors:NO andSaveState:NO];
    [newGroup resizeToFitChildrenWithOption:1];
    
    
    [PaddyManager log:@"NEW FRAME: %@", newGroup.frame];
    
    float right = instance.frame.x + instance.frame.width;
    
    [instance.frame setSize:newGroup.frame.size];
    // If right aligned; offset it to the right
    if (widestTextLayer.textAlignment == 1) {
        [instance.frame setX:(right - instance.frame.width)];
    }
    
    [self.dataManager saveCachedSize:newGroup.frame.size forSymbolInstance:instance andMaster:master];
    
    
    if (insert) {
        [[instance parentPage] insertLayer:newGroup atIndex:0];
    }
    
    
    if (insert) {
        [newGroup.frame setY:(instance.frame.y - instance.frame.height - 10)];
        [newGroup.frame setX:instance.frame.x];
    } else {
        [newGroup removeFromParent];
    }
}

- (void)symbolMasterUpdated:(MSSymbolMaster*)master {
    [self.dataManager updateForSymbol:master];
    [self.dataManager clearSizingCacheForSymbol:master];
    
    NSMutableArray *layoutInstances = [NSMutableArray array];
    
//    NSLog(@"All influenced: %@", master.allInfluencedInstances);
    
    for (MSSymbolInstance *instance in master.allInfluencedInstances) {
        // Only include instances that are auto-resized
        // Or if the instance is used for padding
        
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:instance];
        if ((paddingLayer && paddingLayer.paddingProperties) || [PaddyData shouldSymbolBeAutoResized:instance]) {
            PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:instance withReason:SymbolMasterChanged];
            [layoutInstances addObject:layoutInstance];
        }
    }
    
//    NSLog(@"Affected layers: %@", layoutInstances);
    
    [PaddyLayoutManager updateForLayoutInstances:layoutInstances andSaveState:YES];
}

@end
