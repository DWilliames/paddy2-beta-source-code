//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@interface MSLayerFlattener : NSObject
{
}

- (id)exportRequestFromLayers:(id)arg1 immutablePage:(id)arg2 immutableDoc:(id)arg3;
- (struct CGRect)trimRectFromLayers:(id)arg1 immutablePage:(id)arg2 immutableDoc:(id)arg3;
- (struct CGRect)rectFromLayers:(id)arg1;
- (id)bitmapFromRect:(struct CGRect)arg1 fromLayers:(id)arg2 withImage:(id)arg3;
- (struct CGRect)trimmedRectFromLayers:(id)arg1 immutablePage:(id)arg2 immutableDoc:(id)arg3;
- (id)imageFromLayers:(id)arg1 immutablePage:(id)arg2 immutableDoc:(id)arg3;
- (void)flattenLayers:(id)arg1;

@end

