//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSSharedObject.h"

@interface MSSharedObject : _MSSharedObject
{
}

- (id)parentGroup;
- (unsigned long long)type;
- (BOOL)isOutOfSyncWithInstance:(id)arg1;
- (id)newInstance;
- (BOOL)isSharedObjectForInstance:(id)arg1;
- (void)unregisterInstance:(id)arg1;
- (void)registerInstance:(id)arg1;
- (void)objectDidInit;
- (id)initWithName:(id)arg1 sharedObjectID:(id)arg2 value:(id)arg3;
- (id)initWithName:(id)arg1 firstInstance:(id)arg2;

@end

