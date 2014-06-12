//
//  UITableView+EmptyView.m
//  Discovery
//
//  Created by Boris Bügling on 13/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Aspects/Aspects.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

#import "UITableView+EmptyView.h"

@implementation UITableView (EmptyView)

-(void)cda_onEmptynessShowLabelWithTitle:(NSString*)title {
    UILabel* emptynessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    emptynessLabel.font = [UIFont boldSystemFontOfSize:20.0];
    emptynessLabel.text = title;
    emptynessLabel.textAlignment = NSTextAlignmentCenter;
    
    self.nxEV_emptyView = emptynessLabel;
    
    NSError* error;
    
    id<AspectToken> token = [(NSObject*)self.delegate aspect_hookSelector:@selector(tableView:numberOfRowsInSection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UITableView* tableView, NSInteger section) {
        NSInteger result = 0;
        [aspectInfo.originalInvocation getReturnValue:&result];
        
        if (result == 0) {
            self.separatorStyle = UITableViewCellSeparatorStyleNone;
        } else {
            self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
    } error:&error];
    
    if (!token) {
        NSLog(@"Could not hook tableView:numberOfRowsInSection: because of %@", error);
    }

}

@end
