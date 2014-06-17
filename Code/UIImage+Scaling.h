//
//  UIImage+Scaling.h
//  Discovery
//
//  Created by Boris Bügling on 17/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scaling)

+(UIImage*)cda_imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
