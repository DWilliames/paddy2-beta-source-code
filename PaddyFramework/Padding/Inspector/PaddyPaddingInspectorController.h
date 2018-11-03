//
//  PaddyPaddingInspectorController.h
//  PaddyFramework
//
//  Created by David Williames on 15/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@interface PaddyPaddingInspectorController : NSViewController <NSTextFieldDelegate>

@property (nonatomic, strong) NSArray *layers;

- (id)initWithDocument:(MSDocument*)document;

- (BOOL)shouldShowForLayers:(NSArray*)layers;

- (void)headerMouseDown;
- (void)headerMouseUp;

- (void)toggleInputCount;

@end
