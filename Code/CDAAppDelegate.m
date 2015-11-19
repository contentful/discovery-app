//
//  CDAAppDelegate.m
//  Browser
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import <Keys/DiscoveryKeys.h>
#import <Crashlytics/Crashlytics.h>

#import "BBUSplash.h"
#import "CDAAppDelegate.h"
#import "CDASpaceSelectionViewController.h"
#import "CDATutorialController.h"
#import "UIColor+Contentful.h"

@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:[DiscoveryKeys new].crashlytics];

    [UIButton appearance].tintColor = [UIColor contentfulBlueColor];
    [UINavigationBar appearance].tintColor = [UIColor contentfulBlackColor];
    [UISegmentedControl appearance].tintColor = [UIColor contentfulBlueColor];
    [UITabBar appearance].tintColor = [UIColor contentfulBlueColor];
    
    self.spaceSelectionViewController = [CDASpaceSelectionViewController new];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.spaceSelectionViewController;
    [self.window makeKeyAndVisible];
 
    [BBUSplash showAnimated:NO];
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:0.5];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:CDASpaceKey].length == 0) {
        CDATutorialController* tutorial = [CDATutorialController new];
        [self.window.rootViewController presentViewController:tutorial animated:NO completion:nil];
    }
    
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    
    if (![components.scheme isEqualToString:@"contentful"]) {
        return NO;
    }
    
    if (![components.host isEqualToString:@"open"]) {
        return NO;
    }
    
    if (![components.path hasPrefix:@"/space"]) {
        return NO;
    }
    
    NSString* spaceKey = components.path.lastPathComponent;
    NSString* accessToken = nil;
    
    for (NSString* parameter in [components.query componentsSeparatedByString:@"&"]) {
        NSArray* components = [parameter componentsSeparatedByString:@"="];
        
        if (components.count != 2) {
            return NO;
        }
        
        if ([[components firstObject] isEqualToString:@"access_token"]) {
            accessToken = [components lastObject];
        }
    }
    
    if (!accessToken) {
        return NO;
    }
 
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:CDAAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] setValue:spaceKey forKey:CDASpaceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.spaceSelectionViewController.updatedSavedSpaceAccessInformation = YES;
    return YES;
}

#pragma mark -

-(void)hideSplash {
    [BBUSplash hideAnimated:YES];
}

@end
