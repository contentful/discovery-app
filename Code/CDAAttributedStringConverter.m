//
//  CDAAttributedStringConverter.m
//  Discovery
//
//  Created by Boris Bügling on 19/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAAttributedStringConverter.h"

@implementation CDAInlineAsset

@end

#pragma mark -

@interface CDAAttributedStringConverter ()

@property (nonatomic) NSAttributedString* attributedString;
@property (nonatomic) NSArray* inlineAssets;
@property (nonatomic) BPDocument* lastUsedDocument;

@end

#pragma mark -

@implementation CDAAttributedStringConverter

+(UIImage*)imageWithImage:(UIImage *)image fitToHeight:(CGFloat)height {
    CGFloat ratio = image.size.height / height;
    CGFloat width = image.size.width / ratio;
    CGSize size = CGSizeMake(width, height);

    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newimage;
}

#pragma mark -

-(NSAttributedString *)convertDocument:(BPDocument *)document {
    if (document == self.lastUsedDocument) {
        NSMutableAttributedString* mutableString = [self.attributedString mutableCopy];

        [self.inlineAssets enumerateObjectsUsingBlock:^(CDAInlineAsset* asset, NSUInteger idx, BOOL *s) {
            NSAttributedString* imageAttachment = [self fitImageIntoAttributedString:asset.image];
            if (!imageAttachment) {
                return;
            }

            [mutableString replaceCharactersInRange:asset.range withAttributedString:imageAttachment];

            CGFloat offset = asset.range.length - imageAttachment.length;
            for (NSUInteger i = idx + 1; i < self.inlineAssets.count; i++) {
                CDAInlineAsset* someAsset = self.inlineAssets[i];
                someAsset.range = NSMakeRange(someAsset.range.location - offset,
                                              someAsset.range.length);
            }

            asset.range = NSMakeRange(asset.range.location, imageAttachment.length);
        }];

        return [mutableString copy];
    }

    return [super convertDocument:document];
}

-(void)fetchInlineAssetsFromDocument:(BPDocument *)document
               withCompletionHandler:(CDAInlineImagesFetchedHandler)handler {
    self.attributedString = [super convertDocument:document];
    self.lastUsedDocument = document;

    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"!\\[.*?\\]\\((.*?)\\)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];

    if (!regex) {
        if (handler) {
            handler(nil, error);
        }

        return;
    }

    NSMutableArray* inlineAssets = [@[] mutableCopy];
    NSString* string = self.attributedString.string;

    for (NSTextCheckingResult* result in [regex matchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, string.length)]) {
        assert(result.numberOfRanges == 2);

        NSString* urlString = [string substringWithRange:[result rangeAtIndex:1]];

        NSURL* url = nil;
        if ([urlString hasPrefix:@"http"]) {
            url = [NSURL URLWithString:urlString];
        } else {
            url = [NSURL URLWithString:[@"https:" stringByAppendingString:urlString]];
        }

        CDAInlineAsset* asset = [CDAInlineAsset new];
        asset.range = [result rangeAtIndex:0];
        asset.url = url;

        [inlineAssets addObject:asset];
    }

    self.inlineAssets = inlineAssets;
    [self fetchAssetAtIndex:0 withCompletionHandler:handler];
}

-(void)fetchAssetAtIndex:(NSUInteger)index withCompletionHandler:(CDAInlineImagesFetchedHandler)handler {
    if (self.inlineAssets.count == 0 || index >= self.inlineAssets.count) {
        if (handler) {
            handler(self, nil);
        }

        return;
    }

    CDAInlineAsset* currentAsset = self.inlineAssets[index];

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:currentAsset.url]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!data) {
                                   if (handler) {
                                       handler(nil, error);
                                   }

                                   return;
                               }

                               currentAsset.image = [UIImage imageWithData:data];
                               [self fetchAssetAtIndex:(index + 1) withCompletionHandler:handler];
                           }];
}

-(NSAttributedString*)fitImageIntoAttributedString:(UIImage*)image {
    if (!image) {
        return nil;
    }

    image = [[self class] imageWithImage:image fitToHeight:250.0];

    NSTextAttachment* attachment = [NSTextAttachment new];
    attachment.image = image;

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSMutableDictionary *newAttributes = [NSMutableDictionary new];
    [newAttributes setObject:attachment forKey:NSAttachmentAttributeName];
    [newAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];

    NSMutableAttributedString* imageAttachment = [NSMutableAttributedString new];
    [imageAttachment appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:@"\ufffc" attributes:newAttributes]];
    [imageAttachment appendAttributedString:[self horizontalLineAttributedString]];
    [imageAttachment appendAttributedString:[self horizontalLineAttributedString]];

    return imageAttachment;
}

-(NSAttributedString*)horizontalLineAttributedString {
    return [[NSAttributedString alloc] initWithString:@"\n"];
}

@end
