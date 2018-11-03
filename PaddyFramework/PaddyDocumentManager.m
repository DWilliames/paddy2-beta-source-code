//
//  PaddyDocumentManager.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyDocumentManager.h"

@interface PaddyDocumentManager ()

@property (nonatomic, strong) NSMutableDictionary *paddyDocuments;

@end

@implementation PaddyDocumentManager

#pragma mark - Setup

+ (instancetype)shared {
    static PaddyDocumentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PaddyDocumentManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    self.paddyDocuments = [NSMutableDictionary dictionary];
    
    return self;
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PaddySwizzle replaceMethod:@"MSDocumentController_addDocument:" onClass:[self class]];
        [PaddySwizzle replaceMethod:@"MSDocumentController_removeDocument:" onClass:[self class]];
    });
}

+ (NSString*)keyForDocument:(MSDocument*)document {
    return [NSString stringWithFormat:@"%lu", (unsigned long)document.hash];
}

+ (PaddyDocument*)currentPaddyDocument {
    MSDocument *document = [NSClassFromString(@"MSDocument") currentDocument];
    return [self paddyDocumentForDocument:document];
}

+ (PaddyDocument*)paddyDocumentForDocument:(MSDocument*)document {
    NSString *key = [self keyForDocument:document];
    if (!key) {
        return nil;
    }
    
    PaddyDocument *paddyDocument = [PaddyDocumentManager.shared.paddyDocuments objectForKey:key];
    
    // If it doesn't exist, which should never happen, create it
    if (!paddyDocument) {
        paddyDocument = [[PaddyDocument alloc] initWithDocument:document];
        [PaddyDocumentManager.shared.paddyDocuments setObject:paddyDocument forKey:key];
    }
    
    return paddyDocument;
}

+ (void)setupForDocument:(MSDocument*)document {
    if (![document isKindOfClass:NSClassFromString(@"MSDocument")]) {
        return;
    }
    
    [PaddyManager log:@"Setting up document manager for document: %@", document];
    
    NSString *key = [self keyForDocument:document];
    if (!key) {
        [PaddyManager log:@"Issue for creating key for document: %@", document];
        return;
    }
    
    PaddyDocument *paddyDocument = [PaddyDocumentManager.shared.paddyDocuments objectForKey:key];
    
    if (!paddyDocument) {
        [PaddyManager log:@"Will create Paddy document: %@", document];
        paddyDocument = [[PaddyDocument alloc] initWithDocument:document];
        
        [PaddyDocumentManager.shared.paddyDocuments setObject:paddyDocument forKey:key];
    }
    
    [paddyDocument updateAllLayerListPreviews];
    [paddyDocument refreshInspector];
}

+ (void)tearDownForDocument:(MSDocument*)document {
    if (![document isKindOfClass:NSClassFromString(@"MSDocument")]) {
        return;
    }
    
    NSString *key = [self keyForDocument:document];
    
    PaddyDocument *paddyDocument = [PaddyDocumentManager.shared.paddyDocuments objectForKey:key];
    if (paddyDocument) {
        [paddyDocument tearDown];
        [PaddyDocumentManager.shared.paddyDocuments removeObjectForKey:key];
    }
}

+ (void)tearDownAll {
    [PaddyManager log:@"Tearing down Document manager"];
    
    for (PaddyDocument *paddyDocument in PaddyDocumentManager.shared.paddyDocuments.allValues) {
        [paddyDocument tearDown];
    }
    
    PaddyDocumentManager.shared.paddyDocuments = [NSMutableDictionary dictionary];
}


#pragma mark - Method sizzling

- (void)addDocument:(MSDocument*)document {
    
    [PaddySwizzle run:@"addDocument:" on:self with:document, nil];
    
    if (PaddyManager.shared.enabled) {
        [PaddyManager log:@"Open document: %@", document];
        [PaddyDocumentManager setupForDocument:document];
    }
}

- (void)removeDocument:(MSDocument*)document {
    
    [PaddySwizzle run:@"removeDocument:" on:self with:document, nil];
    
    if (PaddyManager.shared.enabled) {
        [PaddyManager log:@"Removed document: %@", document];
        [PaddyDocumentManager tearDownForDocument:document];
    }
}


@end
