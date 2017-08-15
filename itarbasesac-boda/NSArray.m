//
//  NSArray.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 15/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "NSArray.h"

@implementation NSArray (Map)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end
