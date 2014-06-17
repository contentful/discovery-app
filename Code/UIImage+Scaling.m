//
//  UIImage+Scaling.m
//  Discovery
//
//  Created by Boris Bügling on 17/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "UIImage+Scaling.h"

@implementation UIImage (Scaling)

+(UIImage*)cda_imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
