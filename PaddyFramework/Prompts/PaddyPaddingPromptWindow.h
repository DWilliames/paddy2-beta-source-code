//
//  PaddyPaddingPromptWindow.h
//  PaddyFramework
//
//  Created by David Williames on 22/7/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPromptWindow.h"

@interface PaddyPaddingPromptWindow : PaddyPromptWindow

- (id)initWithModel:(PaddyModelPadding*)model andCallback:(void (^)(PaddyModelPadding*))completionHandler;

@end
