//
//  PaddyAlignmentInspectorController.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyAlignmentInspectorController : NSViewController

@property (nonatomic, strong) NSArray *groups;

- (id)initWithDocument:(MSDocument*)document;

@end
