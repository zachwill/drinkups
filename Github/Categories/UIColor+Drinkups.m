//
//  UIColor+Drinkups.m
//  Github
//
//  Created by Zach Williams on 10/13/12.
//  Copyright (c) 2012 Zach Williams. All rights reserved.
//

#import "UIColor+Drinkups.h"

@implementation UIColor (Drinkups)

+ (UIColor *)gh_backgroundColor {
    return [UIColor colorWithRed:0.773 green:0.784 blue:0.745 alpha:1.000];
}

+ (UIColor *)gh_refreshTintColor {
    return [UIColor colorWithRed:0.631 green:0.647 blue:0.624 alpha:1.000];
}

+ (UIColor *)colorWithHex:(NSString *)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];  

    // Strip 0X if it appears  
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    // String pound sign
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if(cString.length == 3) {
        NSString *first = [cString substringWithRange:NSMakeRange(0, 1)];
        NSString *second = [cString substringWithRange:NSMakeRange(1, 1)];
        NSString *third = [cString substringWithRange:NSMakeRange(2, 1)];
        cString = [NSString stringWithFormat:@"%@%@%@%@%@%@", first, first, second, second, third, third];
    }

    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2;  
    NSString *rString = [cString substringWithRange:range];  

    range.location = 2;  
    NSString *gString = [cString substringWithRange:range];  

    range.location = 4;  
    NSString *bString = [cString substringWithRange:range];  

    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  

    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
}

@end
