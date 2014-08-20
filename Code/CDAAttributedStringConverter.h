//
//  CDAAttributedStringConverter.h
//  Discovery
//
//  Created by Boris Bügling on 19/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Bypass/Bypass.h>

@class CDAAttributedStringConverter;

typedef void(^CDAInlineImagesFetchedHandler)(CDAAttributedStringConverter* converter, NSError* error);

@interface CDAInlineAsset : NSObject

@property (nonatomic) UIImage* image;
@property (nonatomic) NSRange range;
@property (nonatomic) NSURL* url;

@end

#pragma mark -

@interface CDAAttributedStringConverter : BPAttributedStringConverter

@property (nonatomic, readonly) NSArray* inlineAssets;

-(void)fetchInlineAssetsFromDocument:(BPDocument*)document
               withCompletionHandler:(CDAInlineImagesFetchedHandler)handler;

@end
