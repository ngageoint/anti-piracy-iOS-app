#import "LegalViewController_ipad.h"
#import "LegalDetailsViewController_ipad.h"
#import "LegalDetailsViewController_ipad.h"

@interface LegalViewController_ipad () <UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSArray *legalTitleArray;
@property(strong, nonatomic) NSArray *legalFileArray;

@end

@implementation LegalViewController_ipad

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Legal";
    NSString *navigationTitle = @"Legal";
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        navigationTitle = @"";
    }
    else {
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        backImage.frame = self.tableView.frame;
        self.tableView.backgroundView = backImage;
    }
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:navigationTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        
    self.legalTitleArray = @[@"REVClusterMap", @"Reachability", @"DSActivityView", @"DDActionHeaderView", @"Natural Earth"];
    self.legalFileArray = @[@"revclustermap", @"reachability", @"dsactivityview", @"ddactionheaderview", @"naturalearth"];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    else {
        return self.legalTitleArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        cell.textLabel.font = titleFont;
        
		UIFont *detailFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        cell.detailTextLabel.font = detailFont;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Disclaimer";
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = @"ASAM app";
    }
    else if(indexPath.section == 2) {
        cell.textLabel.text = [self.legalTitleArray objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LegalDetailsViewController_ipad *legalController = [[LegalDetailsViewController_ipad alloc]initWithNibName:@"LegalDetailsViewController_ipad" bundle:nil];
    if (indexPath.section == 0) {
        legalController.fileName = @"ngadisclaimer";
        legalController.titleString = @"NGA Disclaimer";
    }
    else if(indexPath.section == 1) {
        legalController.fileName = @"asamapp";
        legalController.titleString = @"ASAM App";
    }
    else if(indexPath.section == 2) {
        legalController.fileName = [self.legalFileArray objectAtIndex:indexPath.row];
        legalController.titleString = [self.legalTitleArray objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:legalController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *value = @"";
    if(section == 0) {
        value =  @"NGA Disclaimer";
    }
    else if (section == 1) {
        value =   @"NGA Privacy Policy";
    }
    else if(section == 2) {
        value =  @"Third Party Licenses";
    }
    return value;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [view addSubview:label];
    return view;
}
@end
