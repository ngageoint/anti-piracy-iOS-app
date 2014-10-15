#import "AsamListView.h"
#import "AsamUtility.h"
#import "AppDelegate.h"
#import "AsamCustomCell.h"
#import "REVClusterPin.h"
#import "AsamUtility.h"


@interface AsamListView() <UIActionSheetDelegate> {
    UINib *_cellLoader;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AsamUtility *asamUtil;

- (void)showActionSheet;
- (void)prepareNavBar;
- (void)sortAsamArrayWithVictimQualifier;
- (void)sortAsamArrayWithAggressorQualifier;
- (void)sortAsamArrayWithDateQualifierDescending;
- (void)sortAsamArrayWithDateQualifierAscending;


@end


@implementation AsamListView

static NSString *CellClassName = @"AsamCustomCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _asamUtil = [[AsamUtility alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareNavBar];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    self.asamArray = nil;
    self.asamDetailView = nil;
    self.tableView  = nil;
    self.asamUtil = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    CGSize size = CGSizeMake(320, 500); // size of view in popover
    self.contentSizeForViewInPopover = size;
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.asamArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AsamCustomCell *cell = (AsamCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellClassName];
    if (!cell) {
        if(_cellLoader == nil) {
            _cellLoader = [UINib nibWithNibName:CellClassName bundle:[NSBundle mainBundle]];
        }
        NSArray *topLevelItems = [_cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];  
		if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    cell.asam = [self.asamArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
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
-(void)prepareNavBar {
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"Sort"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(showActionSheet)];
    
    self.navigationItem.rightBarButtonItem = listButton;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 44)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = [NSString stringWithFormat:@"%lu ASAM(s)", (unsigned long)self.asamArray.count];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.separatorColor = [UIColor whiteColor];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.tableView.backgroundColor = [UIColor colorWithWhite:(64/255.0f) alpha:1.0f];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
}

#pragma 
#pragma mark - Private methods (UIActionSheet) impl.
- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort By:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Victim", @"Aggressor", @"Date Ascending", @"Date Descending", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        [self sortAsamArrayWithVictimQualifier];
    }
	else if (buttonIndex == 1) {
        [self sortAsamArrayWithAggressorQualifier];
    }
	else if(buttonIndex == 2) {
        [self sortAsamArrayWithDateQualifierDescending];
    }
    else if(buttonIndex == 3) {
        [self sortAsamArrayWithDateQualifierAscending];
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
