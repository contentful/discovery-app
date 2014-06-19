//
//  UIFont+Contentful.m
//  Discovery
//
//  Created by Boris Bügling on 19/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <objc/runtime.h>

#import <OpenSans/UIFont+OpenSans.h>

#import "UIFont+Contentful.h"

@implementation UIFont (Contentful)

+(UIFont *)boldContentfulFontOfSize:(CGFloat)fontSize {
    return [self openSansBoldFontOfSize:fontSize];
}

+(UIFont *)contentfulFontOfSize:(CGFloat)fontSize {
    return [self openSansFontOfSize:fontSize];
}

+(UIFont *)fontWithNameContentful:(NSString *)name size:(CGFloat)fontSize {
    return [self fontWithNameContentful:@"Open Sans" size:fontSize];
}

+(UIFont *)italicContentfulFontOfSize:(CGFloat)fontSize {
    return [self openSansItalicFontOfSize:fontSize];
}

+(void)load {
    [self swizzleSelector:@selector(boldSystemFontOfSize:)
             withSelector:@selector(boldContentfulFontOfSize:)];
    [self swizzleSelector:@selector(fontWithName:size:)
             withSelector:@selector(fontWithNameContentful:size:)];
    [self swizzleSelector:@selector(italicSystemFontOfSize:)
             withSelector:@selector(italicContentfulFontOfSize:)];
    [self swizzleSelector:@selector(systemFontOfSize:) withSelector:@selector(contentfulFontOfSize:)];
}

+(void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)overrideSelector {
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method overrideMethod = class_getClassMethod(self, overrideSelector);
    method_exchangeImplementations(originalMethod, overrideMethod);
}



@end
