//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSDate, NSDictionary, NSString, NSURL;

@interface MSCloudShare : NSObject
{
    BOOL _commentsEnabled;
    BOOL _isPrivate;
    NSString *_identifier;
    NSString *_shortID;
    NSString *_userID;
    NSString *_name;
    NSURL *_publicURL;
    NSDate *_creationDate;
    NSDate *_updatedDate;
}

@property(readonly, nonatomic) BOOL isPrivate; // @synthesize isPrivate=_isPrivate;
@property(readonly, nonatomic) BOOL commentsEnabled; // @synthesize commentsEnabled=_commentsEnabled;
@property(retain, nonatomic) NSDate *updatedDate; // @synthesize updatedDate=_updatedDate;
@property(retain, nonatomic) NSDate *creationDate; // @synthesize creationDate=_creationDate;
@property(readonly, nonatomic) NSURL *publicURL; // @synthesize publicURL=_publicURL;
@property(readonly, copy, nonatomic) NSString *name; // @synthesize name=_name;
@property(readonly, nonatomic) NSString *userID; // @synthesize userID=_userID;
@property(readonly, nonatomic) NSString *shortID; // @synthesize shortID=_shortID;
@property(readonly, nonatomic) NSString *identifier; // @synthesize identifier=_identifier;
- (void).cxx_destruct;
- (unsigned long long)hash;
- (BOOL)isEqual:(id)arg1;
@property(readonly, nonatomic) NSString *localizedUpdatedTimeComponentsString;
- (void)applyDictionary:(id)arg1;
- (id)dateFormatter;
@property(readonly, nonatomic) NSDictionary *dictionaryRepresentation;
- (id)initWithDictionary:(id)arg1;

@end

