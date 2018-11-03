//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MSUpDownProtocol-Protocol.h"

@class NSArray, MSUpDownTextField;

@interface MSTextLabelForUpDownField : NSTextField
{
    MSUpDownTextField *_upDownTextField;
    NSArray *_textFields;
}

@property(copy, nonatomic) NSArray *textFields; // @synthesize textFields=_textFields;
@property(nonatomic) __weak NSTextField<MSUpDownProtocol> *upDownTextField; // @synthesize upDownTextField=_upDownTextField;
- (BOOL)canScrub;
- (void)mouseDown:(id)arg1;
- (id)textField;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)awakeFromNib;
- (BOOL)clickShouldDismissPopover:(id)arg1;

@end

