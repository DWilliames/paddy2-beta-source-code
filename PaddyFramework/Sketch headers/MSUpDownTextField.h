//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//


#import "MSUpDownProtocol-Protocol.h"

@class MSUpDownController, NSString;

@interface MSUpDownTextField : NSTextField <NSTextViewDelegate, MSUpDownProtocol, NSTouchBarDelegate>
{
    BOOL _hasMinimum;
    BOOL _hasMaximum;
    id _refreshDelegate;
    MSUpDownController *_upDownController;
    double _ownMinimum;
    double _ownMaximum;
    unsigned long long _scrubberCount;
    unsigned long long _scrubberIndex;
}

@property(nonatomic) unsigned long long scrubberIndex; // @synthesize scrubberIndex=_scrubberIndex;
@property(nonatomic) unsigned long long scrubberCount; // @synthesize scrubberCount=_scrubberCount;
@property(nonatomic) double ownMaximum; // @synthesize ownMaximum=_ownMaximum;
@property(nonatomic) double ownMinimum; // @synthesize ownMinimum=_ownMinimum;
@property(nonatomic) BOOL hasMaximum; // @synthesize hasMaximum=_hasMaximum;
@property(nonatomic) BOOL hasMinimum; // @synthesize hasMinimum=_hasMinimum;
@property(readonly, nonatomic) MSUpDownController *upDownController; // @synthesize upDownController=_upDownController;
@property(nonatomic) __weak id refreshDelegate; // @synthesize refreshDelegate=_refreshDelegate;
- (id)makeTouchBar;
- (void)textDidEndEditing:(id)arg1;
- (BOOL)becomeFirstResponder;
- (BOOL)textView:(id)arg1 shouldChangeTextInRanges:(id)arg2 replacementStrings:(id)arg3;
- (void)textDidChange:(id)arg1;
- (BOOL)textView:(id)arg1 doCommandBySelector:(SEL)arg2;
- (void)keyUp:(id)arg1;
- (id)maximum;
- (id)minimum;
- (double)incrementValue;
- (void)awakeFromNib;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) Class superclass;

@end

