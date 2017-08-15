//
//  Scene.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 11/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CraftARAugmentedRealitySDK/CraftARSDK.h>
#import <CraftARAugmentedRealitySDK/CraftARCloudRecognition.h>
#import <CraftARAugmentedRealitySDK/CraftARTracking.h>
#import <CraftARAugmentedRealitySDK/CraftARTrackingContent.h>
#import <CraftARAugmentedRealitySDK/CraftARTrackingContentImage.h>
#import <CraftARAugmentedRealitySDK/CraftARTrackingContentVideo.h>

#import "Domains.h"

@interface Scene : NSObject

@property TypeContent type;
@property int index;
@property CraftARTrackingContent* content;

+(Scene*) makeSceneAt: (int) index ofType: (TypeContent) type;

@end
