//
//  CDAContentTypesViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <Aspects/Aspects.h>

#import "CDAContentTypesViewController.h"
#import "CDAEntryPreviewController.h"
#import "UITableView+EmptyView.h"
#import "UIView+Geometry.h"

@interface CDAContentTypesViewController () <CDAEntriesViewControllerDelegate>

@property (nonatomic, readonly) UIBarButtonItem* logoutButton;

@end

#pragma mark -

@implementation CDAContentTypesViewController

-(void)didSelectRowWithResource:(CDAResource *)resource {
    CDAContentType* contentType = (CDAContentType*)resource;
    
    NSDictionary* mapping = nil;
    if (contentType.displayField) {
        mapping = @{ @"textLabel.text": [@"fields." stringByAppendingString:contentType.displayField] };
    } else {
        mapping = @{ @"textLabel.text": @"sys.id" };
    }
    
    CDAEntriesViewController* entriesVC = [[CDAEntriesViewController alloc] initWithCellMapping:mapping];
    entriesVC.client = self.client;
    entriesVC.delegate = self;
    entriesVC.locale = self.locale;
    entriesVC.navigationItem.rightBarButtonItem = self.logoutButton;
    entriesVC.query = @{ @"content_type": contentType.identifier };
    entriesVC.showSearchBar = YES;
    entriesVC.title = contentType.name;
    
    [entriesVC.tableView cda_onEmptynessShowLabelWithTitle:NSLocalizedString(@"No matching entries found.", nil)];
    
    [self.navigationController pushViewController:entriesVC animated:YES];
}

-(id)init {
    self = [super initWithCellMapping:@{ @"textLabel.text": @"name",
                                         @"detailTextLabel.text": @"userDescription" } ];
    if (self) {
        self.resourceType = CDAResourceTypeContentType;
        self.tabBarItem.image = [UIImage imageNamed:@"entries"];
        self.title = NSLocalizedString(@"Entries", nil);
    }
    return self;
}

-(UIBarButtonItem *)logoutButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(logout)];
}

#pragma mark - Actions

-(void)logout {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CDAEntriesViewControllerDelegate

-(void)entriesViewController:(CDAEntriesViewController *)entriesViewController
       didSelectRowWithEntry:(CDAEntry *)entry {
    CDAEntryPreviewController* previewController = [[CDAEntryPreviewController alloc] initWithEntry:entry];
    previewController.navigationItem.rightBarButtonItem = self.logoutButton;
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDAContentType* contentType = self.items[indexPath.row];
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* entryCountLabel = nil;
    if (cell.contentView.subviews.count == 3) {
        entryCountLabel = [cell.contentView.subviews lastObject];
    } else {
        entryCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.width - 120.0, 0.0,
                                                                    70.0, cell.height)];
        
        entryCountLabel.font = cell.detailTextLabel.font;
        entryCountLabel.textAlignment = NSTextAlignmentRight;
        entryCountLabel.textColor = cell.detailTextLabel.textColor;
        
        [cell.contentView addSubview:entryCountLabel];
    }
    
    [cell aspect_hookSelector:@selector(layoutSubviews) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        cell.detailTextLabel.width = cell.width - 120.0;
    } error:nil];
    
    [self.client fetchEntriesMatching:@{ @"content_type": contentType.identifier, @"limit": @0 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  entryCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d entries", nil), array.total];
                                  
                                  if (array.total == 0) {
                                      cell.accessoryType = UITableViewCellAccessoryNone;
                                  }
                              } failure:nil];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
