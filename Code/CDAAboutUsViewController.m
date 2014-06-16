//
//  CDAAboutUsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/05/14.
//
//

#import <CGLMail/CGLMailHelper.h>

#import "CDAAboutUsViewController.h"
#import "CDATutorialController.h"
#import "CDAWebController.h"
#import "UIView+Geometry.h"

@interface CDAAboutUsViewController ()

@property (nonatomic) CGFloat emptySpaceHeight;

@end

#pragma mark -

@implementation CDAAboutUsViewController

-(CGFloat)emptySpaceHeight {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1
                                                inSection:0];
    CGRect lastRowFrame = [self.tableView rectForRowAtIndexPath:indexPath];
    return self.tableView.height - (lastRowFrame.origin.y + lastRowFrame.size.height);
}

-(id)init {
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tabBarItem.image = [UIImage imageNamed:@"about"];
        self.title = NSLocalizedString(@"About Us", nil);
        
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                            forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"FAQ", nil);
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Send feedback", nil);
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Contact us", nil);
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"View Tour", nil);
            break;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return 70.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* urlString = nil;
    
    switch (indexPath.row) {
        case 0:
            urlString = @"https://support.contentful.com/hc/en-us/?utm_source=Discovery%20app&utm_medium=iOS&utm_campaign=faq";
            break;
        case 1:
            urlString = @"https://support.contentful.com/hc/en-us/requests/new/?utm_source=Discovery%20app&utm_medium=iOS&utm_campaign=feedback";
            break;
        case 2: {
            UIViewController *mailVC = [CGLMailHelper mailViewControllerWithRecipients:@[@"voice@contentful.com"] subject:@"Question about Contentful" message:@"\n\n" isHTML:NO includeAppInfo:YES completion:nil];
            
            if (!mailVC) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Cannot send mail.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            } else {
                [self presentViewController:mailVC animated:YES completion:nil];
            }
            
            return;
        }
        case 3: {
            CDATutorialController* tutorial = [CDATutorialController new];
            [self presentViewController:tutorial animated:YES completion:nil];
            return;
        }
    }
    
    CDAWebController* webController = [[CDAWebController alloc]
                                       initWithURL:[NSURL URLWithString:urlString]];
    [self.navigationController pushViewController:webController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.emptySpaceHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 150.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                  tableView.width, self.emptySpaceHeight)];
    footerView.userInteractionEnabled = NO;
    
    UILabel* versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.width, 50.0)];
    versionLabel.y = footerView.height - versionLabel.height;
    
    versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"App version %@", nil),
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    
    [footerView addSubview:versionLabel];
    return footerView;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.width, 150.0)];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logo.frame = CGRectMake((headerView.width - 70.0) / 2, 10.0, 70.0, 70.0);
    [headerView addSubview:logo];
    
    UILabel* companyName = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(logo.frame) + 10.0,
                                                                     headerView.width, 20.0)];
    companyName.font = [UIFont boldSystemFontOfSize:18.0];
    companyName.text = @"Contentful GmbH";
    companyName.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:companyName];
    
    return headerView;
}

@end
