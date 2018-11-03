//
//  PaddyStackGroupInspectorController.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyStackGroupInspectorController : NSViewController <NSTextFieldDelegate>

@property (nonatomic, strong) NSArray *layers;

- (id)initWithDocument:(MSDocument*)document;

- (void)headerMouseDown;
- (void)headerMouseUp;

@end
