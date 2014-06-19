//
//  UITableView+EmptyView.h
//  Discovery
//
//  Created by Boris Bügling on 13/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

@interface UITableView (EmptyView)

@property (nonatomic) BOOL loading_cda;

-(void)cda_onEmptynessShowLabelWithTitle:(NSString*)title beforeBlock:(void (^)())before;

@end
