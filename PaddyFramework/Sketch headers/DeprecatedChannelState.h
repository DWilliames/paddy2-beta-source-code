//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class ECLogHandler;

@interface DeprecatedChannelState : NSObject
{
    BOOL _enabled;
    ECLogHandler *_handler;
}

@property(nonatomic) BOOL enabled; // @synthesize enabled=_enabled;
@property(retain, nonatomic) ECLogHandler *handler; // @synthesize handler=_handler;
- (void).cxx_destruct;

@end

