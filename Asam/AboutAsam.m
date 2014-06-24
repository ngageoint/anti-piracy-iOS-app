#import "AboutAsam.h"
#import "LegalViewController_ipad.h"
#import <MessageUI/MessageUI.h>


@interface AboutAsam() <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITabBarDelegate>

@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *emailButton;

- (IBAction)dismissView:(id)sender;
- (IBAction)emailAsamHelpDesk:(id)sender;

@end


@implementation AboutAsam

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // iOS 7+
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    }
    self.infoArray = @[@"Version", @"Legal Information"];
    NSString *backBarButtonTitle = @"About";
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.view.backgroundColor = [UIColor blackColor];
        [self.emailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.emailButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.emailButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        backBarButtonTitle = @"";
    }
    else {
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        backImage.frame = self.tableView.frame;
        self.tableView.backgroundView = backImage;
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backBarButtonTitle style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return  YES;
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)emailAsamHelpDesk:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        mailer.subject = @"ASAM app feedback";
        NSArray *toRecipients = @[@"mcdasam@nga.mil"];
        mailer.toRecipients = toRecipients;
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support sending email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - MFMailComposeController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {
	switch (result) {
		case MFMailComposeResultCancelled:
            break;
            
		case MFMailComposeResultSaved:
            break;
            
		case MFMailComposeResultSent:
            break;
            
		case MFMailComposeResultFailed:
            break;
            
		default:
            break;
	}
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UItableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIndentifier = @"Legal";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIndentifier];
        UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        cell.textLabel.font = titleFont;
        
		UIFont *detailFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        cell.detailTextLabel.font = detailFont;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = [self.infoArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        cell.userInteractionEnabled = NO;
    }
    else {
        cell.textLabel.text = [self.infoArray objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        LegalViewController_ipad  *legal = [[LegalViewController_ipad alloc]initWithNibName:@"LegalViewController_ipad" bundle:nil];
        [self.navigationController pushViewController:legal animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
