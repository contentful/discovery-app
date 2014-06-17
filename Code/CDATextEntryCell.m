//
//  CDATextEntryCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import "CDATextEntryCell.h"
#import "UIView+Geometry.h"

@interface CDATextEntryCell ()

@property (nonatomic) UITextField* textField;

@end

#pragma mark -

@implementation CDATextEntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                       self.width / 2, self.height)];
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.clearsOnBeginEditing = YES;
        self.textField.enablesReturnKeyAutomatically = YES;
        
        self.accessoryView = self.textField;
    }
    return self;
}

- (void)layoutSubviews
{
    self.textField.width = self.width / 2;
    
    [super layoutSubviews];
}

@end
