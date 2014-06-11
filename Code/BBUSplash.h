//
//  BBUSplash.h
//  Slope
//
//  Created by Boris Bügling on 05.01.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBUSplash : UIImageView

+(void)hideAnimated:(BOOL)animated;
+(BOOL)isVisible;
+(void)showAnimated:(BOOL)animated;

@end
