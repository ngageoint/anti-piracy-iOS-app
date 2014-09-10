#import "CommonViewController.h"
#import "AsamUtility.h"
#import "Asam.h"
#import "AsamFetch.h"
#import "DSActivityView.h"
#import "AsamConstants.h"

@interface CommonViewController()

@property (strong, nonatomic) IBOutlet UISwitch *disclaimerSwitch;
@property (strong, nonatomic) NSUserDefaults *prefs;

@end

@implementation CommonViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    }
    
    UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        backBarButtonItem.title = @"Menu";
    }
    else {
        backBarButtonItem.title = @"";   
    }
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma
#pragma mark - Bar title set up
- (void)setUpSettingsBarTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"ASAM Settings";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.tableView.backgroundColor = [UIColor blackColor];
    }
    else {
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        [backImage setFrame:self.tableView.frame];
        self.tableView.backgroundView = backImage;
    }
}

#pragma
#pragma mark - UISwitch Action/ControlEventTarget Actions
- (void)switchAction:(UISwitch*)sender {
    if ([sender isOn]) {
        [self.prefs setObject:@"Yes" forKey:kShowDisclaimer];
    }
    else {
        [self.prefs setObject:@"No" forKey:kShowDisclaimer];
    }
    [self.prefs synchronize];
}


@end
