#import "AsamListViewController_iphone.h"
#import "AsamListView.h"
#import "AsamUtility.h"
#import "AppDelegate.h"
#import "AsamCustomCell.h"

@interface AsamListViewController_iphone() <UIActionSheetDelegate> {
    
UINib *cellLoader;
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AsamDetailView *asamDetailView;

- (void)prepareNavBar;
- (void)segmentAction:(UISegmentedControl*)sender;
- (IBAction)showActionSheet;
- (void)sortAsamArrayWithVictimQualifier;
- (void)sortAsamArrayWithAggressorQualifier;
- (void)sortAsamArrayWithDateQualifierDescending;
- (void)sortAsamArrayWithDateQualifierAscending;

@end


@implementation AsamListViewController_iphone

static NSString *CellClassName = @"AsamCustomCell";

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (cellLoader == nil) {
        cellLoader = [UINib nibWithNibName:CellClassName bundle:[NSBundle mainBundle]];
    }
    [self prepareNavBar];
}

- (void)viewDidUnload{
    self.asamArray = nil;
    self.asamDetailView = nil;
    self.tableView  = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Unselect the selected row if any
	NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
	if (selection) {
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.asamArray.count;
}

    // Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AsamCustomCell *cell = (AsamCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellClassName];
    if (!cell) {
        NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType =  UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    cell.asam = [self.asamArray objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    AsamDetailView *asamDetailView = [[AsamDetailView alloc] initWithNibName:@"AsamDetailView" bundle:nil];
    REVClusterPin *managedObject = [self.asamArray objectAtIndex:indexPath.row];
    asamDetailView.asam = managedObject;
    [self.navigationController pushViewController:asamDetailView animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AsamDetailView *asamDetailView= [[AsamDetailView alloc] initWithNibName:@"AsamDetailView" bundle:nil];
    REVClusterPin *managedObject = [self.asamArray objectAtIndex:indexPath.row];
    asamDetailView.asam = managedObject;
    [self.navigationController pushViewController:asamDetailView animated:YES];
}

#pragma mark -
#pragma mark helper methods
- (void)prepareNavBar {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.tableView.backgroundColor = [UIColor blackColor];
    }
    else {
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        [backImage setFrame:self.tableView.frame];
        self.tableView.backgroundView = backImage;
    }
    
    NSString *title = @"";
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // < iOS 7
        title = @"Back";
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
    backButton.tintColor = [UIColor blackColor];
    self.navigationItem.backBarButtonItem = backButton;

    
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Sort"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(showActionSheet)];
    
    self.navigationItem.rightBarButtonItem = sortButton;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 40)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = [NSString stringWithFormat:@"%lu ASAM(s)", (unsigned long)self.asamArray.count];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

#pragma
#pragma mark - Private methods (UIActionSheet) impl.
- (IBAction)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort By:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Victim", @"Aggressor", @"Date Ascending", @"Date Descending", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self sortAsamArrayWithVictimQualifier];
            break;
            
        case 1:
            [self sortAsamArrayWithAggressorQualifier];
            break;
            
        case 2:
            [self sortAsamArrayWithDateQualifierDescending];
            break;
            
        case 3:
            [self sortAsamArrayWithDateQualifierAscending];
            break;
            
        default:
            break;
    }
}

- (void)sortAsamArrayWithVictimQualifier {
    self.asamArray = [self.asamArray sortedArrayUsingSelector:@selector(victimComparison:)];
    [self.tableView reloadData];
}

- (void)sortAsamArrayWithAggressorQualifier {
    self.asamArray = [self.asamArray sortedArrayUsingSelector:@selector(aggressorComparison:)];
    [self.tableView reloadData];
}

- (void)sortAsamArrayWithDateQualifierDescending {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateofOccurrence" ascending:YES selector:@selector(compare:)];
    NSArray *sortDescriptors = @[dateDescriptor];
    self.asamArray = [self.asamArray sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
}

- (void)sortAsamArrayWithDateQualifierAscending {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateofOccurrence" ascending:NO selector:@selector(compare:)];
    NSArray *sortDescriptors = @[dateDescriptor];
    self.asamArray = [self.asamArray sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
}

@end
