//
//  PaddyNameReader.m
//  PaddyFramework
//
//  Created by David Williames on 12/6/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyNameReader.h"

@interface PaddyNameReader ()

@property (nonatomic, strong) MSLayer *layer;

@property (nonatomic, strong) NSArray *alignments;
@property (nonatomic, strong) PaddyModelStack *stackProperties;
@property (nonatomic, strong) PaddyModelPadding *paddingProperties;

@property (nonatomic) BOOL shouldIgnore;

@end

@implementation PaddyNameReader

+ (PaddyNameReader*)readFromLayer:(MSLayer*)layer {
    return [[PaddyNameReader alloc] initWithLayer:layer];
}


- (id)initWithLayer:(MSLayer*)layer {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.layer = layer;
    
    return [self refreshInfo] ? self : nil;
}

- (BOOL)refreshInfo {
    NSTextCheckingResult *matchedInfo = [self getInfoFromName];
    
    self.stackProperties = nil;
    self.paddingProperties = nil;
    self.alignments = @[];
    
    self.shouldIgnore = self.layer.name.length > 0 && [[self.layer.name substringToIndex:1] isEqualToString:@"-"];
    
    if (matchedInfo) {
        
        NSRange matchRange = [matchedInfo rangeAtIndex:1];
        NSString *matchString = [[self.layer.name substringWithRange:matchRange] lowercaseString];
        
        if (matchString.length < 1) {
            return false;
        }
        
        if ([PaddyClass is:self.layer instanceOf:Group]) {
            [self updateGroupWithString:matchString];
        } else {
            self.paddingProperties = [PaddyModelPadding paddingFromString:matchString];
        }
        
        return true;
    }
    
    return false;
}

- (NSTextCheckingResult*)getInfoFromName {
    
    NSString *name = self.layer.name;
    
    // Override values from name
    NSString *regexPattern = @".*\\[(.*?)\\]";
    
    NSError *regError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:NSRegularExpressionCaseInsensitive error:&regError];
    if (regError) {
        [PaddyManager log:@"%@", regError.localizedDescription];
    }
    
    NSArray *matches = [regex matchesInString:name options:kNilOptions range:NSMakeRange(0, name.length)];
    if (matches.count > 0) {
        return [matches firstObject];
    } else {
        return nil;
    }
}


- (void)updateGroupWithString:(NSString*)string {
    
    // Split by ';'
    // For each split;
    // GROUP; either padding or spacing
    
    NSMutableArray *strings = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@";"]];
    
    if (strings.count < 1) {
        return;
    }
    
    // Get spacing from string
    NSMutableArray *values = [NSMutableArray arrayWithArray:[strings[0] componentsSeparatedByString:@" "]];
    
    NSString *spacingLayout = [values firstObject];
    // Last character of the first word
    NSString *layout = spacingLayout.length > 0 ? [spacingLayout substringFromIndex:spacingLayout.length - 1] : @"";
    
    PaddyOrientation orientation = [PaddyModelOrientation orientationFromString:layout];
    if (orientation != NoOrientation) {
        
        NSString *space = [spacingLayout substringToIndex:spacingLayout.length - 1];
        double spacing = [space doubleValue];
        [values removeObjectAtIndex:0];
        
        self.stackProperties = [PaddyModelStack stackOrientation:orientation withSpacing:spacing];
    }
    
    NSMutableArray *alignments = [NSMutableArray array];
    for (NSString *alignmentValue in values) {
        
        PaddyAlignment alignment = [PaddyModelAlignment alignmentFromString:alignmentValue];
        if (alignment != NoAlignment) {
            [alignments addObject:@(alignment)];
        }
    }
    
    self.alignments = alignments;
    
    if (strings.count > 1) {
        self.paddingProperties = [PaddyModelPadding paddingFromString:strings[1]];
    }
}

@end
