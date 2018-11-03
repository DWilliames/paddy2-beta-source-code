//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSWindowController.h"

#import "NSToolbarDelegate.h"
#import "NSWindowDelegate.h"

@class MSPluginManager, MSPreferencePane, NSArray, NSCache, NSDictionary, NSString, NSToolbar;

@interface MSPreferencesController : NSWindowController <NSToolbarDelegate, NSWindowDelegate>
{
    MSPreferencePane *_currentPreferencePane;
    MSPluginManager *_pluginManager;
    NSArray *_toolbarItemIdentifiers;
    NSDictionary *_preferencePaneClasses;
    NSCache *_preferencePanes;
    NSToolbar *_toolbar;
}

+ (id)sharedController;
@property(nonatomic) __weak NSToolbar *toolbar; // @synthesize toolbar=_toolbar;
@property(retain, nonatomic) NSCache *preferencePanes; // @synthesize preferencePanes=_preferencePanes;
@property(copy, nonatomic) NSDictionary *preferencePaneClasses; // @synthesize preferencePaneClasses=_preferencePaneClasses;
@property(copy, nonatomic) NSArray *toolbarItemIdentifiers; // @synthesize toolbarItemIdentifiers=_toolbarItemIdentifiers;
@property(retain, nonatomic) MSPluginManager *pluginManager; // @synthesize pluginManager=_pluginManager;
@property(retain, nonatomic) MSPreferencePane *currentPreferencePane; // @synthesize currentPreferencePane=_currentPreferencePane;
- (void).cxx_destruct;
- (BOOL)validateToolbarItem:(id)arg1;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)windowWillReturnFieldEditor:(id)arg1 toObject:(id)arg2;
@property(nonatomic) unsigned long long selectedTabIndex;
- (void)updateWindowFrame;
- (void)switchToPaneWithIdentifier:(id)arg1;
- (void)switchPanes:(id)arg1;
- (void)adjustColorsAction:(id)arg1;
- (void)awakeFromNib;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

