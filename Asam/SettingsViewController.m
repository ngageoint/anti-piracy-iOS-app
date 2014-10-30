#import "SettingsViewController.h"
#import "AsamUtility.h"
#import "Reachability.h"
#import "UIButton+ButtonGradient.h"
#import <QuartzCore/QuartzCore.h>
#import "AsamConstants.h"
#import "NSString+StringFromDate.h"
#import "AsamDownloader.h"
#import "AppDelegate.h"
#import "DSActivityView.h"
#import <MapKit/MapKit.h>

#define kLastSyncDateKey @"lastsyncdate"
#define kShowDisclaimer @"showDisclaimer"

@interface SettingsViewController() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *settingsArray;
@property (nonatomic, strong) IBOutlet UISwitch *disclaimerSwitch;
@property (nonatomic, strong) NSUserDefaults *prefs;

- (void)fetchAllAsamsFromLastSyncedDate:(id)sender;

@end

@implementation SettingsViewController

#pragma 
#pragma mark - Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if (![deviceType hasPrefix: @"iPhone"]) {
        self.settingsArray = @[@"Last Sync Date", @"Show Disclaimer", @"Map", @"Sync Now"];
    }
    else {
        self.settingsArray = @[@"Last Sync Date", @"Show Disclaimer", @"Sync Now"];
    }
    
    self.prefs = [NSUserDefaults standardUserDefaults];
    [self setUpSettingsBarTitle];
}

- (void)viewDidUnload {
    self.settingsArray = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SettingTableIdentifier = @"SettingTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingTableIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingTableIdentifier"];
		UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        [[cell textLabel] setFont:titleFont];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *button = nil;

        NSString *option = [self.settingsArray objectAtIndex:[indexPath row]];
        

        if ([option isEqualToString:@"Last Sync Date"]) {
            self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 12, 100, 30)];
            self.dateLabel.backgroundColor = [UIColor clearColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                self.dateLabel.textColor = [UIColor whiteColor];
            } else {
                self.dateLabel.textColor = [UIColor blackColor];
            }
            
            if ([self.prefs objectForKey:kLastSyncDateKey] == nil) {
                self.dateLabel.text = [NSString getStringFromDate:[AsamUtility fetchAndFomatLastSyncDate]];
            }
            else {
                self.dateLabel.text = [self.prefs objectForKey:kLastSyncDateKey];
            }
            cell.accessoryView = self.dateLabel;
            [cell addSubview:self.dateLabel];
            cell.textLabel.text = option;
        }
        else if ([option isEqualToString:@"Show Disclaimer"]) {
            self.disclaimerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.disclaimerSwitch.on = ([[self.prefs objectForKey:kShowDisclaimer] isEqualToString:@"Yes"]) ? YES : NO;
            self.disclaimerSwitch.tag = 1;
            [self.disclaimerSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.disclaimerSwitch;
            [cell addSubview:self.disclaimerSwitch];
            cell.textLabel.text = option;
        }
        else if ([option isEqualToString:@"Map"]) {
            NSArray *itemArray = [NSArray arrayWithObjects: @"Standard", @"Satellite", @"Hybrid", @"Offline", nil];
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
            segmentedControl.frame = CGRectMake(80, 7, 300, 30);
            segmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
            segmentedControl.tintColor = [UIColor whiteColor];
            segmentedControl.apportionsSegmentWidthsByContent = true;
            
            [segmentedControl addTarget:self action:@selector(action:) forControlEvents:UIControlEventValueChanged];
            
            //set the selected map type.
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *maptype = [prefs stringForKey:@"maptype"];
            
            if ([@"Standard" isEqual:maptype]) {
                segmentedControl.selectedSegmentIndex = 0;
            }
            else if ([@"Satellite" isEqual:maptype]) {
                segmentedControl.selectedSegmentIndex = 1;
            }
            else if ([@"Hybrid" isEqual:maptype]) {
                segmentedControl.selectedSegmentIndex = 2;
            }
            else if ([@"Offline" isEqual:maptype]) {
                segmentedControl.selectedSegmentIndex = 3;
            }
            else {
                segmentedControl.selectedSegmentIndex = 0;
            }
            
            [cell addSubview:segmentedControl];
            cell.textLabel.text = option;
        }
        else if ([option isEqualToString:@"Sync Now"]) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                [button addTarget:self action:@selector(syncNow:) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                [button addTarget:self action:@selector(fetchAllAsamsFromLastSyncedDate:) forControlEvents:UIControlEventTouchUpInside];
            }
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                button.tintColor = [UIColor whiteColor];
            } else {
                button.tintColor = [UIColor blackColor];
                [button addGradient:button];
            }
            [button setTitle:@"Sync Now" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateHighlighted)];
            button.frame =  CGRectMake(160, 7, 150, 30);
            button.tag = 3;
            button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            [cell addSubview:button];
        }
	}
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)action:(id)sender {

    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    switch (selectedSegment) {
        case 0:
            [standardUserDefaults setObject:@"Standard" forKey:@"maptype"];
            break;
        case 1:
            [standardUserDefaults setObject:@"Satellite" forKey:@"maptype"];
            break;
        case 2:
            [standardUserDefaults setObject:@"Hybrid" forKey:@"maptype"];
            break;
        case 3:
            [standardUserDefaults setObject:@"Offline" forKey:@"maptype"];
            break;
        default:
            break;                
    }
   
}

- (void)fetchAllAsamsFromLastSyncedDate:(id)sender {
    [DSBezelActivityView activityViewForView:self.view withLabel:@"Fetching Asam(s)..." width:160];

    if (![AsamUtility reachable]) {
        [DSBezelActivityView removeViewAnimated:YES];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Your device is not connected to the Internet" message:@"Network is currently offline" delegate:nil cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [message show];
        return;
        
    }
    AsamDownloader *asamDownloader = [[AsamDownloader alloc] init];
    NSString *urlToCall = [NSString stringWithFormat:@"%@%@%@%@", kAsamBaseUrl,[AsamUtility fetchAndFomatLastSyncDate], kAsamPartTwo, [AsamUtility formatTodaysDate]];
    [asamDownloader downloadAndSaveAsamsWithURL:[NSURL URLWithString:urlToCall] completionBlock:^(BOOL success, NSError *error) {
        if (error) {
            [DSBezelActivityView removeViewAnimated:YES];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Download Asams failed" message:@"Try again later" delegate:nil cancelButtonTitle:@"OK"  otherButtonTitles:nil];
            [message show];
            return;
        }
        else {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSDate *date = [NSDate date];
            NSDateFormatter *lastSynDateFormatter = [[NSDateFormatter alloc] init];
            lastSynDateFormatter.dateFormat = @"MM/dd/yyyy";
            NSString *formattedNewSyncDate = [lastSynDateFormatter stringFromDate:date];
            [prefs setObject:formattedNewSyncDate forKey:kLastSyncDateKey];
            [prefs synchronize];
            self.dateLabel.text = formattedNewSyncDate;
            [self.tableView reloadData];
            [DSBezelActivityView removeViewAnimated:YES];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (IBAction)syncNow:(id)sender {
    [self.asamUpdateDelegate updateAsamFromDate];
}


@end
