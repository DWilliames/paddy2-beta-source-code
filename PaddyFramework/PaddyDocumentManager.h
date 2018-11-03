//
//  PaddyDocumentManager.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//


@interface PaddyDocumentManager : NSObject

+ (void)setupForDocument:(MSDocument*)document;
+ (void)tearDownForDocument:(MSDocument*)document;
+ (void)tearDownAll;

+ (PaddyDocument*)currentPaddyDocument;
+ (PaddyDocument*)paddyDocumentForDocument:(MSDocument*)document;

@end
