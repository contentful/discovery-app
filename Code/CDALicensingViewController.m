//
//  CDALicensingViewController.m
//  Discovery
//
//  Created by Boris Bügling on 20/06/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Bypass/Bypass.h>

#import "CDALicensingViewController.h"
#import "CDAWebController.h"

@interface CDALicensingViewController () <UITextViewDelegate>

@property (nonatomic) NSString* markdownText;
@property (nonatomic) UITextView* textView;

@end

#pragma mark -

@implementation CDALicensingViewController

- (void)setMarkdownText:(NSString *)markdownText {
    _markdownText = markdownText;
    
    BPDocument* document = [[BPParser new] parse:markdownText];
    BPAttributedStringConverter* converter = [BPAttributedStringConverter new];
    converter.displaySettings.quoteFont = [UIFont fontWithName:@"Marion-Italic"
                                                          size:[UIFont systemFontSize] + 1.0f];
    NSAttributedString* attributedText = [converter convertDocument:document];
    
    self.textView.attributedText = attributedText;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Licensing", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.textView.delegate = self;
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:18.0];
    if ([self.textView respondsToSelector:@selector(textContainerInset)]) {
        self.textView.textContainerInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 20.0);
    }
    [self.view addSubview:self.textView];
    
    NSString* licensingInfo = @"# Contentful Discovery\n\nCopyright (c) 2014 [Contentful GmbH](https://www.contentful.com)\n\nUses icons from the [IcoMoon icon set](http://keyamoon.com/icomoon/), licensed under [CC BY 3.0](http://creativecommons.org/licenses/by/3.0/).\n\n";
    
    NSString* pathToAcknowledgements = [[NSBundle mainBundle] pathForResource:@"Pods-Discovery-acknowledgements" ofType:@"markdown"];
    NSString* acknowledgements = [NSString stringWithContentsOfFile:pathToAcknowledgements
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
    
    self.markdownText = [licensingInfo stringByAppendingString:acknowledgements];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)range {
    CDAWebController* webController = [[CDAWebController alloc] initWithURL:URL];
    [self.navigationController pushViewController:webController animated:YES];
    return YES;
}

@end
