//
//  CDASpaceSelectionViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <DHCShakeNotifier/UIWindow+DHCShakeRecognizer.h>

#import "CDAAboutUsViewController.h"
#import "CDAHelpViewController.h"
#import "CDASpaceViewController.h"
#import "CDATextEntryCell.h"
#import "CDASpaceSelectionViewController.h"
#import "UIApplication+Browser.h"
#import "UIView+Geometry.h"

NSString* const CDAAccessTokenKey    = @"CDAAccessTokenKey";
NSString* const CDASpaceKey          = @"CDASpaceKey";

static NSString* const CDADebugMenuCell     = @"DebugMenuCell";
static NSString* const CDALogoAnimationKey  = @"SpinLogo";

@interface CDASpaceSelectionViewController () <CDAEntriesViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, readonly) BOOL done;
@property (nonatomic) UIButton* loadButton;
@property (nonatomic) UIImageView* logoView;
@property (nonatomic) BOOL showsDebugMenu;

@end

#pragma mark -

@implementation CDASpaceSelectionViewController

- (void)dealloc
{
    for (NSString* name in @[ DHCSHakeNotificationName, UIApplicationDidBecomeActiveNotification ]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:nil];
    }
}

- (BOOL)done
{
    return [self textFieldAtRow:0].text.length > 0 && [self textFieldAtRow:1].text.length > 0;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.title = NSLocalizedString(@"Space selection", nil);
        
        [self.tableView registerClass:[CDATextEntryCell class]
               forCellReuseIdentifier:NSStringFromClass([self class])];
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:CDADebugMenuCell];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(shakeHappened:)
                                                     name:DHCSHakeNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)setUpdatedSavedSpaceAccessInformation:(BOOL)updatedSavedSpaceAccessInformation {
    _updatedSavedSpaceAccessInformation = updatedSavedSpaceAccessInformation;
    
    [self applicationDidBecomeActive:nil];
}

- (void)showSpaceWithKey:(NSString*)spaceKey accessToken:(NSString*)accessToken
{
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:spaceKey accessToken:accessToken];
    [UIApplication sharedApplication].client = client;
    
    [self startSpinningLogo];
    
    [client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        [self stopSpinningLogo];
        
        CDASpaceViewController* spaceVC = [CDASpaceViewController new];
        [self presentViewController:spaceVC animated:YES completion:nil];
    } failure:^(CDAResponse *response, NSError *error) {
        [self stopSpinningLogo];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (UITextField*)textFieldAtRow:(NSInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:1];
    CDATextEntryCell* cell = (CDATextEntryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    return cell.textField;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self stopSpinningLogo];
    
    [self.tableView reloadData];
    
    [UIApplication sharedApplication].currentLocale = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopSpinningLogo];
}

#pragma mark - Actions

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    if (self.updatedSavedSpaceAccessInformation) {
        [self.tableView reloadData];
        
        self.updatedSavedSpaceAccessInformation = NO;
    }
}

- (void)doneTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadDefaultSpaceTapped
{
    [self showSpaceWithKey:@"nvyqx9l6z9z9" accessToken:@"af972a4929249ff278fa09828a4f6d4580ff6cba1d0ca1ef12c0c9afda2fe57e"];
}

- (void)loadSpaceTapped
{
    NSString* spaceKey = [self textFieldAtRow:0].text;
    NSString* accessToken = [self textFieldAtRow:1].text;
    
    [[NSUserDefaults standardUserDefaults] setValue:spaceKey forKey:CDASpaceKey];
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:CDAAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self showSpaceWithKey:spaceKey accessToken:accessToken];
}

- (void)logoTapped
{
    CDAAboutUsViewController* aboutUs = [CDAAboutUsViewController new];
    aboutUs.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    
    UINavigationController* navController = [[UINavigationController alloc]
                                             initWithRootViewController:aboutUs];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)shakeHappened:(NSNotification*)note
{
#ifdef DEBUG
    self.showsDebugMenu = !self.showsDebugMenu;
    
    [self.tableView reloadData];
#endif
}

- (void)showHelp
{
    CDAHelpViewController* help = [CDAHelpViewController new];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:help];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)textFieldChanged
{
    self.loadButton.enabled = self.done;
}

#pragma mark - Animations

- (void)startSpinningLogo
{
    [[self textFieldAtRow:0] resignFirstResponder];
    [[self textFieldAtRow:1] resignFirstResponder];
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 1.1;
    rotation.repeatCount = INT_MAX;
    
    [self.logoView.layer addAnimation:rotation forKey:CDALogoAnimationKey];
}

- (void)stopSpinningLogo
{
    [self.logoView.layer removeAnimationForKey:CDALogoAnimationKey];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.showsDebugMenu ? 1 : 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showsDebugMenu) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CDADebugMenuCell
                                                                forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Ancient Myths";
                break;
                
            case 1:
                cell.textLabel.text = @"Asset testing";
                break;
            
            case 2:
                cell.textLabel.text = @"Browser app test";
                break;
                
            case 3:
                cell.textLabel.text = @"Case study";
                break;
                
            case 4:
                cell.textLabel.text = @"Seed database test";
                break;
            case 5:
                cell.textLabel.text = @"Music Demo Publishing";
                break;
        }
        
        return cell;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CDATextEntryCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                         forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
            cell.textField.placeholder = NSLocalizedString(@"Space", nil);
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CDASpaceKey];
            cell.textLabel.text = cell.textField.placeholder;
            break;
        case 1:
            cell.textField.placeholder = NSLocalizedString(@"Access Token", nil);
            cell.textField.returnKeyType = UIReturnKeyGo;
            cell.textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:CDAAccessTokenKey];
            cell.textLabel.text = cell.textField.placeholder;
            break;
    }
    
    cell.textField.delegate = self;
    
    [cell.textField addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.showsDebugMenu) {
        return 0.0;
    }
    
    return section == 1 ? 118.0 : UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.showsDebugMenu) {
        return 0.0;
    }
    
    CGFloat topHeight = 220.0 + ([UIScreen mainScreen].bounds.size.height - 480.0);
    return section == 0 ? topHeight : UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showsDebugMenu) {
        return 6;
    }
    
    return section == 0 ? 0 : 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.showsDebugMenu ? nil : NSLocalizedString(@"Enter access information", nil);
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 || self.showsDebugMenu) {
        return nil;
    }
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.width, 118.0)];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 10.0, 250.0, 44.0);
    button.x = (tableView.width - button.width) / 2;
    
    [button addTarget:self action:@selector(loadSpaceTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"btn_blue"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Load Space", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(5.0, -225.0, 5.0, 5.0)];
    
    self.loadButton = button;
    self.loadButton.enabled = self.done;
    
    [view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.loadButton.x, CGRectGetMaxY(self.loadButton.frame) + 10.0,
                              self.loadButton.width, self.loadButton.height);
    
    [button addTarget:self
               action:@selector(loadDefaultSpaceTapped)
     forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"btn_green"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Demo Space", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:self.loadButton.titleEdgeInsets];
    
    [view addSubview:button];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && !self.showsDebugMenu) {
        UIView* containerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        self.logoView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoView.frame = CGRectMake(0.0, 40.0, tableView.width, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 420 : 200.0);
        self.logoView.userInteractionEnabled = YES;
        [containerView addSubview:self.logoView];
        
        [self.logoView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(logoTapped)]];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(tableView.width - 50.0, 20.0, 44.0, 44.0);
        
        [button addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
        
        [containerView addSubview:button];
        return containerView;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showsDebugMenu) {
        switch (indexPath.row) {
            case 0:
                [self showSpaceWithKey:@"nvyqx9l6z9z9"
                           accessToken:@"af972a4929249ff278fa09828a4f6d4580ff6cba1d0ca1ef12c0c9afda2fe57e"];
                break;
                
            case 1:
                [self showSpaceWithKey:@"gfldmthn9ms1"
                           accessToken:@"2cb1dae8fa4849ed58075769441d81a39c19e2cdbc6126a1f096d1c4e1823cc3"];
                break;
                
            case 2:
                [self showSpaceWithKey:@"xob0ttmty67c"
                           accessToken:@"ccc4d04e8f85c5e86925587c2f9ec2c32651c7f0c8e4e641bb70dac9ad71f35c"];
                break;
                
            case 3:
                [self showSpaceWithKey:@"zdd82vwiz91m"
                           accessToken:@"79ba4c76a2813d9322b3c068bb61dfb00120b9a5453001682c3ad2b152d0bef2"];
                break;
                
            case 4:
                [self showSpaceWithKey:@"duzidfp33ikw"
                           accessToken:@"a196a5806ddd5f25700624bb11dfc94aeac9f0a5d4bd245e68cf42f78f8b2cc6"];
                break;
                
            case 5:
                [self showSpaceWithKey:@"ntaqqv7rma1o"
                           accessToken:@"750704407ecefb218f1e0af2d799053413abd773f402d447bfc066b6292fb480"];
                break;
        }
        
        return;
    }
    
    [[self textFieldAtRow:indexPath.row] becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        [[self textFieldAtRow:1] becomeFirstResponder];
        return NO;
    }
    
    if (self.done) {
        [self loadSpaceTapped];
        return NO;
    }
    
    return YES;
}

@end
