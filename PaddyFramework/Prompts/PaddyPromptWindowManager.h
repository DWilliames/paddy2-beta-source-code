//
//  PaddyPromptWindowManager.h
//  PaddyFramework
//
//  Created by David Williames on 9/7/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyPromptType) {
    SpacingPrompt = 0,
    PaddingPrompt = 1
};


@interface PaddyPromptWindowManager : NSObject

+ (PaddyPromptWindowManager*)shared;
+ (void)show:(PaddyPromptType)promptType;

+ (void)showPaddingPromptWithModel:(PaddyModelPadding*)model andCallback:(void (^)(PaddyModelPadding*))completionHandler;

@end
