//
//  CDAAssetPreviewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAssetPreviewController.h"

extern NSString* CDACacheFileNameForResource(CDAResource* resource);

@interface CDAAssetPreviewItem : NSObject <QLPreviewItem>

@property (nonatomic) NSString* title;
@property (nonatomic) NSURL* url;

@end

#pragma mark -

@implementation CDAAssetPreviewItem

-(id)initWithTitle:(NSString*)title URL:(NSURL*)url {
    self = [super init];
    if (self) {
        self.title = title;
        self.url = url;
    }
    return self;
}

-(NSString *)previewItemTitle {
    return self.title;
}

-(NSURL *)previewItemURL {
    return self.url;
}

@end

#pragma mark -

@interface CDAAssetPreviewController () <QLPreviewControllerDataSource>

@property (nonatomic) UIActivityIndicatorView* activity;
@property (nonatomic) CDAAsset* asset;
@property (nonatomic) UIView* backgroundView;
@property (nonatomic, readonly) NSURL* localURL;

@end

#pragma mark -

@implementation CDAAssetPreviewController

+(BOOL)shouldHandleAsset:(CDAAsset*)asset {
    // Asset previews do not work reliably at the moment, so...
    return NO;
}

#pragma mark -

-(void)finishLoading {
    [self.activity removeFromSuperview];
    [self.backgroundView removeFromSuperview];

    [self reloadData];
    
    if (self.previewDelegate) {
        [self.previewDelegate assetPreviewControllerDidLoadAssetPreview:self];
    }
}

-(id)initWithAsset:(CDAAsset*)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        self.dataSource = self;
    }
    return self;
}

-(NSURL *)localURL {
    return [NSURL fileURLWithPath:CDACacheFileNameForResource(self.asset)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.view bringSubviewToFront:self.activity];
    [self.activity startAnimating];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 44) / 2, (self.view.bounds.size.height - 44) / 2, 44.0, 44.0)];
    self.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:self.activity];
    
    if ([self.localURL checkResourceIsReachableAndReturnError:nil]) {
        [self finishLoading];
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.asset.URL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               [self.activity stopAnimating];

                               if (data) {
                                   [data writeToURL:self.localURL atomically:YES];
                                   
                                   [self finishLoading];
                               } else {
                                   UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:connectionError.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                                   [alert show];
                               }
                           }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.backgroundView atIndex:0];
}

#pragma mark - QLPreviewControllerDataSource

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [self.localURL checkResourceIsReachableAndReturnError:nil] ? 1 : 0;
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                   previewItemAtIndex:(NSInteger)index {
    return [[CDAAssetPreviewItem alloc] initWithTitle:self.asset.fields[@"title"] URL:self.localURL];
}

@end
