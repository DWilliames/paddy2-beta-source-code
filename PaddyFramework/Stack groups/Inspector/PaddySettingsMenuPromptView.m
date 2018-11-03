//
//  PaddySettingsMenuPromptView.m
//  PaddyFramework
//
//  Created by David Williames on 30/5/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddySettingsMenuPromptView.h"

@implementation PaddySettingsMenuPromptView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)rightMouseDown:(NSEvent*)event {
    [super rightMouseDown:event];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [menu insertItemWithTitle:@"Paddy settings" action:@selector(showSettings) keyEquivalent:@"" atIndex:0];
    
    [NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

- (void)showSettings {
    [PaddyManager showSettings];
}

@end
