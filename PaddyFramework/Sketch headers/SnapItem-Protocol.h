//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

@class NSArray;

@protocol SnapItem <NSObject>
@property(readonly, nonatomic) struct CGRect rectForSnapping;
@property(readonly, nonatomic) id <SnapItem> snapItemForDrawing;
@property(readonly, nonatomic) NSArray *snapLines;
- (struct CGRect)distanceRectangleToItem:(id <SnapItem>)arg1 axis:(unsigned long long)arg2;
@end
