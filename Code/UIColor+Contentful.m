//
//  UIColor+Contentful.m
//  Discovery
//
//  Created by Boris Bügling on 19/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "UIColor+Contentful.h"

#define UIColorWithRGB(r, g, b) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1.0]

@implementation UIColor (Contentful)

+(UIColor *)contentfulBlackColor {
    return UIColorWithRGB(0x3B, 0x3B, 0x3B);
}

+(UIColor *)contentfulBlueColor {
    return UIColorWithRGB(0x4D, 0xB5, 0xE2);
}

+(UIColor *)contentfulDarkBlueColor {
    return UIColorWithRGB(0x00, 0x81, 0xB6);
}

+(UIColor *)contentfulDarkRedColor {
    return UIColorWithRGB(0xCD, 0x45, 0x39);
}

+(UIColor *)contentfulRedColor {
    return UIColorWithRGB(0xF0, 0x56, 0x50);
}

+(UIColor *)contentfulYellowColor {
    return UIColorWithRGB(0xFF, 0xEE, 0x00);
}

@end
