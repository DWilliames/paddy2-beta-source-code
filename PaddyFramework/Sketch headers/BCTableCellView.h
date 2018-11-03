//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "BCTableCellViewDelegate-Protocol.h"

@class BCCollapsableImageView, NSButton, NSDictionary, NSLayoutConstraint, NSPopUpButton, NSWindow;

@interface BCTableCellView : NSTableCellView
{
    BOOL _currentSelectedState;
    BOOL _isDrawingFocused;
    id <BCTableCellViewDelegate> _delegate;
    unsigned long long _displayState;
    NSButton *_badgeButton;
    NSPopUpButton *_popupBadgeButton;
    BCCollapsableImageView *_previewView;
    NSDictionary *_previewImages;
    BCCollapsableImageView *_secondaryPreviewView;
    NSLayoutConstraint *_badgeTrailingSpaceConstraint;
}

+ (void)initialize;
@property(nonatomic) BOOL isDrawingFocused; // @synthesize isDrawingFocused=_isDrawingFocused;
@property(nonatomic) BOOL currentSelectedState; // @synthesize currentSelectedState=_currentSelectedState;
@property(nonatomic) __weak NSLayoutConstraint *badgeTrailingSpaceConstraint; // @synthesize badgeTrailingSpaceConstraint=_badgeTrailingSpaceConstraint;
@property(nonatomic) __weak BCCollapsableImageView *secondaryPreviewView; // @synthesize secondaryPreviewView=_secondaryPreviewView;
@property(retain, nonatomic) NSDictionary *previewImages; // @synthesize previewImages=_previewImages;
@property(nonatomic) __weak BCCollapsableImageView *previewView; // @synthesize previewView=_previewView;
@property(nonatomic) __weak NSPopUpButton *popupBadgeButton; // @synthesize popupBadgeButton=_popupBadgeButton;
@property(nonatomic) __weak NSButton *badgeButton; // @synthesize badgeButton=_badgeButton;
@property(nonatomic) unsigned long long displayState; // @synthesize displayState=_displayState;
@property(nonatomic) __weak id <BCTableCellViewDelegate> delegate; // @synthesize delegate=_delegate;
@property(readonly, nonatomic) NSWindow *destinationWindow;
- (void)drawDragImageInRect:(struct CGRect)arg1;
@property(readonly, nonatomic) double widthForDragImage;
- (void)refreshPreviewImages;
- (void)updateTextColour;
- (void)renameNode;
@property(readonly, nonatomic) BOOL isTextFieldEditing;

- (void)updatePreviewsPreferExistingPrimaryImageOverNil:(BOOL)preferExisting; // Sketch 53+


- (void)updatePreviews;
- (void)drawRect:(struct CGRect)arg1;
- (void)drawTextFieldBorder;
- (void)handleBadgePressed:(id)arg1;
- (void)updateBadge;
- (void)updateBadgeImages;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (BOOL)isEventCurrent:(id)arg1;
- (void)setObjectValue:(id)arg1;
- (void)stopObserving;
- (void)startObserving;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (id)addSliceIconToImage:(id)arg1;
@property(readonly, nonatomic) id <BCOutlineViewNode> node;
@property(readonly, nonatomic, getter=isNodeSelected) BOOL nodeSelected;
- (void)dealloc;

@end

