//
//  UIDevice+BBU.m
//  Slope
//
//  Created by Boris Bügling on 05.01.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "UIDevice+BBU.h"

static const CGFloat kPhoneHeight = 480.0;

@implementation UIDevice (BBU)

+(BBUDeviceType)bbu_type {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIScreen mainScreen].scale > 1 ? BBUDeviceTypePadRetina : BBUDeviceTypePad;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (MAX(screenSize.width, screenSize.height) > kPhoneHeight) {
            return BBUDeviceTypePhoneRetina4;
        }
        
        return [UIScreen mainScreen].scale > 1 ? BBUDeviceTypePhoneRetina : BBUDeviceTypePhone;
    }
    
    return BBUDeviceTypeUnknown;
}

+(NSString*)bbu_typeString {
    switch ([self bbu_type]) {
        case BBUDeviceTypePad:
            return @"BBUDeviceTypePad";
        case BBUDeviceTypePadRetina:
            return @"BBUDeviceTypePadRetina";
        case BBUDeviceTypePhone:
            return @"BBUDeviceTypePhone";
        case BBUDeviceTypePhoneRetina:
            return @"BBUDeviceTypePhoneRetina";
        case BBUDeviceTypePhoneRetina4:
            return @"BBUDeviceTypePhoneRetina4";
        default:
            break;
    }
    
    return @"BBUDeviceTypeUnknown";
}

@end
