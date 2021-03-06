//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSBezierPath;

@interface FBBezierOperationChainOperand : NSObject
{
    int _operation;
    NSBezierPath *_path;
}

+ (id)operandWithMomento:(id)arg1;
+ (id)operandWithOperation:(int)arg1 path:(id)arg2;
@property(readonly, nonatomic) NSBezierPath *path; // @synthesize path=_path;
@property(readonly, nonatomic) int operation; // @synthesize operation=_operation;
- (void).cxx_destruct;
- (id)momento;
- (id)initWithMomento:(id)arg1;
- (id)initWithOperation:(int)arg1 path:(id)arg2;

@end

