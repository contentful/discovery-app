//
//  CDAMarkdownCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <Bypass/Bypass.h>

#import "CDAAttributedStringConverter.h"
#import "CDAMarkdownCell.h"

@interface CDAMarkdownCell ()

@property (nonatomic) UITextView* textView;

@end

#pragma mark -

@implementation CDAMarkdownCell

+(UIFont*)usedFont {
    return [UIFont systemFontOfSize:18.0];
}

#pragma mark -

- (void)applyBackgroundsToInlineAssets:(NSArray*)inlineAssets {
    for (CDAInlineAsset* asset in inlineAssets) {
        CGRect boundingRect = [self boundingRectForCharacterRange:asset.range];

        boundingRect.origin.x = 5.0;
        boundingRect.origin.y += 25.0;
        boundingRect.size.width = self.textView.frame.size.width - 10.0;
        boundingRect.size.height += 20.0;

        UIView* backgroundView = [[UIView alloc] initWithFrame:boundingRect];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
        [self.textView.superview insertSubview:backgroundView atIndex:0];
    }
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range {
    NSLayoutManager* layoutManager = self.textView.layoutManager;
    NSTextContainer* textContainer = self.textView.textContainer;

    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];

    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:self.bounds];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
        self.textView.editable = NO;
        self.textView.font = [[self class] usedFont];
        if ([self.textView respondsToSelector:@selector(textContainerInset)]) {
            self.textView.textContainerInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 20.0);
        }
        [self addSubview:self.textView];
    }
    return self;
}

- (void)layoutSubviews {
    self.textView.frame = self.bounds;
    [self.contentView bringSubviewToFront:self.textView];
}

- (void)setMarkdownText:(NSString *)markdownText {
    _markdownText = markdownText;
    
    BPDocument* document = [[BPParser new] parse:markdownText];
    CDAAttributedStringConverter* converter = [CDAAttributedStringConverter new];

    [converter fetchInlineAssetsFromDocument:document withCompletionHandler:^(CDAAttributedStringConverter *converter, NSError *error) {
        converter.displaySettings.quoteFont = [UIFont fontWithName:@"Marion-Italic"
                                                              size:[UIFont systemFontSize] + 1.0f];
        NSAttributedString* attributedText = [converter convertDocument:document];

        self.textView.attributedText = attributedText;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.scrollEnabled = NO;

        [self performSelector:@selector(applyBackgroundsToInlineAssets:)
                   withObject:converter.inlineAssets
                   afterDelay:0.1];
    }];
}

@end
