
#import "SettingsView.h"
#import "UIButton+ButtonGradient.h"
#import "AsamUtility.h"
#import "Reachability.h"
#import "DSActivityView.h"

@implementation SettingsView

@synthesize  settingsArray;
@synthesize asamUpdateDelegate = _asamUpdateDelegate;

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
        // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.settingsArray = [NSArray arrayWithObjects:@"Last Sync Date",@"Sync Now",nil];
    [self setUpBarTitle];
    [self.tableView reloadData];
    [super viewDidLoad];
}

- (void)viewDidUnload{
    self.settingsArray = nil;
    self.asamUpdateDelegate = nil;
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        // Return YES for supported orientations
    return NO;
}


#pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.settingsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    static NSString *SettingTableIdentifier = @"SettingTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SettingTableIdentifier];
	if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingTableIdentifier"];
		UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue Bold" size:16.0];
        [[cell textLabel] setFont:titleFont];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch( [indexPath row]) {
            case(0):{
                self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 12, 100, 20)];
                self.dateLabel.backgroundColor = [UIColor clearColor];
                self.dateLabel.textColor = [UIColor blackColor];
                
                
                if([defaults objectForKey:kLastSyncDateKey] == nil){
                    self.dateLabel.text = @"01/04/2012";
                }else
                    self.dateLabel.text = [defaults objectForKey:kLastSyncDateKey];
                cell.accessoryView = self.dateLabel;
                
                [cell addSubview:self.dateLabel];
                cell.textLabel.text = [self.settingsArray objectAtIndex:[indexPath row]]; 
                break;
            }
                
            case(1):{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button addTarget:self action:@selector(syncNow:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:@"Sync" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected | UIControlStateHighlighted)];
                button.frame =  CGRectMake(200, 8, 100, 30);
                cell.accessoryView = button;
                [button addGradient:button];
                [cell addSubview:button];
                cell.textLabel.text = [self.settingsArray objectAtIndex:[indexPath row]];
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


#pragma mark - ControlEventTarget Actions

- (void)switchAction:(UISwitch*)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([sender isOn])
        [prefs setObject:@"Yes" forKey:kConnectedKey];
    else
        [prefs setObject:@"No" forKey:kConnectedKey];
    [prefs synchronize];
}

- (void)switchDisclaimer:(UISwitch*)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([sender isOn])
        [prefs setObject:@"Yes" forKey:kShowDisclainer];
    else
        [prefs setObject:@"No" forKey:kShowDisclainer];
    [prefs synchronize];
}

-(void)updateAsam:(id)sender{
    [self.asamUpdateDelegate updateAsamFromDate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)syncNow:(id)sender{
    [self.asamUpdateDelegate updateAsamFromDate];
    
}
- (IBAction)dismissView:(id)sender {
//    [self. dismissPopoverAnimated:YES];
}

- (void)setUpBarTitle{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    
    self.tableView.backgroundView = imageView;


    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue Bold" size:16.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText: @"ASAM Settings"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}


@end
