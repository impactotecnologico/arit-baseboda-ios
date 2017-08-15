//
//  NSArray.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 15/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Map)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end
