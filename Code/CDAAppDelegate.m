//
//  CDAAppDelegate.m
//  Browser
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import "BBUSplash.h"
#import "CDAAppDelegate.h"
#import "CDASpaceSelectionViewController.h"
#import "CDATutorialController.h"

@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UINavigationBar appearance].tintColor = [UIColor colorWithWhite:0.233 alpha:1.000];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [CDASpaceSelectionViewController new];
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
    return YES;
}

#pragma mark -

-(void)hideSplash {
    [BBUSplash hideAnimated:YES];
}

@end
