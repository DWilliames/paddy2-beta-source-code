//
//  PaddyNameGenerator.h
//  PaddyFramework
//
//  Created by David Williames on 12/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyNameGenerator : NSObject

+ (void)updateNameForLayer:(MSLayer*)layer;
+ (NSString*)generateNameStringForLayer:(MSLayer*)layer;

@end
