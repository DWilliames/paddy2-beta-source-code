//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//


@class MSActionController, NSString;

@protocol MSActionObserver <NSObject>
- (void)actionController:(MSActionController *)arg1 didInstantActionWithID:(NSString *)arg2 context:(id)arg3;
- (void)actionController:(MSActionController *)arg1 didFinishActionWithID:(NSString *)arg2 context:(id)arg3;
- (void)actionController:(MSActionController *)arg1 willBeginActionWithID:(NSString *)arg2 context:(id)arg3;
@end

