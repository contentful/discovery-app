//
//  CDAAppDelegate.h
//  Browser
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import <UIKit/UIKit.h>

@class CDAClient;
@class CDASpaceSelectionViewController;

@interface CDAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) CDAClient *client;
@property (strong, nonatomic) NSString* currentLocale;
@property (strong, nonatomic) CDASpaceSelectionViewController* spaceSelectionViewController;
@property (strong, nonatomic) UIWindow *window;

@end
