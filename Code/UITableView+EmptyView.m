//
//  UITableView+EmptyView.m
//  Discovery
//
//  Created by Boris Bügling on 13/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <objc/runtime.h>

#import <Aspects/Aspects.h>

#import "UITableView+EmptyView.h"
#import "UIView+Geometry.h"

static const char* CDALoadingKey = "CDALoadingKey";

@implementation UITableView (EmptyView)

@dynamic loading_cda;

#pragma mark -

-(void)cda_onEmptynessShowLabelWithTitle:(NSString*)title beforeBlock:(void (^)())before {
    UILabel* emptynessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    emptynessLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    emptynessLabel.font = [UIFont boldSystemFontOfSize:20.0];
    emptynessLabel.hidden = YES;
    emptynessLabel.text = title;
    emptynessLabel.textAlignment = NSTextAlignmentCenter;
    
    UIActivityIndicatorView* loadingIndicator = [[UIActivityIndicatorView alloc]
                                                 initWithFrame:CGRectZero];
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    loadingIndicator.color = [UIColor blackColor];
    [loadingIndicator startAnimating];
    
    UIView* emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    [emptyView addSubview:emptynessLabel];
    [emptyView addSubview:loadingIndicator];
    
    self.nxEV_emptyView = emptyView;
    
    NSError* error;
    
    id<AspectToken> token = [self aspect_hookSelector:@selector(reloadData) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        if (before) {
            before();
        }
        
        if ([self numberOfRowsInSection:0] == 0) {
            self.separatorStyle = UITableViewCellSeparatorStyleNone;
        } else {
            self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        
        emptynessLabel.hidden = self.loading_cda;
        emptynessLabel.frame = emptyView.bounds;
        
        loadingIndicator.hidden = !self.loading_cda;
        loadingIndicator.size = CGSizeMake(100.0, 100.0);
        loadingIndicator.x = (emptyView.width - loadingIndicator.width) / 2;
        loadingIndicator.y = (emptyView.height - loadingIndicator.height) / 2;
    } error:&error];
    
    if (!token) {
        NSLog(@"Could not hook tableView:numberOfRowsInSection: because of %@", error);
    }
}

#pragma mark - Properties

-(BOOL)loading_cda {
    NSNumber* loading = objc_getAssociatedObject(self, CDALoadingKey);
    return [loading boolValue];
}

-(void)setLoading_cda:(BOOL)loading {
    objc_setAssociatedObject(self, CDALoadingKey, [NSNumber numberWithBool:loading],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
