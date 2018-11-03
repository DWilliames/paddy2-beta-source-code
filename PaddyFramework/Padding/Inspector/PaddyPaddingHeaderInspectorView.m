//
//  PaddyPaddingHeaderInspectorView.m
//  PaddyFramework
//
//  Created by David Williames on 15/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingHeaderInspectorView.h"

@implementation PaddyPaddingHeaderInspectorView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    [self.controller headerMouseDown];
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];
    [self.controller headerMouseUp];
}

@end
