//
//  CDATutorialController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 07/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>
#import <DDPageControl/DDPageControl.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CDATutorialController.h"
#import "CDATutorialView.h"
#import "UIColor+Contentful.h"
#import "UIDevice+BBU.h"
#import "UIView+Geometry.h"

@interface CDATutorialController () <UIScrollViewDelegate>

@property (nonatomic) CDAClient* client;
@property (nonatomic) DDPageControl* pageControl;
@property (nonatomic) UIScrollView* scrollView;

@end

#pragma mark -

@implementation CDATutorialController

- (BOOL)atEndOfScrollView {
    CGFloat position = self.scrollView.contentOffset.x + self.scrollView.bounds.size.width;
    position -= self.scrollView.contentInset.right;
    
    return position > self.scrollView.contentSize.width;
}

-(id)init {
    self = [super init];
    if (self) {
        self.client = [[CDAClient alloc] initWithSpaceKey:@"tyqxsw7o3ipi"
                                              accessToken:@"5ddd61286e007dd90a78549abd753c96ec7b6d8498e6217fb18328f3842b55b3"];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [DDPageControl new];
    self.pageControl.onColor = [UIColor contentfulBlackColor];
    self.pageControl.offColor = [UIColor lightGrayColor];
    self.pageControl.frame = CGRectMake(0.0, self.view.height - 50.0, 100.0, 50.0);
    self.pageControl.x = (self.view.width - self.pageControl.width) / 2;
    [self.view addSubview:self.pageControl];
    
    UIButton* skipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    skipButton.frame = CGRectMake(0.0, 10.0, 75.0, 50.0);
    skipButton.x = self.view.width - skipButton.width;
    [skipButton addTarget:self action:@selector(skipTour) forControlEvents:UIControlEventTouchUpInside];
    [skipButton setTitle:NSLocalizedString(@"Skip tour", nil) forState:UIControlStateNormal];
    [self.view addSubview:skipButton];
    
    [self.client fetchEntryWithIdentifier:@"3dqGz5zXQsK0kmeMCSMgKs"
                                  success:^(CDAResponse *response, CDAEntry *entry) {
                                      CGFloat xCoordinate = 0.0;
                                      NSArray* pages = entry.fields[@"pages"];
                                      
                                      for (CDAEntry* page in pages) {
                                          CDATutorialView* tutorialView = [[CDATutorialView alloc] initWithFrame:self.scrollView.bounds];
                                          
                                          if (xCoordinate < 1.0) {
                                              tutorialView.imageView.userInteractionEnabled = YES;
                                              [tutorialView.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)]];
                                          }
                                          
                                          tutorialView.x = xCoordinate;
                                          xCoordinate += tutorialView.width;
                                          
                                          switch ([UIDevice bbu_type]) {
                                              case BBUDeviceTypePad:
                                              case BBUDeviceTypePadRetina:
                                                  [tutorialView.backgroundImageView cda_setImageWithAsset:entry.fields[@"backgroundImageIPad"]];
                                                  break;
                                              default:
                                                  [tutorialView.backgroundImageView cda_setImageWithAsset:entry.fields[@"backgroundImage"]];
                                                  break;
                                          }
                                          
                                          [tutorialView.imageView cda_setImageWithAsset:page.fields[@"asset"]];
                                          
                                          tutorialView.body.text = page.fields[@"content"];
                                          tutorialView.headline.text = page.fields[@"headline"];
                                          
                                          [self.scrollView addSubview:tutorialView];
                                      }
                                      
                                      self.pageControl.currentPage = 0;
                                      self.pageControl.numberOfPages = pages.count;
                                      self.scrollView.contentSize = CGSizeMake(self.scrollView.width * pages.count,
                                                                               self.scrollView.height);
                                  } failure:^(CDAResponse *response, NSError *error) {
                                      UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                                      [alertView show];
                                  }];
}

#pragma mark - Actions

-(void)playVideo {
    NSURL* movieURL = [[NSBundle mainBundle] URLForResource:@"contentful-video" withExtension:@"mp4"];
    MPMoviePlayerViewController* moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

-(void)skipTour {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger page = self.scrollView.contentOffset.x / (self.scrollView.contentSize.width / self.pageControl.numberOfPages);
    self.pageControl.currentPage = page + 1;
    
    if ([self atEndOfScrollView]) {
        [self skipTour];
    }
}

@end
