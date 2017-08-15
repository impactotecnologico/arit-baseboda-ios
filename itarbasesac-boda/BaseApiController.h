//
//  BaseApiController.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 12/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseApiController : NSObject

-(void) getJSONWithBase: (NSString* _Nullable) host
            thisService: (NSString* _Nonnull) action
             withMethod: (NSString* _Nullable) method
              onSuccess: (void(^_Nonnull)(NSDictionary* _Nullable data)) successHandler
                onError: (void(^_Nonnull)(NSError * _Nullable error)) errorHandler;

-(void) getDataWithBase: (NSString* _Nullable) host
            thisService: (NSString* _Nonnull) action
              onSuccess: (void(^_Nonnull)(NSData * _Nullable data)) successHandler
                onError: (void(^_Nonnull)(NSError * _Nullable error)) errorHandler;

@end
