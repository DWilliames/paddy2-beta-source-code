//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "BCPopover.h"

@class MSAction, NSViewController;

@interface BCToolbarPopover : BCPopover
{
    NSViewController *_contentViewController;
    NSViewController *_embeddedContentViewController;
    MSAction *_action;
}

@property(nonatomic) __weak MSAction *action; // @synthesize action=_action;
@property(retain, nonatomic) NSViewController *embeddedContentViewController; // @synthesize embeddedContentViewController=_embeddedContentViewController;
- (void)setContentViewController:(id)arg1;
- (id)contentViewController;
- (void).cxx_destruct;
- (id)contentViewControllerForEmbeddedViewController:(id)arg1;

@end

