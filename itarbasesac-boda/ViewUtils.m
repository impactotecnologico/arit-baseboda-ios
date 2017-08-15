//
//  ViewUtils.m
//  itarbasesac-boda
//
//  Created by Roysbert Salinas on 14/8/17.
//  Copyright © 2017 Luis Martinell Andreu. All rights reserved.
//

#import "ViewUtils.h"

@implementation ViewUtils


+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    if ([hexString characterAtIndex:0] == '#')
        [scanner setScanLocation:1]; // bypass '#' character
    
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
