//
//  PaddyDocument.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyStackGroupInspectorController.h"
#import "PaddyAlignmentInspectorController.h"
#import "PaddyLayerDetailsInspectorController.h"
#import "PaddyPaddingInspectorController.h"
#import "PaddySelectionTracker.h"
#import "PaddySymbolManager.h"

@interface PaddyDocument : NSObject

@property (nonatomic, strong, readonly) MSDocument *document;

// Inspector view controllers
@property (nonatomic, strong, readonly) PaddyStackGroupInspectorController *stackGroupInspectorViewController;
@property (nonatomic, strong, readonly) PaddyAlignmentInspectorController *alignmentInspectorViewController;
@property (nonatomic, strong, readonly) PaddyLayerDetailsInspectorController *layerDetailsInspectorViewController;
@property (nonatomic, strong, readonly) PaddyPaddingInspectorController *paddingInspectorViewController;

@property (nonatomic, strong, readonly) PaddySelectionTracker *selectionTracker;
@property (nonatomic, strong, readonly) PaddySymbolManager *symbolManager;

+ (PaddyDocument*)current;

- (id)initWithDocument:(MSDocument*)document;
- (void)tearDown;

- (void)updatedSelectionFrom:(NSArray*)oldSelection to:(NSArray*)newSelection;

- (void)updateSelectedLayerListPreviews;
- (void)updateAllLayerListPreviews;
- (void)refreshInspector;

@end
