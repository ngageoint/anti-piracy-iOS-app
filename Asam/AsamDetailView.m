#import "AsamDetailView.h"
#import "NSString+ReplaceDegree.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface AsamDetailView() <MKMapViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AsamUtility *asamUtil;

- (void)setUpBarTitle;

@end


@implementation AsamDetailView

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBarTitle];
    CGSize size = CGSizeMake(320, 400); // size of view in popover
    self.contentSizeForViewInPopover = size;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.asam = nil;
    self.tableView = nil;
    self.asamUtil = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ASAM table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 6) {
        NSString *text = self.asam.asamDescription;
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 44.0f);
        return height + (CELL_CONTENT_MARGIN * 2);
    }
    else {
        return 50.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        cell.textLabel.font = titleFont;
        cell.textLabel.textColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
		UIFont *detailFont = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        cell.detailTextLabel.font = detailFont;
    }
    
	switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Date of Occurance";
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = [self.asamUtil getStringFromDate: _asam.dateofOccurrence];  
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
			break;
            
        case 1:
            cell.textLabel.text = @"Reference Number";
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = _asam.referenceNumber;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
			break;
            
        case 2:
            cell.textLabel.text = @"Geographical Subregion";
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = _asam.geographicalSubregion;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
			break;
            
        case 3:
            cell.textLabel.text = @"Geographic Location";
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%@, %@", _asam.degreeLatitude, _asam.degreeLongitude];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
            break;
            
        case 4:
            cell.textLabel.text = @"Aggressor";
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = _asam.aggressor;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
			break;
            
		case 5:
            cell.textLabel.text = @"Victim";
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = _asam.victim;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
			break;
            
        case 6:
            cell.textLabel.text = @"Description";
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.textColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = _asam.asamDescription;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
                [cell setBackgroundColor:[UIColor blackColor]];
            }
			break;
            
        default:
            break;
	}
	return cell;
}

- (void)setUpBarTitle {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.navigationController.navigationBar.backgroundColor = [UIColor colorWithWhite:(64/255.0f) alpha:1.0f];
        self.tableView.backgroundColor = [UIColor blackColor];
    }
    else {
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        [backImage setFrame:self.tableView.frame];
        self.tableView.backgroundView = backImage;
    }
    self.asamUtil = [[AsamUtility alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];

    titleLabel.text = @"ASAM Details";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

@end
