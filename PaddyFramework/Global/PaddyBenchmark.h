//
//  PaddyBenchmark.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyBenchmark : NSObject

+ (id)benchmark;
+ (id)benchmark:(NSString*)label;

- (void)logIntermittent:(NSString*)label;
- (void)logIntermittent;

- (void)logEnd;
- (double)end; // Time in Milliseconds


@end
