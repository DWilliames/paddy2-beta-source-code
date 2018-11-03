//
//  PaddyBenchmark.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyBenchmark.h"

@interface PaddyBenchmark ()

@property (nonatomic) NSTimeInterval time;
@property (nonatomic, strong) NSString *label;

@property (nonatomic) NSTimeInterval lastIntermittentTime;
@property (nonatomic, strong) NSMutableArray *intermittentTimes;

@end

@implementation PaddyBenchmark

+ (id)benchmark {
    return [[PaddyBenchmark alloc] initWithLabel:@"Benchmark"];
}

+ (id)benchmark:(NSString*)label {
    return [[PaddyBenchmark alloc] initWithLabel:label];
}

- (id)initWithLabel:(NSString*)label {
    self = [super init];
    
    self.time = [[NSDate date] timeIntervalSince1970];
    self.label = label;
    
    self.intermittentTimes = [NSMutableArray array];
    self.lastIntermittentTime = self.time;
    
    return self;
}


- (void)logIntermittent:(NSString*)label {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval diff = (now - self.lastIntermittentTime) * 1000;
    
    [self.intermittentTimes addObject:[NSString stringWithFormat:@"%@: %.4gms", label, diff]];
    self.lastIntermittentTime = now;
}

- (void)logIntermittent {
    [self logIntermittent:[NSString stringWithFormat:@"%lu", self.intermittentTimes.count + 1]];
}

- (void)logEnd {
    double time = [self end];
    
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@: %.4gms", self.label, time];
    
    for (NSString *intermittentTime in self.intermittentTimes) {
        [string appendFormat:@"\n\t%@", intermittentTime];
    }
    
    
    if (!PRODUCTION && BENCHMARKING_ENABLED) {
//        [PaddyManager log:@"%@", string];
        NSLog(@"%@", string);
    }
}

- (double)end {
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval diff = (now - self.time);
    
    return (diff * 1000);
}


@end
