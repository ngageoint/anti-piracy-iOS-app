#import "MainViewController_iphone.h"
#import "AsamMap_iphone.h"
#import "SettingsViewController.h"
#import "AboutAsam.h"
#import "SubRegionView_iphone.h"
#import "AsamUtility.h"
#import "AsamSearch.h"
#import "AboutAsam_iphone.h"
#import "AsamSearchViewController_iphone.h"

@interface MainViewController_iphone ()

@property (nonatomic, strong) IBOutlet UIButton *mapViewButton;
@property (nonatomic, strong) IBOutlet UIButton *settingsViewButton;
@property (nonatomic, strong) IBOutlet UIButton *listViewButton;
@property (nonatomic, strong) IBOutlet UIButton *queryViewButton;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;

- (IBAction)navigateToMapView:(id)sender;
- (IBAction)navigateToSubRegionView:(id)sender;
- (IBAction)navigateToQueryView:(id)sender;
- (IBAction)navigateToSettingsView:(id)sender;
- (IBAction)aboutAssam:(id)sender;

@end

@implementation MainViewController_iphone

#pragma
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    }
    else {
        self.navigationItem.backBarButtonItem.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    self.bottomLabel.text = @"Go to Settings and Sync to view the most recent reports";
    self.bottomLabel.numberOfLines = 0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    button.tintColor = [UIColor whiteColor];
    button.accessibilityIdentifier = @"About";
    button.accessibilityLabel = @"About";
    [button addTarget:self action:@selector(aboutAssam:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.rightBarButtonItem = customItem;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.text = @"Anti-Shipping Activity Messages";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.navigationController.navigationBar.opaque = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.bottomLabel = nil;
    self.mapViewButton = nil;
    self.listViewButton = nil;
    self.queryViewButton = nil;
    self.settingsViewButton = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma
#pragma mark - Navigation Methods
- (IBAction)navigateToMapView:(id)sender {
    AsamMap_iphone *asamMap = [[AsamMap_iphone alloc] initWithNibName:@"AsamMap_iphone" bundle:nil];
    [self.navigationController pushViewController:asamMap animated:YES];
}

- (IBAction)navigateToSubRegionView:(id)sender {
    SubRegionView_iphone *subRegionView_iphone = [[SubRegionView_iphone alloc] initWithNibName:@"SubRegionView_iphone" bundle:nil];
    [self.navigationController pushViewController:subRegionView_iphone animated:YES];
}

- (IBAction)navigateToQueryView:(id)sender {
    AsamSearchViewController_iphone *asamSearch = [[AsamSearchViewController_iphone alloc] initWithNibName:@"AsamSearchViewController_iphone" bundle:nil];
    [self.navigationController pushViewController:asamSearch animated:YES];
}

- (IBAction)navigateToSettingsView:(id)sender {
    SettingsViewController *settingsView = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController_iphone" bundle:nil];
    [self.navigationController pushViewController:settingsView animated:YES];
}

#pragma mark - About Asam
- (IBAction)aboutAssam:(id)sender {
    AboutAsam_iphone *aboutAssam = [[AboutAsam_iphone alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aboutAssam];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
