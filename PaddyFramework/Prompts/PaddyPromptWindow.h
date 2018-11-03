//
//  PaddyPromptWindow.h
//  PaddyFramework
//
//  Created by David Williames on 25/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@interface PaddyPromptWindow : NSWindowController

+ (PaddyPromptWindow*)newWindow;

- (id)initWithNibName:(NSString*)nibName;

- (void)show;

@end
