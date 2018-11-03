//
//  PaddyPromptWindowManager.m
//  PaddyFramework
//
//  Created by David Williames on 9/7/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPromptWindowManager.h"
#import "PaddyPromptWindow.h"
#import "PaddyStackPromptWindow.h"
#import "PaddyPaddingPromptWindow.h"

@interface PaddyPromptWindowManager ()

@property (nonatomic, strong) PaddyPromptWindow *promptWindow;

@end


@implementation PaddyPromptWindowManager

+ (instancetype)shared {
    static PaddyPromptWindowManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PaddyPromptWindowManager alloc] init];
    });
    
    return manager;
}

- (id)init {
    return self;
}

+ (void)show:(PaddyPromptType)promptType {
    
    if (self.shared.promptWindow) {
        [self.shared.promptWindow.window close];
    }
    
    switch (promptType) {
        case SpacingPrompt:
            self.shared.promptWindow = [PaddyStackPromptWindow newWindow];
            [self.shared.promptWindow show];
            break;
        case PaddingPrompt:
            self.shared.promptWindow = [PaddyPaddingPromptWindow newWindow];
            [self.shared.promptWindow show];
            break;
    }
}

+ (void)showPaddingPromptWithModel:(PaddyModelPadding*)model andCallback:(void (^)(PaddyModelPadding*))completionHandler {
    PaddyPaddingPromptWindow *prompt = [[PaddyPaddingPromptWindow alloc] initWithModel:model andCallback:completionHandler];
    
    self.shared.promptWindow = prompt;
    [self.shared.promptWindow show];
}

@end
