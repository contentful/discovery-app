//
//  UIDevice+BBU.h
//  Slope
//
//  Created by Boris Bügling on 05.01.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BBUDeviceType) {
    BBUDeviceTypePad,
    BBUDeviceTypePadRetina,
    BBUDeviceTypePhone,
    BBUDeviceTypePhoneRetina,
    BBUDeviceTypePhoneRetina4,
    BBUDeviceTypeUnknown,
};

@interface UIDevice (BBU)

+(BBUDeviceType)bbu_type;
+(NSString*)bbu_typeString;

@end
