//
//  CDAHelpViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 13/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAHelpViewController.h"
#import "UIDevice+BBU.h"
#import "UIView+Geometry.h"

@interface CDAHelpViewController ()

@property (nonatomic) CDAClient* client;

@end

#pragma mark -

@implementation CDAHelpViewController

-(CGFloat)addContentFromEntry:(CDAEntry*)entry
                 toScrollView:(UIScrollView*)scrollView
                  yCoordinate:(CGFloat)yCoordinate {
    UILabel* explanatoryText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yCoordinate,
                                                                         scrollView.width - 20.0, 0.0)];
    explanatoryText.numberOfLines = 0;
    explanatoryText.text = entry.fields[@"text"];
    [explanatoryText sizeToFit];
    [scrollView addSubview:explanatoryText];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                           scrollView.width, 0.0)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.y = CGRectGetMaxY(explanatoryText.frame) + 20.0;
    [scrollView addSubview:imageView];
    
    switch ([UIDevice bbu_type]) {
        case BBUDeviceTypePad:
        case BBUDeviceTypePadRetina:
            imageView.height = 200.0;
            [imageView cda_setImageWithAsset:entry.fields[@"imageIPad"]];
            break;
        default:
            imageView.height = 100.0;
            [imageView cda_setImageWithAsset:entry.fields[@"image"]];
            break;
    }
    
    return CGRectGetMaxY(imageView.frame);
}

-(id)init {
    self = [super init];
    if (self) {
        self.client = [[CDAClient alloc] initWithSpaceKey:@"tyqxsw7o3ipi" accessToken:@"5ddd61286e007dd90a78549abd753c96ec7b6d8498e6217fb18328f3842b55b3"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
        self.title = NSLocalizedString(@"Help", nil);
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0,
                                                                    self.view.width - 20.0, 100.0)];
    titleLabel.font = [UIFont boldSystemFontOfSize:25.0];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:titleLabel];
    
    [self.client fetchEntryWithIdentifier:@"4qigoc7Yw0OqyE6I0Ic8Gu"
                                  success:^(CDAResponse *response, CDAEntry *entry) {
                                      titleLabel.text = entry.fields[@"title"];
                                      [titleLabel sizeToFit];
                                      
                                      CGFloat yCoordinate = CGRectGetMaxY(titleLabel.frame) + 50.0;
                                      for (CDAEntry* item in entry.fields[@"helpItems"]) {
                                          yCoordinate = [self addContentFromEntry:item
                                                                     toScrollView:scrollView
                                                                      yCoordinate:yCoordinate] + 50.0;
                                      }
                                      
                                      scrollView.contentSize = CGSizeMake(scrollView.width, yCoordinate + 20.0);
                                  } failure:^(CDAResponse *response, NSError *error) {
                                      UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                                      [alertView show];
                                  }];
}

#pragma mark - Actions

-(void)doneTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
