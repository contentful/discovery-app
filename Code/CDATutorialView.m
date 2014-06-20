//
//  CDATutorialView.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/05/14.
//
//

#import "CDATutorialView.h"
#import "UIDevice+BBU.h"
#import "UIView+Geometry.h"

@interface CDATutorialView ()

@property (nonatomic) UIImageView* backgroundImageView;
@property (nonatomic) UILabel* body;
@property (nonatomic) UILabel* headline;
@property (nonatomic) UIImageView* imageView;

@end

#pragma mark -

@implementation CDATutorialView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.backgroundImageView];
        
        switch ([UIDevice bbu_type]) {
            case BBUDeviceTypePhone:
            case BBUDeviceTypePhoneRetina:
                self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
                break;
                
            default:
                break;
        }
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 110.0, 320.0, 240.0)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.imageView.size = CGSizeMake(768.0, 700.0);
        }
        
        self.headline = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 50.0, self.width, 50.0)];
        self.headline.font = [UIFont boldSystemFontOfSize:20.0];
        self.headline.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.headline];
        
        self.body = [[UILabel alloc] initWithFrame:CGRectMake(10.0, CGRectGetMaxY(self.imageView.frame),
                                                              self.width - 20.0, 0.0)];
        self.body.height = self.height - self.body.y;
        self.body.numberOfLines = 0;
        self.body.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.body];
    }
    return self;
}

@end
