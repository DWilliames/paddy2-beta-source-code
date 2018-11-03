//
//  PaddyDocument.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyDocument.h"
#import "PaddyLayoutManager.h"
#import "PaddyPaddingLayer.h"
#import "PaddyLayerListPreview.h"

@interface PaddyDocument ()

@property (nonatomic, strong) MSDocument *document;
@property (nonatomic, strong) PaddyStackGroupInspectorController *stackGroupInspectorViewController;
@property (nonatomic, strong) PaddyAlignmentInspectorController *alignmentInspectorViewController;
@property (nonatomic, strong) PaddyLayerDetailsInspectorController *layerDetailsInspectorViewController;
@property (nonatomic, strong) PaddyPaddingInspectorController *paddingInspectorViewController;

//@property (nonatomic, strong) id mouseEventMonitor;
@property (nonatomic, strong) PaddySelectionTracker *selectionTracker;
@property (nonatomic, strong) PaddySymbolManager *symbolManager;

@property (nonatomic) BOOL historyIsChanging;

@end

@implementation PaddyDocument

static void *observerContext = &observerContext;

+ (PaddyDocument*)current {
    return [PaddyDocumentManager currentPaddyDocument];
}

- (id)initWithDocument:(MSDocument *)document {
    
    if (!(self = [super init])) {
        return nil;
    }
    
    self.document = document;
    self.stackGroupInspectorViewController = [[PaddyStackGroupInspectorController alloc] initWithDocument:document];
    self.alignmentInspectorViewController = [[PaddyAlignmentInspectorController alloc] initWithDocument:document];
    self.layerDetailsInspectorViewController = [[PaddyLayerDetailsInspectorController alloc] initWithDocument:document];
    self.paddingInspectorViewController = [[PaddyPaddingInspectorController alloc] initWithDocument:document];
    
    self.historyIsChanging = false;
    
    self.selectionTracker = [[PaddySelectionTracker alloc] initWithPaddyDocument:self];
    self.symbolManager = [[PaddySymbolManager alloc] initWithPaddyDocument:self];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(historyWillChange:) name:@"MSHistoryMakerWillMoveThroughHistoryNotification" object:nil];
    [notificationCenter addObserver:self selector:@selector(historyDidChange:) name:@"MSHistoryMakerDidMoveThroughHistoryNotification" object:nil];
//    [notificationCenter addObserver:self selector:@selector(selectionDidChange:) name:@"MSSelectionDidChangeNotification" object:nil];
    
    [PaddyManager log:@"Setting up document: %@", document];
    
//    MSDocumentData *docData = self.document.documentData;
//
//    [PaddyObserver observeKeyPath:@"documentData.pages" ofObject:self.document withCallback:^(id oldValue, id newValue) {
//        [PaddyManager log:@"Pages changed from: %@ to %@", oldValue, newValue];
//    }];
    
    [PaddyObserver observeKeyPath:@"selectedLayers" ofObject:self.document withCallback:^(id oldValue, id newValue) {
        MSLayerArray *from = oldValue;
        MSLayerArray *to = newValue;

        [self updatedSelectionFrom:from.layers to:to.layers];
    }];
    
    //    self.mouseEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp) handler:^(NSEvent *event) {
    //        [PaddyManager log:@"> MOUSE EVENT: %@", event];
    //    }];
    
    
//    [self.document addObserver:self forKeyPath:@"previousSelectedLayers" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:observerContext];
    
    
    
//    [PaddyObserver observeKeyPath:@"stringValue" ofObject:widthTextField withCallback:^(id oldValue, id newValue) {
//        NSString *from = oldValue;
//        NSString *to = newValue;
//
//        NSLog(@"Width changed from: %@ to: %@", from, to);
//    }];
//    self.heightTextField = [layerInspector heightTextField];
    
//    originalTextColor = self.widthTextField.textColor;
    
    
//    [self.widthTextField addObserver:self forKeyPath:@"stringValue" options:NSKeyValueObservingOptionNew context:widthValueContext];
//    [self.heightTextField addObserver:self forKeyPath:@"stringValue" options:NSKeyValueObservingOptionNew context:heightValueContext];
    
    
    return self;
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [PaddySwizzle replaceMethod:@"MSEventHandler_inspectorViewControllersForLayers:standardControllers:" onClass:NSClassFromString(@"PaddyDocument")];
        [PaddySwizzle replaceMethod:@"MSInsertShapeEventHandler_insertShapeAsNewLayer:" onClass:NSClassFromString(@"PaddyDocument")];
        
        [PaddySwizzle replaceMethod:@"MSDocument_layerSelectionDidChange" onClass:NSClassFromString(@"PaddyDocument")];
//        [PaddySwizzle replaceMethod:@"MSDocument_layerPositionPossiblyChanged" onClass:NSClassFromString(@"PaddyDocument")];
        
        
//        [PaddySwizzle appendMethod:@"MSContentDrawView_pageDidChange:" with:^(MSContentDrawView *drawView, va_list args) {
//            [PaddyManager log:@"paget did change to: %@", args];
//        }];
//
//        [PaddySwizzle appendMethod:@"MSDocument_layerSelectionDidChange" with:^(MSDocument *document, va_list args) {
//            [PaddyManager log:@"Layer selection did change"];
//        }];
        
        
        
        
        // Experimental...
        [PaddySwizzle appendMethod:@"MSDocument_layerPositionPossiblyChanged" with:^(MSDocument *doc, va_list args) {
            // If the layer position changed, and the mouse is no longer down; then update the layers
            NSUInteger mouseButtonMask = [NSEvent pressedMouseButtons];
            BOOL leftMouseButtonDown = (mouseButtonMask & (1 << 0)) != 0;

            if (!leftMouseButtonDown) {

                [PaddyManager log:@"Layers changed position: %@", [doc selectedLayers].layers];

                PaddyBenchmark *benchmark = [PaddyBenchmark benchmark:@"Layer position possibly changed"];

                PaddyDocument *currentDoc = [PaddyDocumentManager currentPaddyDocument];
                [PaddyManager log:@"Current doc: %@", currentDoc];
                [currentDoc.selectionTracker updateLayers:[doc selectedLayers].layers];

                [benchmark logEnd];
            }
        }];
        
        [PaddySwizzle appendMethod:@"MSTextLayer_finishEditing" with:^(MSTextLayer *layer, va_list args) {
            [PaddyManager log:@"Text layer finished editing: %@", layer];
            [PaddyLayoutManager updateForLayer:layer withReason:ChangedTextValue];
        }];
        
    });
}

- (void)layerSelectionDidChange {
    
    MSDocument *document = (MSDocument*)self;
    
    if (PaddyManager.shared.enabled) {
        MSLayerArray *old = document.previousSelectedLayers;
        MSLayerArray *new = [document.documentData selectedLayers];
        
        [PaddyManager log:@"Layer selection did change \nFrom: %@ \nTo: %@", old, new];
        
        PaddyDocument *paddyDocument = [PaddyDocumentManager paddyDocumentForDocument:document];
        if (paddyDocument) {
            [paddyDocument updatedSelectionFrom:old.layers to:new.layers];
        }
    }
    
    NSString *methodString = [NSString stringWithFormat:@"%@%@", kSwizzlePrefix, @"layerSelectionDidChange"];
    SEL selector = NSSelectorFromString(methodString);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation invoke];
}

- (id)insertShapeAsNewLayer:(struct CGRect)rect {
    
    NSString *methodString = [NSString stringWithFormat:@"%@%@", kSwizzlePrefix, @"insertShapeAsNewLayer:"];
    SEL selector = NSSelectorFromString(methodString);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation setArgument:&rect atIndex:2];
    [invocation retainArguments];
    [invocation invoke];
    
    id __unsafe_unretained response;
    [invocation getReturnValue:&response];
    
    MSLayer *layer = response;
    
    if (PaddyManager.shared.enabled) {
        [PaddyLayoutManager updateForLayer:layer withReason:LayerWasInserted];
        [PaddyManager log:@"INSERT SHAPE AS NEW LAYER: %@", layer];
    }
    
    return layer;
}

- (unsigned long long)selectedBadgeMenuItem {
    [PaddySwizzle run:@"selectedBadgeMenuItem" on:self];
    
    MSLayer *layer = (MSLayer*)self;
    [PaddyManager log:@"selectedBadgeMenuItem: %@", layer];
    
    return 0;
}

- (id)badgeMenu {
    NSString *methodString = [NSString stringWithFormat:@"%@%@", kSwizzlePrefix, @"badgeMenu"];
    SEL selector = NSSelectorFromString(methodString);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation retainArguments];
    [invocation invoke];
    
    id __unsafe_unretained response;
    [invocation getReturnValue:&response];
    
    MSLayer *layer = (MSLayer*)self;
    [PaddyManager log:@"Generate menu for layer: %@", layer];
    //
    //    PaddyStackGroup *stackGroup = [PaddyStackGroup fromLayer:layer];
    //    if (stackGroup) {
    //
    //        if (stackGroup.alignments.count > 0) {
    //            NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Alignment"];
    //            menu.autoenablesItems = YES;
    //
    //            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Left" action:nil keyEquivalent:nil];
    //
    //
    //        } else if (stackGroup.stackProperties) {
    //            NSMenu *menu = [NSMenu alloc] initWithTitle:@""
    //        }
    //    }
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Test"];
    menu.autoenablesItems = YES;
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Item" action:nil keyEquivalent:@""];
    
    [menu addItem:item];
    return menu;
    
    
    return response;
}

- (NSMutableArray*)inspectorViewControllersForLayers:(NSArray*)layers standardControllers:(MSStandardInspectorViewControllers *)controllers {
    
    if (!layers) {
        layers = @[];
    }
    
    NSMutableArray *viewControllers = [PaddySwizzle run:@"inspectorViewControllersForLayers:standardControllers:" on:self with:layers, controllers, nil];
    
    if (PaddyManager.shared.enabled && [PaddyPreferences shouldShowInInspector]) {
        
        // Add view to inspector if necessary
        MSDocument *document = [PaddyManager currentDocument];
        PaddyDocument *paddyDocument = [PaddyDocumentManager paddyDocumentForDocument:document];
        
        // Only show if the currently selected layer is a Stack group, or all the selected layers can be grouped
        MSLayerArray *selectedLayers = [document selectedLayers];
        
        BOOL canShowStackGroupInspector = [selectedLayers containsLayers]; // Only if there is more than one layer
        BOOL canShowAlignmentInspector = [selectedLayers containsLayers];
        
        BOOL canShowPaddingInspector = [[paddyDocument paddingInspectorViewController] shouldShowForLayers:selectedLayers.layers];
        
        for (MSLayer *layer in selectedLayers.layers) {
            if (canShowStackGroupInspector) {
                canShowStackGroupInspector = [layer canBeContainedByGroup];
            }
            
            if (canShowAlignmentInspector) {
                canShowAlignmentInspector = [PaddyClass is:layer instanceOf:Group];
            }
        }
        
        // Which Inspector View Controller should we add everything after
//        NSString *postViewControllerName = @"MSFlowInspectorViewController";
        
        // No artboard
        //        (
        //         "<MSLayerInspectorViewController: 0x600000360240>",
        //         "<MSSpecialLayerViewController: 0x600001cf6d80>",
        //         "<MSMultipleFillInspectorViewController: 0x60000019ce50>",
        //         "<MSMultipleBorderInspectorViewController: 0x600002bbc620>",
        //         "<MSMultipleShadowInspectorViewController: 0x600002bbc700>",
        //         "<MSMultipleInnerShadowInspectorViewController: 0x600002bbc7e0>",
        //         "<MSBlurInspectorViewController: 0x6000005e4300>"
        //         )
        
        // With artboard
        //        (
        //         "<MSLayerInspectorViewController: 0x600000360240>",
        //         "<MSSpecialLayerViewController: 0x600001cf6d80>",
        //         "<PaddyIgnoreLayerInspectorController: 0x60c0012e6100>",
        //         "<PaddyAlignmentInspectorController: 0x600000105970>",
        //         "<PaddyStackGroupInspectorController: 0x60c000148cf0>",
        //         "<MSFlowInspectorViewController: 0x60000019cd80>",
        //         "<MSSharedStylesInspectorSection: 0x600000129600>",
        //         "<MSOpacityBlendingInspectorViewController: 0x600001cf6c80>",
        //         "<MSMultipleShadowInspectorViewController: 0x600002bbc700>"
        //         )
        
        // Insert it just after the 'Special Layer' inspector
        [viewControllers enumerateObjectsUsingBlock:^(id _Nonnull vc, NSUInteger index, BOOL * _Nonnull stop) {
            // MSLayerInspectorViewController or MSSpecialLayerViewController or MSFlowInspectorViewController
            if ([PaddyClass is:vc instanceOfClassNamed:@"MSSpecialLayerViewController"]) {
                
//                index = viewControllers.count - 1;
                
                if ([selectedLayers containsLayers]) {
                    PaddyLayerDetailsInspectorController *layerDetailsInspectorViewController = [paddyDocument layerDetailsInspectorViewController];
                    layerDetailsInspectorViewController.layers = selectedLayers.layers;
                    
                    [viewControllers insertObject:layerDetailsInspectorViewController atIndex:index + 1];
                }
                
                if (canShowPaddingInspector) {
                    PaddyPaddingInspectorController *paddingInspectorViewController = [paddyDocument paddingInspectorViewController];
                    paddingInspectorViewController.layers = selectedLayers.layers;
                    
                    [viewControllers insertObject:paddingInspectorViewController atIndex:index + 1];
                }
                
                if (canShowStackGroupInspector) {
                    PaddyStackGroupInspectorController *stackGroupViewController = [paddyDocument stackGroupInspectorViewController];
                    stackGroupViewController.layers = selectedLayers.layers;
                    
                    [viewControllers insertObject:stackGroupViewController atIndex:index + 1];
                }
                
                if (canShowAlignmentInspector) {
                    PaddyAlignmentInspectorController *alignmentViewController = [paddyDocument alignmentInspectorViewController];
                    alignmentViewController.groups = selectedLayers.layers;
                    
                    [viewControllers insertObject:alignmentViewController atIndex:index + 1];
                }

                *stop = YES;
            }
        }];
        
        
        
//        NSArray *filtered = [PaddyUtils filter:viewControllers withBlock:^BOOL(id obj) {
//            return [obj isKindOfClass:NSClassFromString(@"MSLayerInspectorViewController")];
//        }];
//
//        MSLayerInspectorViewController *layerInspector = filtered.count > 0 ? [filtered firstObject] : nil;
//        [[PaddyDocumentManager currentPaddyDocument] observeForLayerInspector:layerInspector];
//
//        NSLog(@"View controllers: %@", viewControllers);
        
        //        [PaddyManager log:@"View controllers: %@", viewControllers];
    }
    
    return viewControllers;
}

- (void)tearDown {
    [PaddyManager log:@"Tear down document: %@", self.document];
    
    [PaddyObserver removeObserversOfObject:self.document];
    [PaddyObserver removeObserversOfObject:self.document.documentData];
    
    [self updateAllLayerListPreviews];
    [self refreshInspector];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.document removeObserver:self forKeyPath:@"previousSelectedLayers"];
}

- (void)historyWillChange:(NSNotification*)notification {
    [PaddyManager log:@"HISTORY WILL CHANGE"];
    self.historyIsChanging = true;
}

- (void)historyDidChange:(NSNotification*)notification {
    [PaddyManager log:@"HISTORY DID CHANGE"];
    self.historyIsChanging = false;
    
    PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
    [document.selectionTracker resetCacheToLayers:[PaddyManager selectedLayers]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == observerContext && [keyPath isEqualToString:@"selectedLayers"]) {
        
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        
        MSLayerArray *from = oldValue;
        MSLayerArray *to = newValue;
        
        [self updatedSelectionFrom:from.layers to:to.layers];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updatedSelectionFrom:(NSArray*)oldSelection to:(NSArray*)newSelection {
    [PaddyManager log:@"Updated selection from: %@ to %@", oldSelection, newSelection];
    
    
    if (!PaddyManager.shared.enabled) {
        return;
    }
    
    // If the history is currrently changing, then ignore
    if (self.historyIsChanging) {
        [self.selectionTracker resetCacheToLayers:newSelection];
        return;
    }
    
    [self.selectionTracker updatedSelectionFrom:oldSelection to:newSelection];
}

- (void)updateSelectedLayerListPreviews {
    BCSideBarViewController *sideBarController = [self.document sidebarController];
    BCOutlineViewController *layerListViewController = [sideBarController layerListViewController];
    
    for (id node in layerListViewController.selectedItems) {
        BCTableCellView *cell = [layerListViewController tableCellViewForNode:node];
        if ([cell.objectValue isKindOfClass:NSClassFromString(@"MSLayer")]) {
            [PaddyLayerListPreview clearCacheForLayer:(MSLayer *)cell.objectValue];
        }
        
        if ([cell respondsToSelector:@selector(refreshPreviewImages)]) {
            [cell refreshPreviewImages];
        }
    }
}

- (void)updateAllLayerListPreviews {
    [PaddyManager log:@"UPDATE LAYER LIST"];
    BCSideBarViewController *sideBarController = [self.document sidebarController];
    
    if ([PaddyClass is:sideBarController instanceOfClassNamed:@"BCSideBarViewController"]) {
        BCOutlineViewController *layerListViewController = [sideBarController layerListViewController];
        
        BCOutlineView *outlineView = [layerListViewController outlineView];
        [outlineView reloadData];
    }
}

- (void)refreshInspector {
    [PaddyManager log:@"REFRESH INSPECTOR STACK VIEWS"];
    MSInspectorController *inspectorController = [self.document inspectorController];
    MSNormalInspector *normalInspector = [inspectorController normalInspector];
    MSInspectorStackView *stackView = [normalInspector stackView];
    
    [stackView reloadSubviews];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@", self.document];
}


@end
