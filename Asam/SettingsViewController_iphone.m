

#import "SettingsViewController_iphone.h"
#import "AsamUtility.h"
#import "Reachability.h"
#import "UIButton+ButtonGradient.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "AsamConstants.h"
#import "NSString+StringFromDate.h"

#define kConnectedKey @"connected"
#define kLastSyncDateKey @"lastsyncdate"
#define kShowDisclaimer @"showDisclaimer"

@interface SettingsViewController_iphone()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong)NSArray *settingsArray;
@property (strong, nonatomic) IBOutlet UISwitch *disclaimerSwitch;
@property (strong, nonatomic) NSUserDefaults *prefs;

- (void) setUpBarTitle;


@end

@implementation SettingsViewController_iphone


#pragma mark - Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.settingsArray = [[NSArray alloc ]initWithObjects:@"Last Sync Date",@"Show Disclaimer",@"Sync Now",nil];
    self.prefs = [NSUserDefaults standardUserDefaults];
    if([self.prefs objectForKey:kShowDisclaimer] == nil){
            //Default is yes
        [self.prefs setObject:@"Yes" forKey:kShowDisclaimer];
    }
    self.disclaimerSwitch.tag = 1;
    
    [self.disclaimerSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

    [self setUpBarTitle];
    [super viewDidLoad];
}

- (void)viewDidUnload{
    self.settingsArray = nil;
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated {
    if([self.request isExecuting])
        [self.request clearDelegatesAndCancel];
    [super viewWillDisappear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.settingsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *SettingTableIdentifier = @"SettingTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SettingTableIdentifier];
	if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingTableIdentifier"];
		UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        [[cell textLabel] setFont:titleFont];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch( [indexPath row]) {
                
            case(0):{
                self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 12, 100, 30)];
                self.dateLabel.backgroundColor = [UIColor clearColor];
                self.dateLabel.textColor = [UIColor blackColor];
                
                
                if([self.prefs objectForKey:kLastSyncDateKey] == nil){
                    self.dateLabel.text = [NSString getStringFromDate:[AsamUtility fetchAndFomatLastSyncDate]];
                }else
                    self.dateLabel.text = [self.prefs objectForKey:kLastSyncDateKey];
                cell.accessoryView = self.dateLabel;
                
                [cell addSubview:self.dateLabel];
                cell.textLabel.text = [self.settingsArray objectAtIndex:[indexPath row]];
                break;
            }
            case(1):{
                self.disclaimerSwitch =  [[ UISwitch alloc ] initWithFrame: CGRectZero ];
                
                self.disclaimerSwitch.on = ([[self.prefs objectForKey:kShowDisclaimer] isEqualToString:@"Yes"]) ? YES : NO;
                self.disclaimerSwitch.tag = 1;
                [self.disclaimerSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = self.disclaimerSwitch;
                
                [ cell addSubview: self.disclaimerSwitch ];
                
                cell.textLabel.text = [self.settingsArray objectAtIndex:[indexPath row]];
                break;
            }

            case(2):{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button addTarget:self action:@selector(fetchAllAsamsFromLastSyncedDate:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:@"Sync Now" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateHighlighted)];
                button.frame =  CGRectMake(20, 10, 280, 30);
                button.tag = 3;
                [button addGradient:button];
                [cell addSubview:button];
                    //  [cell.contentView addSubview:button];

                break;
            }
                
            default:{
                break;
            }
        }
        
	}
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}



#pragma 
#pragma mark - Bar title set up
- (void)setUpBarTitle{
        //Set up about button
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText: @"ASAM Settings"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [backImage setFrame:self.tableView.frame];
    self.tableView.backgroundView = backImage;
}

#pragma
#pragma mark - UISwitch Action/ControlEventTarget Actions
- (void)switchAction:(UISwitch*)sender{
    NSLog(@"sender is %i", [sender isOn]);
    
    if([sender isOn])
        [self.prefs setObject:@"Yes" forKey:kShowDisclaimer];
    else
        [self.prefs setObject:@"No" forKey:kShowDisclaimer];
    
     
}


@end
