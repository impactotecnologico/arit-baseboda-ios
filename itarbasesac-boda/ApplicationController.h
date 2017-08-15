//
//  ApplicationController.h
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 12/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "Scene.h"
@interface ApplicationController : NSObject 

- (void) getConfigOnSuccess:(void(^)(Config*)) handler;
- (void) getResourcesAndStore:(void(^)(NSString* message, float percent)) handler callback: (void(^)()) onFinished;
- (Scene*) getSceneAt: (int) index ofType: (TypeContent) type;

+(ApplicationController*) Instance;
@end
