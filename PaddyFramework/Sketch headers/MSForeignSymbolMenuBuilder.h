//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class MSAssetLibraryController, MSDocument, MSSymbolsMenuBuilder;

@interface MSForeignSymbolMenuBuilder : NSObject
{
    BOOL _requiresSymbolSubmenu;
    CDUnknownBlockType _filter;
    MSDocument *_document;
    MSSymbolsMenuBuilder *_menuBuilder;
}

@property(retain, nonatomic) MSSymbolsMenuBuilder *menuBuilder; // @synthesize menuBuilder=_menuBuilder;
@property(retain, nonatomic) MSDocument *document; // @synthesize document=_document;
@property(nonatomic) BOOL requiresSymbolSubmenu; // @synthesize requiresSymbolSubmenu=_requiresSymbolSubmenu;
@property(copy, nonatomic) CDUnknownBlockType filter; // @synthesize filter=_filter;
- (void).cxx_destruct;
- (id)buildMenuItemsForMenu:(id)arg1 withAction:(id)arg2;
- (id)buildMenuItemsForMenu:(id)arg1 withTarget:(id)arg2 selector:(SEL)arg3;
- (id)menuItemForSymbols:(id)arg1 inMenu:(id)arg2 library:(id)arg3 localSymbolMapTable:(id)arg4 target:(id)arg5 selector:(SEL)arg6;
- (id)buildLibraryToSymbolMap;
@property(readonly, nonatomic) MSAssetLibraryController *librariesController;
- (id)initWithDocument:(id)arg1;

@end

