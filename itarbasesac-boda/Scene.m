//
//  Scene.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 11/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "Scene.h"
#import "ApplicationController.h"

@interface Scene()

@end

@implementation Scene

+(Scene*) makeSceneAt: (int) index ofType: (TypeContent) type
{
    Scene* scene = [[Scene alloc] init];
    
    [scene setType:type];
    [scene setIndex:index];
    
    [[ApplicationController Instance] getConfigOnSuccess:^(Config * config)
    {
        NSString* nameResource;
        switch (type) {
            case TypeContentImage:
                nameResource = [[config imagesAR] objectAtIndex:index];
                break;
            case TypeContentVideo:
                nameResource = [[config videosAR] objectAtIndex:index];
                break;
            default:
                break;
        }

        NSString* pathResource = [config pathARResource:nameResource];
        NSURL* urlResource = [NSURL fileURLWithPath:pathResource];
        
        switch (type) {
            case TypeContentImage:
                [scene setContent: [[CraftARTrackingContentImage alloc] initWithImageFromURL:urlResource]];
                break;
            case TypeContentVideo:
                [scene setContent: [[CraftARTrackingContentVideo alloc] initWithVideoFrom:urlResource]];
                break;
            default:
                break;
        }
    }];
    
    return scene;
}
@end
