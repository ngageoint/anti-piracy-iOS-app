#import "LegalViewController_iphone.h"
#import "LegalDetailsViewController_iPhone.h"

@interface LegalViewController_iphone () <UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSArray *legalTitleArray;
@property(strong, nonatomic) NSArray *legalFileArray;

@end

@implementation LegalViewController_iphone

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
    
    self.legalTitleArray = @[@"REVClusterMap", @"Reachability", @"DSActivityView", @"DDActionHeaderView"];
    self.legalFileArray = @[@"revclustermap", @"reachability", @"dsactivityview", @"ddactionheaderview"];
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
        
		UIFont *detailFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:1.0];
        cell.detailTextLabel.font = detailFont;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if(indexPath.section == 0){
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    LegalDetailsViewController_iPhone *legalController = [[LegalDetailsViewController_iPhone alloc] initWithNibName:@"LegalDetailsViewController_iPhone" bundle:nil];
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
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *value = @"";
    if (section == 0) {
        value = @"NGA Disclaimer";
    }
    else if (section == 1) {
        value = @"NGA Privacy Policy";
    }
    else if(section == 2) {
        value = @"Third Party Licenses";
    }
    return value;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
        tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        tableViewHeaderFooterView.textLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        tableViewHeaderFooterView.textLabel.textColor = [UIColor whiteColor];
    }
}

@end
