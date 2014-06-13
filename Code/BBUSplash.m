//
//  BBUSplash.m
//  Slope
//
//  Created by Boris Bügling on 05.01.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "BBUSplash.h"
#import "UIDevice+BBU.h"
#import "UIView+Geometry.h"

@implementation BBUSplash

+(void)hideAnimated:(BOOL)animated {
    UIView* frontmostView = [[[UIApplication sharedApplication] keyWindow].subviews lastObject];
    if (![frontmostView isKindOfClass:[self class]]) {
        return;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            frontmostView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [frontmostView removeFromSuperview];
            }
        }];
    } else {
        [frontmostView removeFromSuperview];
    }
}

+(BOOL)isVisible {
    UIView* frontmostView = [[[UIApplication sharedApplication] keyWindow].subviews lastObject];
    return [frontmostView isKindOfClass:[self class]];
}

+(UIImage*)launchImage {
    switch ([UIDevice bbu_type]) {
        case BBUDeviceTypePad:
        case BBUDeviceTypePadRetina:
            return [self launchImagePad];
        case BBUDeviceTypePhoneRetina4:
            return [UIImage imageNamed:@"LaunchImage-700-568h"];
        default:
            break;
    }
    
    return [UIImage imageNamed:@"LaunchImage-700"];
}

+(UIImage*)launchImagePad {
    switch ([self orientation]) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return [UIImage imageNamed:@"LaunchImage-Landscape"];
        default:
            break;
    }
    
    return [UIImage imageNamed:@"LaunchImage-Portrait"];
}

+(UIInterfaceOrientation)orientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

+(void)showAnimated:(BOOL)animated {
    UIView* splashImageView = [[[self class] alloc] init];
    splashImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[[UIApplication sharedApplication] keyWindow] addSubview:splashImageView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape([self orientation])) {
            CGFloat angle = ([self orientation] == UIInterfaceOrientationLandscapeRight) ? 90.0 : -90.0;
            splashImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0));
            CGFloat x = ([self orientation] == UIInterfaceOrientationLandscapeRight) ? 0.0 : 20.0;
            splashImageView.frame = CGRectMake(x, 0.0, 748.0, 1024.0);
        }
        
        if ([self orientation] == UIInterfaceOrientationPortrait) {
            splashImageView.y += 20.0;
        }
        
        if ([self orientation] == UIInterfaceOrientationPortraitUpsideDown) {
            splashImageView.transform = CGAffineTransformMakeRotation(180.0 * (M_PI / 180.0));
        }
    }
    
    if (animated) {
        splashImageView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            splashImageView.alpha = 1.0;
        }];
    }
}

#pragma mark - 

-(id)init {
    self = [super initWithImage:[[self class] launchImage]];
    return self;
}

@end
