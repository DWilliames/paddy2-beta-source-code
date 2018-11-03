//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

@class BCOutlineViewDataController, NSArray, NSPasteboard, NSURL;

@protocol BCOutlineViewDelegate <NSObject>
- (void)dataController:(BCOutlineViewDataController *)arg1 refreshPreviewsOnNodes:(NSArray *)arg2;
- (void)dataController:(BCOutlineViewDataController *)arg1 handleBadgePressedOnNode:(id)arg2 withAltState:(BOOL)arg3;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 copyNodes:(NSArray *)arg2 toParent:(id)arg3 after:(id)arg4;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 moveNodes:(NSArray *)arg2 toParent:(id)arg3 after:(id)arg4;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 canCopyNodes:(NSArray *)arg2 toParent:(id)arg3 after:(id)arg4;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 canMoveNodes:(NSArray *)arg2 toParent:(id)arg3 after:(id)arg4;
- (NSArray *)dataController:(BCOutlineViewDataController *)arg1 readNodesFromPasteboard:(NSPasteboard *)arg2;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 writeNodes:(NSArray *)arg2 toPasteboard:(NSPasteboard *)arg3;
- (NSArray *)dragTypesForDataController:(BCOutlineViewDataController *)arg1;
- (NSArray *)dataController:(BCOutlineViewDataController *)arg1 exportNodes:(NSArray *)arg2 toFolder:(NSURL *)arg3;
- (void)dataController:(BCOutlineViewDataController *)arg1 updateNode:(id)arg2 expandedState:(unsigned long long)arg3;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 isNodeExpandable:(id)arg2;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 isNodeExpanded:(id)arg2;
- (void)dataController:(BCOutlineViewDataController *)arg1 changeSelectionTo:(NSArray *)arg2;
- (BOOL)dataController:(BCOutlineViewDataController *)arg1 isNodeSelected:(id)arg2;

@optional
- (void)dataController:(BCOutlineViewDataController *)arg1 hoverNodeDidChangeTo:(id)arg2;
- (NSArray *)dataController:(BCOutlineViewDataController *)arg1 menuItemsForSelectedObjects:(NSArray *)arg2;
@end

