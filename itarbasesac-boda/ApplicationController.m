//
//  ApplicationController.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 12/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "ApplicationController.h"
#import "BaseApiController.h"
#import "AppDelegate.h"
#import "Domains.h"
#import "NSArray.h"

@interface ApplicationController()

@property BaseApiController* client;
@property Config* config;
@property NSMutableDictionary* scenesImage;
@property NSMutableDictionary* scenesVideo;

@end

@implementation ApplicationController

@synthesize client;
@synthesize config;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.client = [[BaseApiController alloc] init];
        self.scenesImage = [[NSMutableDictionary alloc] init];
        self.scenesVideo = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (Scene*) getSceneAt: (int) index ofType: (TypeContent) type
{
    Scene* scene = nil;
    NSMutableDictionary* resources;
    switch (type) {
        case TypeContentImage:
            resources = [self scenesImage];
            break;
        case TypeContentVideo:
            resources = [self scenesVideo];
            break;
        default:
            break;
    }
    
    id resource = [resources objectForKey: [NSString stringWithFormat:@"%d",index]];
    
    if (resource)
    {
        scene = (Scene*) resource;
    }
    
    if (scene == nil)
    {
        scene = [Scene makeSceneAt:index ofType:type];
        [resources setValue:scene forKey: [NSString stringWithFormat:@"%d",index]];
    }
    
    return scene;
}

+ (ApplicationController*) Instance
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate controller] == nil)
    {
        [appDelegate setController: [[ApplicationController alloc] init]];
    }
    return [appDelegate controller];
}

- (void) getConfigOnSuccess:(void(^)(Config*)) handler
{
    
    if ([self config])
    {
        handler(config);
    }
    else
    {
        [[self client] getJSONWithBase: [config urlBase]
                           thisService: @"config.json"
                            withMethod: @"GET"
                             onSuccess:^(NSDictionary * _Nullable data) {
                                 [self setConfig: [Config makeWith: data]];

                                 handler([self config]);
                             }
                               onError:^(NSError * _Nullable error) {
                                   NSLog(@"Get Config error: %@", error);
                               }];
    }
}

- (void) getResourcesAndStore:(void(^)(NSString* message, float percent)) handler callback: (void(^)()) onFinished
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        float total = 0;
        
        NSArray* infos = [[[self config] imagesAR] mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            return [NSString stringWithFormat:@"info%d.png", idx+1];
        }];
        
        NSArray* collectionResources = @[
            [[self config] minis],
            [[self config] imagesAR],
            infos,
            [[self config] videosAR]
        ];
        
        for (NSArray* resources in collectionResources) {
            total = total + [resources count];
        }
        
        float improvement = 100 / (total * 2);
        __block float percent = 0;
        
        for (NSArray* resources in collectionResources) {
            for (NSString* nameResource in resources)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(@"Downloading resource...", percent);
                });
                BOOL isDir;
                NSString *filePath = [[self config] pathARResource: nameResource];
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
                {
                    [client getDataWithBase: [[self config] urlBase]
                                thisService: nameResource
                                  onSuccess:^(NSData * _Nullable data)
                     {
                         percent = percent + improvement;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             handler(@"Saving resource...", percent);
                         });
                         if (data)
                         {
                             
                             percent = percent + improvement;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [data writeToFile:filePath atomically:YES];
                             });
                             
                         }
                     }
                                    onError:^(NSError * _Nullable error)
                     {
                         NSLog(@"Error on get and store resource: %@.", nameResource);
                         percent = percent + improvement*2;
                     }];
                }
                else
                {
                    percent = percent + improvement*2;
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(@"Finished.", percent);
            onFinished();
        });
    });
}

@end
