//
//  PaddyModelPadding.h
//  PaddyFramework
//
//  Created by David Williames on 2/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

typedef NS_ENUM(NSInteger, PaddyPaddingViewInputCount) {
    AllInputs = 0,
    TwoInputs = 1,
    OneInput = 2
};


@interface PaddyModelPadding : NSObject

@property (nonatomic, readonly) NSNumber *top;
@property (nonatomic, readonly) NSNumber *right;
@property (nonatomic, readonly) NSNumber *bottom;
@property (nonatomic, readonly) NSNumber *left;

@property (nonatomic) BOOL enabled;

@property (nonatomic) PaddyPaddingViewInputCount inputCount;


+ (id)defaultModel;

+ (id)inferFromLayer:(MSLayer*)backgroundLayer;

+ (id)paddingFromString:(NSString*)string;
+ (id)paddingFromDictionary:(NSDictionary*)dictionary;

- (id)initWithTop:(NSNumber*)top right:(NSNumber*)right bottom:(NSNumber*)bottom andLeft:(NSNumber*)left inputCount:(PaddyPaddingViewInputCount)inputCount ;

- (NSString*)propertiesString;

- (NSDictionary*)dictionary;

@end
