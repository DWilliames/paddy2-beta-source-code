//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MSHoverButton.h"

@class NSColor;

@interface BCWindowBadge : MSHoverButton
{
    NSColor *_tintColor;
}

+ (Class)cellClass;
@property(retain, nonatomic) NSColor *tintColor; // @synthesize tintColor=_tintColor;
- (void).cxx_destruct;
- (struct CGSize)fittingSize;
- (void)windowDidChangeKeyState:(id)arg1;
- (void)viewWillMoveToWindow:(id)arg1;
- (id)init;
- (id)initWithFrame:(struct CGRect)arg1;

@end

