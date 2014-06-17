//
//  CDAWebController.m
//  Discovery
//
//  Created by Boris Bügling on 11/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAWebController.h"
#import "UIView+Geometry.h"

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

#pragma UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)_webView {
    [super webViewDidFinishLoad:_webView];

    self.view.y = 20.0;
}

@end
