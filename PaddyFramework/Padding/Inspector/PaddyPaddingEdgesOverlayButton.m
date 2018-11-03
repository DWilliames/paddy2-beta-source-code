//
//  PaddyPaddingEdgesOverlayButton.m
//  PaddyFramework
//
//  Created by David Williames on 26/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingEdgesOverlayButton.h"

@implementation PaddyPaddingEdgesOverlayButton

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [PaddySwizzle appendMethod:@"NSTextField_mouseUp:" with:^(id label, va_list args){
            if ([[label className] isEqualToString:@"MSTextLabelForUpDownField"] && [label tag] == 99) {
                PaddyDocument *document = [PaddyDocumentManager currentPaddyDocument];
                PaddyPaddingInspectorController *viewController = [document paddingInspectorViewController];
                [viewController toggleInputCount];
            }
        }];
    });
}

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    [self setTransparent:FALSE];
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    [self setTransparent:TRUE];
}

@end
