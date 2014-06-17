//
//  CDAAssetThumbnailOperation.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>

#import "CDAAssetPreviewController.h"
#import "CDAAssetThumbnailOperation.h"
#import "UIImage+AverageColor.h"
#import "UIImage+Scaling.h"

@interface CDAAssetThumbnailOperation () <CDAAssetPreviewControllerDelegate> {
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic) CDAAsset* asset;
@property (nonatomic) CDAAssetPreviewController* previewController;
@property (nonatomic) UIImage* snapshot;
@property (nonatomic) CGSize thumbnailSize;

@end

#pragma mark -

@implementation CDAAssetThumbnailOperation

+(NSDictionary*)fileTypeMap {
    static dispatch_once_t once;
    static NSDictionary* fileTypeMap;
    dispatch_once(&once, ^ {
        NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fileGroups"
                                                                                      ofType:@"json"]];
        NSError* error;
        NSDictionary* map = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (!map) {
            NSLog(@"Error reading fileGroups.json: %@", error);
            return;
        }
        
        NSMutableDictionary* mutableFileTypeMap = [@{} mutableCopy];
        
        [map enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* fileTypes, BOOL *stop) {
            NSArray* types = [fileTypes valueForKeyPath:@"type"];
            mutableFileTypeMap[key] = types;
        }];
        
        fileTypeMap = [mutableFileTypeMap copy];
    });
    return fileTypeMap;
}

+(NSString*)imageNameForMimeType:(NSString*)mimeType {
    __block NSString* imageName = @"attachment";
    
    [[self fileTypeMap] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* types, BOOL *stop) {
        if ([types containsObject:mimeType]) {
            imageName = key;
        }
    }];
    
    return imageName;
}

#pragma mark -

-(void)finish {
    self.previewController = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

-(id)initWithAsset:(CDAAsset*)asset thumbnailSize:(CGSize)thumbnailSize {
    self = [super init];
    if (self) {
        self.asset = asset;
        self.thumbnailSize = thumbnailSize;
        
        _isExecuting = NO;
        _isFinished = NO;
    }
    return self;
}

-(BOOL)isConcurrent {
    return YES;
}

-(BOOL)isExecuting {
    return _isExecuting;
}

-(BOOL)isFinished {
    return _isFinished;
}

-(UIImage *)snapshot {
    if (!_snapshot || [_snapshot isBlack]) {
        NSString* imageName = [[self class] imageNameForMimeType:self.asset.MIMEType];
        UIImage* image = [UIImage imageNamed:imageName];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        image = [UIImage cda_imageWithImage:image scaledToSize:CGSizeMake(40.0 * scale, 40.0 * scale)];
        image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
        
        return image;
    }
    
    return _snapshot;
}

-(UIImage *)snapshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (![CDAAssetPreviewController shouldHandleAsset:self.asset]) {
        [self finish];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewController = [[CDAAssetPreviewController alloc] initWithAsset:self.asset];
        self.previewController.previewDelegate = self;
        self.previewController.view.frame = CGRectMake(0.0, 0.0,
                                                       self.thumbnailSize.width,
                                                       self.thumbnailSize.height);
        [self.previewController viewWillAppear:NO];
    });
}

#pragma mark - CDAAssetPreviewControllerDelegate

-(void)assetPreviewControllerDidLoadAssetPreview:(CDAAssetPreviewController *)assetPreviewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       self.snapshot = [self snapshot:assetPreviewController.view];
                       
                       [self finish];
                   });
}

@end
