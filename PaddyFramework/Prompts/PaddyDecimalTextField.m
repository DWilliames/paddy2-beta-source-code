//
//  PaddyDecimalTextField.m
//  PaddyFramework
//
//  Created by David Williames on 9/7/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyDecimalTextField.h"

@implementation PaddyDecimalTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    
    // Filter the characters to only be decimal characters
    static NSCharacterSet *nonDecimalCharacters = nil;
    if (!nonDecimalCharacters) {
        nonDecimalCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] invertedSet];
    }
    
    NSString *filtered = [[self.stringValue componentsSeparatedByCharactersInSet:nonDecimalCharacters] componentsJoinedByString:@""];
    
    
    // Make sure we only have one decimal place
    NSArray *split = [filtered componentsSeparatedByString:@"."];
    
    NSMutableString *newValue = [NSMutableString string];
    for (int i = 0; i < split.count; i ++) {
        [newValue appendString:split[i]];
        if (i < 1 && split.count > 1) {
            [newValue appendString:@"."];
        }
    }
    
    self.stringValue = newValue;
}

@end
