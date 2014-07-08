//
//  CDAWebController.m
//  Discovery
//
//  Created by Boris Bügling on 11/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAWebController.h"
#import "UIView+Geometry.h"

@interface CDAWebController ()

@property CGFloat originalHeight;
@property UIView* overlayView;

@end

#pragma mark -

@implementation CDAWebController

-(id)initWithURL:(NSURL *)url {
    self = [super initWithURL:url];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.hideTopBarAndBottomBarOnScrolling = NO;
        self.mode = TSMiniWebBrowserModeNavigation;
        self.showPageTitleOnTitleBar = NO;
        self.showToolBar = NO;
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.overlayView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.originalHeight = self.view.height;
}

#pragma UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)_webView {
    [super webViewDidFinishLoad:_webView];

    [self.overlayView removeFromSuperview];
    self.overlayView = nil;

    self.view.y = 20.0;
    self.view.height = self.originalHeight + 40.0;
}

@end
