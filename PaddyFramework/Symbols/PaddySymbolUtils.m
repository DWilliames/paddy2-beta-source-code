//
//  PaddySymbolUtils.m
//  PaddyFramework
//
//  Created by David Williames on 14/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySymbolUtils.h"
#import "PaddyPaddingLayer.h"
#import "PaddyLayoutManager.h"

@implementation PaddySymbolUtils


+ (MSLayerGroup*)createDetachedGroupFromSymbol:(MSSymbolInstance*)symbol withMaster:(MSSymbolMaster*)master {
    if (!symbol || !master) {
        return nil;
    }
    
    [PaddyManager log:@"Creating a detached group for symbol: %@", symbol];
    [PaddyManager log:@"Master: %@", master];
    
//    NSLog(@"Creating a detached group for symbol: %@ – Master: %@", symbol, master);
    
    MSDocumentData *documentData = [master documentData];
//    NSLog(@"Doc data: %@", documentData);
    //    if (!documentData) {
    //        // If there's no document data from the symbol; try from the master
    //        documentData = [master documentData];
    //        NSLog(@"* Doc data: %@", documentData);
    //
    //    }
    
    NSArray *overrides = [symbol overrideValues];
    
    MSSymbolMaster *masterCopy = [master copyWithOptions:1];
    [PaddyManager log:@"Overrides values: %@", overrides];
    [PaddyManager log:@"Overrides: %@", [symbol overrides]];
//    NSLog(@"Overrides: %@", [symbol overrides]);
    
    
//    NSLog(@"Master: %@", [master simpleTreeStructure]);
//    NSLog(@"Master copy: %@", [masterCopy simpleTreeStructure]);
    
    NSMutableDictionary *trailingInfoLookup = [NSMutableDictionary dictionary];
    
    // Save all the 'trailing layer' info, for later
    for (MSLayer *layer in masterCopy.children) {
        if ([PaddyClass is:layer instanceOf:TextLayer]) {
            MSTrailingLayerInfo *trailingInfo = [NSClassFromString(@"MSTrailingLayersMover") trailingLayerInfoForLayer:layer];
            if (trailingInfo.trailingLayers.count > 0) {
                [trailingInfoLookup setObject:trailingInfo forKey:layer.objectID];
            }
            [PaddyManager log:@"Trailing info for: %@ – %@ – %@", layer, trailingInfo, trailingInfo.trailingLayers];
            [PaddyManager log:@"String value: %@", ((MSTextLayer*)layer).stringValue];
        }
    }
    
    if ([masterCopy respondsToSelector:@selector(applyOverrides:)]) { 
        [masterCopy applyOverrides:overrides];
    } else if ([masterCopy respondsToSelector:@selector(applyOverrides:document:)]) {
//        [masterCopy applyOverrides:overrides document:[PaddyManager currentDocument]];
    }
    
    
//    NSLog(@"Overriden master copy: %@", [masterCopy simpleTreeStructure]);
    
    
    NSArray *masterChildren = masterCopy.children;
    
    
    NSUInteger index = 0;
    // Detach symbol instances first
    for (MSLayer *layer in masterChildren) {
        
        [PaddyManager log:@"* Equivalent: %@ = %@", layer, [master.children objectAtIndex:index]];
        
        if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
            MSSymbolInstance *equivalentLayer = [master.children objectAtIndex:index];
            
            MSSymbolInstance *instance = ((MSSymbolInstance*)layer);
            id instanceOverrides = [[symbol overrides] objectForKey:instance.objectID];
//            NSLog(@"Child instance: %@ – overrides: %@", instance, instanceOverrides);
            
            if (instanceOverrides) {
                NSString *replacementSymbolID = [instanceOverrides objectForKey:@"symbolID"];
                if (replacementSymbolID) {
                    
                    id replacementSymbol = [documentData symbolWithID:replacementSymbolID];
//                    NSLog(@"Replacement (%@): %@", replacementSymbolID, replacementSymbol);
                }
            }
            
            [PaddyManager log:@"Instance overrides: %@, %@", [instanceOverrides class], instanceOverrides];
            
            
            [PaddyManager log:@"* Overrides: %@", [instance overrideValues]];
            if (equivalentLayer) {
                [PaddyManager log:@"** Overrides: %@", [equivalentLayer overrideValues]];
            }
            
            
            MSSymbolMaster *master = [documentData symbolWithID:instance.symbolID];
            [PaddyManager log:@"* Master for: %@ – %@ – %@", instance.name, master, instance.symbolMaster];
            
            if (equivalentLayer && !master) {
                [PaddyManager log:@"** Master for: %@ – %@ – %@", equivalentLayer.name, [documentData symbolWithID:equivalentLayer.symbolID], equivalentLayer.symbolMaster];
                master = equivalentLayer.symbolMaster;
            }
            
//            NSLog(@"**** Instance: %@ – %@", layer, layer.frame);
            MSLayerGroup *detachedSymbol = [self createDetachedGroupFromSymbol:instance withMaster:master];
            //            [detachedSymbol.frame setSize:layer.frame.size];
            NSLog(@"* Detached: %@ – %@", detachedSymbol, detachedSymbol.frame);
            
            if (detachedSymbol) {
                [[layer parentGroup] insertLayer:detachedSymbol afterLayer:layer];
                
                PaddyPaddingLayer *paddingSymbol = [PaddyPaddingLayer fromLayer:instance];
                
                if (paddingSymbol && paddingSymbol.paddingProperties) {
                    PaddyPaddingLayer *newPaddingLayer = [PaddyPaddingLayer fromLayer:detachedSymbol];
                    [newPaddingLayer updatePaddingProperties:paddingSymbol.paddingProperties andUpdateLayout:false];
                }
                
                [detachedSymbol setIsVisible:instance.isVisible];
                
                //                [detachedSymbol setFrame:layer.frame];
                
                [detachedSymbol.frame setOrigin:layer.frame.origin];
                
//                [detachedSymbol setFrame:[layer.frame copy]];
                
                NSMutableArray *paddingLayers = [NSMutableArray array];
                
//                if (!(layer.hasFixedHeight && layer.hasFixedWidth)) {
                    // Set the size, if a child layer is not a label with auto sizing
                    BOOL containsAutoSizeTextLayer = false;
                    for (MSLayer *child in detachedSymbol.children) {
                        if (!containsAutoSizeTextLayer && [PaddyClass is:child instanceOf:TextLayer]) {
                            MSTextLayer *textLayer = (MSTextLayer*)child;
                            if (textLayer.textBehaviour == 0){
                                containsAutoSizeTextLayer = true;
                            }
                        }
                        
                        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:child];
                        if (paddingLayer.paddingProperties && child.name.length >= 2 && [[child.name substringToIndex:2] isEqualToString:@"//"]) {
                            [paddingLayers addObject:paddingLayer];
                        }
                    }
                    
                    if (!containsAutoSizeTextLayer) {
                        // Update the padding values...
                        
                        double xRatio = layer.frame.width / detachedSymbol.frame.width;
                        double yRatio = layer.frame.height / detachedSymbol.frame.height;
                        
                        for (PaddyPaddingLayer *paddingLayer in paddingLayers) {
                            
                            PaddyModelPadding *props = paddingLayer.paddingProperties;
                            
                            NSNumber *newTop = (props.top != nil) ? @([props.top doubleValue] / yRatio) : nil;
                            NSNumber *newBottom = (props.bottom != nil) ? @([props.bottom doubleValue] / yRatio) : nil;
                            
                            NSNumber *newRight = (props.right != nil) ? @([props.right doubleValue] / xRatio) : nil;
                            NSNumber *newLeft = (props.left != nil) ? @([props.left doubleValue] / xRatio) : nil;
                        
                            PaddyModelPadding *newProps = [[PaddyModelPadding alloc] initWithTop:newTop right:newRight bottom:newBottom andLeft:newLeft inputCount:props.inputCount];
                            newProps.enabled = props.enabled;
                            
//                            NSLog(@"Ratios - x: %g, y: %g", xRatio, yRatio);
//                            NSLog(@"Old props: %@ – New: %@", props, newProps);
                            
                            [paddingLayer updatePaddingProperties:newProps andUpdateLayout:false];
                            
                        }
                        
//                        NSLog(@"BEFORE TREE\n%@", [masterCopy simpleTreeStructure]);
//                        NSLog(@"SET RECT: %@", layer.frame);
                        
                        [detachedSymbol.frame setRectByIgnoringProportions:layer.frame.rect];
//                        NSLog(@"AFTER TREE\n%@", [masterCopy simpleTreeStructure]);
//                        BOOL constrainProportions = detachedSymbol.constrainProportions;
//                        [detachedSymbol setConstrainProportions:FALSE];
//                        [detachedSymbol.frame setSize:layer.frame.size];
//                        [detachedSymbol setConstrainProportions:constrainProportions];
                    }
//                }
                
//                NSLog(@"Instance frame: %@", instance.frame);
//                NSLog(@"Detached symbol frame: %@", detachedSymbol.frame);
                
                [layer removeFromParent];
            }
            
        } else if ([PaddyClass is:layer instanceOf:TextLayer]) {
            MSTextLayer *equivalentLayer = [master.children objectAtIndex:index];
            
            MSTrailingLayerInfo *trailingInfo = [NSClassFromString(@"MSTrailingLayersMover") trailingLayerInfoForLayer:layer];
            [PaddyManager log:@"*Trailing info for: %@ – %@ – %@", layer, trailingInfo, trailingInfo.trailingLayers];
            
            [PaddyManager log:@"Equivalent string value: %@ == %@", ((MSTextLayer*)layer).stringValue, equivalentLayer.stringValue];
        }
        
        index++;
    }
    
    
    // Re-apply the 'trailing layer' info
    for (MSLayer *layer in masterChildren) {
        if ([PaddyClass is:layer instanceOf:TextLayer]) {
            MSTrailingLayerInfo *trailingInfo = [trailingInfoLookup objectForKey:layer.objectID];
            if (trailingInfo) {
                [PaddyManager log:@"Applying Trailing info for: %@ – %@ – %@", layer, trailingInfo, trailingInfo.trailingLayers];
                [NSClassFromString(@"MSTrailingLayersMover") applyTrailingLayerInfo:trailingInfo toLayer:layer];
            }
            
        }
    }
    
//    NSLog(@"NEW TREE\n%@", [masterCopy simpleTreeStructure]);
    
    
    // Save the 'frames' and to reset them later
    NSMutableArray *frames = [NSMutableArray array];
    masterChildren = masterCopy.children;
    
    // Save the frames
    for (MSLayer *layer in masterChildren) {
        [frames addObject:[layer.frame copy]];
    }
    
    //    SEL selector = NSSelectorFromString(@"copyDeep");
    //    ((void (*)(id, SEL))[masterCopy.layers methodForSelector:selector])(masterCopy.layers, selector);
    
    SEL selector = NSSelectorFromString(@"copyDeep");
    IMP imp = [masterCopy.layers methodForSelector:selector];
    NSArray *(*func)(id, SEL) = (void *)imp;
    NSArray *newLayers = func(masterCopy.layers, selector);
    
    //    NSArray *newLayers = [masterCopy.layers performSelector:NSSelectorFromString(@"copyDeep")];
    //    [PaddyManager log:@"NEW LAYERS: %@", newLayers];
    
    
    MSLayerArray *layers = [NSClassFromString(@"MSLayerArray") arrayWithLayers:newLayers];
    MSLayerGroup *newGroup = [NSClassFromString(@"MSLayerGroup") groupFromLayers:layers];
    
//    NSLog(@"New group: %@ frame: %@", newGroup, newGroup.frame);
//    [newGroup setFrame:[symbol.frame copy]];
//    NSLog(@"* New group: %@ frame: %@", newGroup, newGroup.frame);
    //    [PaddyManager log:@"NEW GROUP: %@, Children: %@", newGroup, newGroup.children];
    
    newGroup.name = symbol.name;
    newGroup.hasFixedTop = symbol.hasFixedTop;
    newGroup.hasFixedRight = symbol.hasFixedRight;
    newGroup.hasFixedBottom = symbol.hasFixedBottom;
    newGroup.hasFixedLeft = symbol.hasFixedLeft;
    newGroup.hasFixedWidth = symbol.hasFixedWidth;
    newGroup.hasFixedHeight = symbol.hasFixedHeight;
    newGroup.constrainProportions = symbol.constrainProportions;
    
    double scale = symbol.scale;
//    NSLog(@"Scale for: %@ – %g", symbol, scale);
    [newGroup multiplyBy:scale];
    
    index = 0;
    for (MSLayer *layer in newGroup.children) {
        //        [PaddyManager log:@"Layer: %@", layer];
        //        [PaddyManager log:@"Frame: %@", layer.frame];
        
        if ([PaddyClass is:layer instanceOf:TextLayer]) {
            //            [PaddyManager log:@"TEXT %@: %@", layer.name, ((MSTextLayer*)layer).stringValue];
        } else if ([PaddyClass is:layer instanceOf:SymbolInstance]) {
            // Replace itself
            [PaddyManager log:@"SHOULD NOT BE POSSIBLE"];
        }
        
        if (masterChildren.count > index) {
            MSLayer *equivalentLayer = [masterChildren objectAtIndex:index];
            [PaddyManager log:@"EQUIVALENT for: %@ == %@", layer, equivalentLayer];
            
//            NSLog(@"Equivalent for: %@ == %@", layer, equivalentLayer);
            
            if (![PaddyClass is:equivalentLayer instanceOf:SymbolMaster]) {
//                NSLog(@"Set origin for: %@ from (%g, %g) to (%g, %g)", layer, layer.frame.origin.x, layer.frame.origin.y, equivalentLayer.frame.origin.x, equivalentLayer.frame.origin.y);
                [layer.frame setOrigin:equivalentLayer.frame.origin];
            }
            
            
            //            [layer.frame setSize:equivalentLayer.frame.size];
            
            if ([PaddyClass is:layer instanceOf:TextLayer]) {
                
                MSTextLayer *textLayer = (MSTextLayer*)layer;
                MSTextLayer *equivalentTextLayer = (MSTextLayer*)equivalentLayer;
                
                [PaddyManager log:@"TEXT %@: %@", layer.name, ((MSTextLayer*)layer).stringValue];
                [PaddyManager log:@"BEHAVIOUR orignial %@: equivalent %@", textLayer.textBehaviour == 1 ? @"FIXED" : @"AUTO", equivalentTextLayer.textBehaviour == 1 ? @"FIXED" : @"AUTO"];
                
                [textLayer setTextBehaviour:equivalentTextLayer.textBehaviour];
            }
        } else {
            [PaddyManager log:@"NO EQUIVALENT for: %@", layer];
        }
        
        // Remove 'clipping' from the background layer
//        if ([PaddyClass is:layer instanceOf:ShapeGroup] && [layer.name isEqualToString:@"Background"]) {
//            [PaddyManager log:@"### FOUND BACKGROUND: %@", layer];
//            MSShapeGroup *background = (MSShapeGroup*)layer;
//            [background setHasClippingMask:FALSE];
//        }
        
        
        //
        //        if (frames.count > 0) {
        //            MSRect *frame = [frames firstObject];
        //            [layer.frame setOrigin:frame.origin];
        //            [frames removeObjectAtIndex:0];
        //        } else {
        //            [PaddyManager log:@"NO FRAME for: %@", layer];
        //        }
        
        index++;
        
        //        [PaddyManager log:@"Frame 2: %@", layer.frame];
    }
    
//    NSLog(@"- %@", symbol);
//    NSLog(@"> Instance frame: %@", symbol.frame);
//    NSLog(@"> Detached frame: %@", newGroup.frame);
    
    
//    [newGroup.frame setRectByIgnoringProportions:symbol.frame.rect];
//    [newGroup.frame setSize:symbol.frame.size];
//    NSLog(@">> Detached frame: %@", newGroup.frame);
    
    
    
    NSMutableArray *existingPaddingModels = [NSMutableArray array];
    NSMutableArray *contentLayers = [NSMutableArray array];
    
    frames = [NSMutableArray array];
    for (MSLayer *layer in master.layers) {
        
        PaddyPaddingLayer *paddingLayer = [PaddyPaddingLayer fromLayer:layer];
        if (!paddingLayer.paddingProperties) { // && ![layer isMasked]
            if (![PaddyPaddingLayer shouldLayerBeIgnored:layer]) {
                 [contentLayers addObject:layer];
            }
            
        } else {
            [existingPaddingModels addObject:paddingLayer.paddingProperties];
        }
    }
    
    MSRect *contentRect = [PaddyLayerUtils boundingRectForLayers:contentLayers withFilter:^BOOL(MSLayer *layer) {
        return ![PaddyData shouldLayerBeIgnored:layer];
    }];
    
    double left = contentRect.x;
    double top = contentRect.y;
    double right = master.frame.width - contentRect.width - contentRect.x;
    double bottom = master.frame.height - contentRect.height - contentRect.y;
    
    // Round to 2 decimal places – to avoid things like -4.44089e-16
    int decimalPlaces = 2;
    float multiplier = powf(10, decimalPlaces);
    
    left = ((int)(left * multiplier)) / multiplier;
    top = ((int)(top * multiplier)) / multiplier;
    right = ((int)(right * multiplier)) / multiplier;
    bottom = ((int)(bottom * multiplier)) / multiplier;
    
    
    PaddyPaddingViewInputCount inputCount = AllInputs;
    
    if (top == bottom && left == right) {
        if (top == left) {
            inputCount = OneInput;
        } else {
            inputCount = TwoInputs;
        }
    }
    
    [newGroup resizeToFitChildrenWithOption:1];
    
    
    PaddyModelPadding *paddingProps = [[PaddyModelPadding alloc] initWithTop:@(top) right:@(right) bottom:@(bottom) andLeft:@(left) inputCount:inputCount];
    
    NSLog(@"Padding props for: %@ — %@", symbol, paddingProps);
    
    [PaddyManager log:@"Padding props for: %@ = %@", contentRect, paddingProps];
    
    [PaddyManager log:@"Creating background rect for: %@", master];
    MSShapeGroup *bgRect = [NSClassFromString(@"MSShapeGroup") shapeWithRect:CGRectMake(0, 0, newGroup.frame.width, newGroup.frame.height)];
    bgRect.name = [NSString stringWithFormat:@"// %@ BG", master.name];
    
//        [PaddyData saveShouldBeIgnored:YES toLayer:bgRect];
    
    [PaddyManager log:@"Size: (%f, %f)", newGroup.frame.width, newGroup.frame.height];
    
    MSStyle *style = bgRect.style;
    
    
    
    if (master.hasBackgroundColor && master.backgroundColor && master.includeBackgroundColorInInstance) {
        [PaddyManager log:@"Should include background"];
        
        MSStyleFill *fill = [style addStylePartOfType:0];
        [fill setColor:master.backgroundColor];
        
        [PaddyData savePaddingData:paddingProps toLayer:bgRect];
        
        [newGroup insertLayer:bgRect atIndex:0];
    } else if (!(left == 0 && top == 0 && right == 0 && bottom == 0) && ![existingPaddingModels containsObject:paddingProps]) {
        
        [PaddyData savePaddingData:paddingProps toLayer:bgRect];
        
        [style removeAllStyleFills];
        [style removeAllStyleShadows];
        [style removeAllStyleBorders];
        //        [bgRect setIsVisible:FALSE];
        [newGroup insertLayer:bgRect atIndex:0];
        
    }
    
    
    
    
    
    //    MSLayerGroup *parent = [symbol parentGroup];
    //    [parent insertLayer:newGroup afterLayer:symbol];
    
    // TODO: Offset by actual offset
//    [newGroup.frame setOrigin:symbol.frame.origin];
    
    
//    [newGroup resizeToFitChildrenWithOption:1];
    
    // If there's no padding / stacking in the symbol. Then resize.
//    if (existingPaddingModels.count == 0) {
//        [newGroup.frame setSize:symbol.frame.size];
//    }
    
    
    
//    NSMutableArray *layoutInstances = [NSMutableArray array];
//
//    for (MSLayer *layer in newGroup.children) {
//        PaddyLayoutInstance *layoutInstance = [PaddyLayoutInstance fromLayer:layer withReason:CustomLayoutSelection];
//        layoutInstance.includeAncestors = FALSE;
//
//        [layoutInstances addObject:layoutInstance];
//    }
//
////    [PaddyLayoutManager updateForLayoutInstances:layoutInstances andSaveState:NO];
//
//    NSLog(@"Layout: %@", layoutInstances);
    
    NSLog(@"New group tree: %@", [newGroup simpleTreeStructure]);
    
    
    return newGroup;
}

@end
