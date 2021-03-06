//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

#import "MSAllRenderers.h"

@class NSString;

@interface MSOptionalRenderer : NSObject <MSAllRenderers>
{
    id _baseRenderer;
    id _nullRenderer;
    NSString *_disableSetting;
}

@property(retain, nonatomic) NSString *disableSetting; // @synthesize disableSetting=_disableSetting;
@property(retain, nonatomic) id nullRenderer; // @synthesize nullRenderer=_nullRenderer;
@property(retain, nonatomic) id baseRenderer; // @synthesize baseRenderer=_baseRenderer;
- (void).cxx_destruct;
@property(readonly, nonatomic) BOOL enabled;
- (id)forwardingTargetForSelector:(SEL)arg1;
- (id)initWithBaseRenderer:(id)arg1 disableSetting:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

