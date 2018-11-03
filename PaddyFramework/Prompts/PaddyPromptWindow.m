//
//  PaddyPromptWindow.m
//  PaddyFramework
//
//  Created by David Williames on 25/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPromptWindow.h"

@interface PaddyPromptWindow ()

@end

@implementation PaddyPromptWindow

+ (PaddyPromptWindow*)newWindow {
    return [[[self class] alloc] init];
}

- (id)initWithNibName:(NSString*)nibName {
    if (!(self = [super initWithWindowNibName:nibName])) {
        return nil;
    }
    
    [self styleWindow];
    return self;
}


- (void)show {
    
    NSWindow* window = [self window];
    // Close it, just in case it is already open
    [window close];
    
    NSWindow* keyWindow = [[NSApplication sharedApplication] keyWindow];
    
    [keyWindow addChildWindow:window ordered:NSWindowAbove];
    [window makeKeyWindow];
    
    MSDocument *document = [PaddyManager currentDocument];
    
    [PaddyPromptWindow centerWindow:window comparedToExistingWindow:document.window];
    
}

+ (void)centerWindow:(NSWindow*)window comparedToExistingWindow:(NSWindow*)existingWindow {
    NSRect frame = window.frame;
    NSRect existingFrame = existingWindow.frame;
    
    CGFloat newX = (existingFrame.size.width - frame.size.width) / 2.0 + existingFrame.origin.x;
    CGFloat newY = (existingFrame.size.height - frame.size.height) / 2.0 + existingFrame.origin.y;
    
    [window setFrameOrigin:NSMakePoint(newX, newY)];
}


#pragma mark - Styling

- (void)styleWindow {
    NSWindow* window = [self window];
    
    NSWindowStyleMask mask = NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskClosable;
    
    [window setLevel:NSFloatingWindowLevel];
    [window setStyleMask:mask];
    [window setTitleVisibility:NSWindowTitleHidden];
    [window setTitlebarAppearsTransparent:YES];
    [[window standardWindowButton:NSWindowCloseButton] setHidden:NO];
    [[window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    [[window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [window setHasShadow:TRUE];
    [window setMovableByWindowBackground:FALSE];
    [window setHidesOnDeactivate:FALSE];
}


@end
