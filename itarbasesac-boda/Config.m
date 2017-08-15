//
//  Config.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 10/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "Config.h"

@interface Config()

@end

@implementation Config

@synthesize items;
@synthesize imagesAR;
@synthesize videosAR;
@synthesize minis;


-(void) makeDirectoryWithPath: (NSString*) path
{
    
}

-(NSString*) pathARResource: (NSString*) nameResource
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [self arMobileDirectory]];
    
    NSError *error;
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    
    return [NSString stringWithFormat:@"%@/%@", path, nameResource];
}

+(Config*) makeWith: (NSDictionary*) data
{
    if (data)
    {
        Config* config = [[Config alloc] init];
        
        [config setTitulo:[data objectForKey:@"titulo"]];
        
        /*
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd yyyy HH:mm:ss ZZZZ"];
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMTZZ"];
        [dateFormatter setTimeZone:gmt];
        
        NSString* dates = [dateFormatter stringFromDate:[[NSDate alloc] init]];
        
        NSDate* date = [dateFormatter dateFromString:dates];
        NSLog(date);
        [config setFecha:[dateFormatter dateFromString:[data objectForKey:@"fecha"]]];
        */
        [config setFechaTexto: [data objectForKey:@"fecha_texto"]];
        [config setColor: [data objectForKey:@"color"]];
        [config setColorRosa: [data objectForKey:@"colorRosa"]];
        [config setIniciales: [data objectForKey:@"iniciales"]];
        [config setShutdown: (NSNumber*) [data objectForKey:@"shutdown"]];
        [config setUrlBase: [data objectForKey:@"urlBase"]];
        [config setDelay: (NSNumber*) [data objectForKey:@"delay"]];
        [config setArCollection: [data objectForKey:@"arCollection"]];
        [config setArMobileDirectory: [data objectForKey:@"arMobileDirectory"]];
        
        [config setItems: [data objectForKey:@"items"]];
        [config setImagesAR: [data objectForKey:@"imagesAR"]];
        [config setVideosAR: [data objectForKey:@"videosAR"]];
        [config setMinis: [data objectForKey:@"minis"]];
        
        return config;
    }
    else
    {
        NSLog(@"Error Config.LoadWithData nil.");
    }
    return nil;
}

@end
