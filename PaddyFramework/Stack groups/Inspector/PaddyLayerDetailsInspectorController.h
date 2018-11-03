//
//  PaddyIgnoreLayerInspectorController.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyLayerDetailsInspectorController : NSViewController

@property (nonatomic, strong) NSArray *layers;

- (id)initWithDocument:(MSDocument*)document;

@end
