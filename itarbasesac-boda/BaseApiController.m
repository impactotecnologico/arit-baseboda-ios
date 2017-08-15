//
//  BaseApiController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 12/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "BaseApiController.h"
#import <Pods/AFNetworking.h>

@interface BaseApiController()

@property NSString* baseUrl;

@end

@implementation BaseApiController
@synthesize baseUrl;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBaseUrl:@"http://technoimpact.net/"];
    }
    return self;
}

-(NSURL*) makeUrlWithBase: (NSString* _Nullable) host
              thisService: (NSString* _Nonnull) action
{
    NSURL *url = nil;
    if (host)
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, action]];
    }
    else
    {
        url = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@", [self baseUrl], action]];
    }
    return url;
}

-(NSMutableURLRequest*) makeRequestWithBase: (NSString* _Nullable) host
                                thisService: (NSString* _Nonnull) action
                                 withMethod: (NSString* _Nullable) method
{
    NSURL *url = [self makeUrlWithBase:host thisService:action];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    if (method)
    {
        request.HTTPMethod = method;
    }
    else
    {
        request.HTTPMethod = @"GET";
    }
    
    return request;
}

-(AFHTTPSessionManager*) makeSessionWithBase: (NSString* _Nullable) host
                                 thisService: (NSString* _Nonnull) action
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURL* url = [self makeUrlWithBase:host thisService:action];
    
    AFHTTPSessionManager* sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:sessionConfiguration];

    return sessionManager;
}

-(void) getJSONWithBase: (NSString* _Nullable) host
            thisService: (NSString* _Nonnull) action
             withMethod: (NSString* _Nullable) method
              onSuccess: (void(^_Nonnull)(NSDictionary* _Nullable data)) successHandler
                onError: (void(^_Nonnull)(NSError * _Nullable error)) errorHandler
{
    NSMutableURLRequest* request = [self makeRequestWithBase:host thisService:action withMethod:method];
    
    AFHTTPSessionManager* sessionManager = [self makeSessionWithBase:host thisService:action];
    [sessionManager setRequestSerializer: [AFJSONRequestSerializer serializer]];
    
    NSURLSessionDataTask* dataTask =
        [sessionManager dataTaskWithRequest:request
                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
    {
        if (!error)
        {
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successHandler((NSDictionary*)responseObject);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorHandler(error);
            });
        }
    }];
    
    [dataTask resume];
}

-(void) getDataWithBase: (NSString* _Nullable) host
             thisService: (NSString* _Nonnull) action
               onSuccess: (void(^_Nonnull)(NSData * _Nullable data)) successHandler
                 onError: (void(^_Nonnull)(NSError * _Nullable error)) errorHandler
{
    NSURL* url = [self makeUrlWithBase:host thisService:action];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if ( data )
    {
        successHandler(data);
    }
    else
    {
        errorHandler([[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:-1 userInfo:@{
            @"message" : @"On get data response is nil..."
        }]);
    }
    
}

@end
