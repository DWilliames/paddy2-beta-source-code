//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "_MSImmutableShapePath.h"

#import "MSShapePath.h"

@interface MSImmutableShapePath : _MSImmutableShapePath <MSShapePath>
{
}

- (void)migratePropertiesFromV87OrEarlierWithCoder:(id)arg1;
@property(readonly, nonatomic) unsigned long long numberOfPoints;
@property(readonly, nonatomic) BOOL isRectangle;
@property(readonly, nonatomic) BOOL isPolyline;
@property(readonly, nonatomic) BOOL isPolygon;
- (id)bezierPathInRect:(struct CGRect)arg1;
- (id)pathInRect:(struct CGRect)arg1;
@property(readonly, nonatomic) BOOL isSVGRectangle;

@end

