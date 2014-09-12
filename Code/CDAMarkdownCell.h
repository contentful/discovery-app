//
//  CDAMarkdownCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^CDAInlineImagesFinishedLoadingHandler)();

@interface CDAMarkdownCell : UITableViewCell

@property (nonatomic, copy) CDAInlineImagesFinishedLoadingHandler finishedLoadingHandler;
@property (nonatomic) NSString* markdownText;
@property (nonatomic, readonly) UITextView* textView;

+(UIFont*)usedFont;

@end
