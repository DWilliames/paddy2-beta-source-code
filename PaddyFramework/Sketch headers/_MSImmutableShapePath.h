//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MSImmutableModelObject.h"

@class NSArray;

@interface _MSImmutableShapePath : MSImmutableModelObject
{
    BOOL _isClosed;
    long long _pointRadiusBehaviour;
    NSArray *_points;
}

+ (Class)mutableClass;
@property(retain, nonatomic) NSArray *points; // @synthesize points=_points;
@property(nonatomic) long long pointRadiusBehaviour; // @synthesize pointRadiusBehaviour=_pointRadiusBehaviour;
@property(nonatomic) BOOL isClosed; // @synthesize isClosed=_isClosed;
- (void).cxx_destruct;
- (id)keysDifferingFromObject:(id)arg1;
- (BOOL)isEqualForDiffToObject:(id)arg1;
- (void)initializeUnsetObjectPropertiesWithDefaults;
- (BOOL)hasDefaultValues;
- (void)performInitEmptyObject;
- (void)decodePropertiesWithUnarchiver:(id)arg1;
- (void)encodePropertiesWithCoder:(id)arg1;
- (void)enumerateChildProperties:(CDUnknownBlockType)arg1;
- (void)enumerateProperties:(CDUnknownBlockType)arg1;
- (void)performInitWithMutableModelObject:(id)arg1;

@end

