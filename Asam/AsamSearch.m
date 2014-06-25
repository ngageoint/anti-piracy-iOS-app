#import "AsamSearch.h"
#import "AsamUtility.h"
#import "AppDelegate.h"
#import "UIButton+ButtonGradient.h"

# define kOFFSET_FOR_KEYBOARD 150.0

@interface AsamSearch() <UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *subRegions;
@property (nonatomic, assign) NSInteger selectedSubRegionIndex;
@property (nonatomic, strong) NSDate *selectedDateFrom;
@property (nonatomic, strong) NSDate *selectedDateTo;
@property (nonatomic, strong) UIDatePicker *datePickerFromView;
@property (nonatomic, strong) UIActionSheet *datePickerFromActionSheet;
@property (nonatomic, strong) UIDatePicker *datePickerToView;
@property (nonatomic, strong) UIActionSheet *datePickerToActionSheet;
@property (nonatomic, strong) UIActionSheet *subRegionsActionSheet;
@property (nonatomic, strong) UIPickerView *subRegionsPickerView;
@property (nonatomic, strong) IBOutlet UITextField *refNumberYear;
@property (nonatomic, strong) IBOutlet UITextField *refNumber;
@property (nonatomic, strong) IBOutlet UITextField *aggressor;
@property (nonatomic, strong) IBOutlet UITextField *victim;
@property (nonatomic, strong) IBOutlet UITextField *selectedSubRegion;
@property (nonatomic, strong) IBOutlet UITextField *dateFrom;
@property (nonatomic, strong) IBOutlet UITextField *dateTo;
@property (nonatomic, strong) NSArray *asamArray;
@property (nonatomic, strong) NSArray *asamResults;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;

- (IBAction)selectDateFromSheet:(id)sender;
- (IBAction)selectDateToSheet:(id)sender;
- (IBAction)selectSubRegionSheet:(id)sender;
- (IBAction)resetSearchFields:(id)sender;
- (IBAction)prepareQuery:(id)sender;
- (IBAction)textFieldDidEndEditing:(id)sender;
- (IBAction)textFieldDidBeginEditing:(id)sender;

- (void)dateFromWasSelected:(NSDate *)dateFromIndex;
- (void)cancelButtonPressedFrom:(id)sender;
- (void)dateToWasSelected:(NSDate *)dateToIndex;
- (void)cancelButtonPressedTo:(id)sender;
- (void)cancelSubRegionButton:(id)sender;
- (void)loadSubregions;
- (void)setUpBarTitle;
- (NSString *)formattedDateAsString:(NSDate *)date;

@end


@implementation AsamSearch

#pragma mark
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBarTitle];
    [self loadSubregions];
    [self.searchButton addBackgroundToButton:self.searchButton];
    [self.resetButton addBackgroundToButton:self.resetButton];
}

- (void)viewDidUnload {
    self.subRegions = nil;
    self.selectedDateFrom = nil;
    self.selectedDateTo = nil;
    self.datePickerFromView = nil;
    self.datePickerFromActionSheet = nil;
    self.datePickerToView = nil;
    self.datePickerToActionSheet = nil;
    self.subRegionsActionSheet = nil;
    self.subRegionsPickerView = nil;
    self.victim = nil;
    self.aggressor = nil;
    self.dateTo = nil;
    self.dateFrom = nil;
    self.refNumber = nil;
    self.refNumberYear = nil;
    self.selectedSubRegion = nil;
    self.asamSearchDelegate = nil;
    self.searchButton = nil;
    self.resetButton = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Needed for when a user hists the search button instead of the Done button
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.victim resignFirstResponder];
    [self.aggressor resignFirstResponder];

}

#pragma mark 
#pragma mark - Memory Mgmt
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark 
#pragma mark - Date From
- (IBAction)selectDateFromSheet:(id)sender {
    const CGFloat toolbarHeight = 44.0f;
    self.datePickerFromActionSheet = [[UIActionSheet alloc] init];
    self.datePickerFromView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolbarHeight, 0, 0)];
    self.datePickerFromView.datePickerMode = UIDatePickerModeDate;
    self.datePickerFromView.hidden = NO;
    self.datePickerFromView.backgroundColor = [UIColor whiteColor];
    self.datePickerFromView.date = [NSDate date];

    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    pickerToolbar.translucent = YES;
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressedFrom:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateFromWasSelected:)];
    NSArray *barItems = @[cancelBtn, flexSpace, doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [cancelBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [doneBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    
    [self.datePickerFromActionSheet addSubview:pickerToolbar];
    [self.datePickerFromActionSheet addSubview:self.datePickerFromView];
    [self.datePickerFromActionSheet showInView:self.view];
    self.datePickerFromActionSheet.bounds = CGRectMake(0, 0, 320, 464);
}

- (void)cancelButtonPressedFrom:(id)sender {
    [self.datePickerFromActionSheet dismissWithClickedButtonIndex:1 animated:YES];
}  

- (void)dateFromWasSelected:(NSDate *)dateFromIndex {
    self.dateFrom.text = [self formattedDateAsString:self.datePickerFromView.date];
    [self cancelButtonPressedFrom:nil];
}

#pragma mark 
#pragma mark - Date To
- (IBAction)selectDateToSheet:(id)sender {
    const CGFloat toolbarHeight = 44.0f;
    self.datePickerToActionSheet = [[UIActionSheet alloc] init];
    self.datePickerToView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolbarHeight, 0, 0)];
    self.datePickerToView.datePickerMode = UIDatePickerModeDate;
    self.datePickerToView.hidden = NO;
    self.datePickerToView.backgroundColor = [UIColor whiteColor];
    self.datePickerToView.date = [NSDate date];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    pickerToolbar.translucent = YES;
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressedTo:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateToWasSelected:)];
    NSArray *barItems = @[cancelBtn, flexSpace, doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [cancelBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [doneBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    
    [self.datePickerToActionSheet addSubview:pickerToolbar];
    [self.datePickerToActionSheet addSubview:self.datePickerToView];
    [self.datePickerToActionSheet showInView:self.view];
    self.datePickerToActionSheet.bounds = CGRectMake(0, 0, self.view.frame.size.width, 464);
}

- (void)dateToWasSelected:(NSDate *)dateFromIndex {
    self.dateTo.text = [self formattedDateAsString:self.datePickerToView.date];
    [self cancelButtonPressedTo:nil];    
}

- (void)cancelButtonPressedTo:(id)sender {
    [self.datePickerToActionSheet dismissWithClickedButtonIndex:1 animated:YES];
}  

#pragma mark 
#pragma mark - Subregions
- (IBAction)selectSubRegionSheet:(id)sender {
    const CGFloat toolbarHeight = 44.0f;
    self.subRegionsActionSheet = [[UIActionSheet alloc] init];
    self.subRegionsPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolbarHeight, 0, 0)];
	self.subRegionsPickerView.delegate = self;
	self.subRegionsPickerView.dataSource = self;
	self.subRegionsPickerView.showsSelectionIndicator = YES;
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSubRegionButton:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelSubRegionButton:)];
    NSArray *barItems = @[cancelBtn, flexSpace, doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [cancelBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [doneBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    
    [self.subRegionsActionSheet addSubview:pickerToolbar];
    [self.subRegionsActionSheet addSubview:self.subRegionsPickerView];
    [self.subRegionsActionSheet showInView:self.view];
    self.subRegionsActionSheet.bounds = CGRectMake(0, 0, self.view.frame.size.width, 464);
}

- (void)cancelSubRegionButton:(id)sender {
    [self.subRegionsActionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedSubRegion.text = [self.subRegions objectAtIndex:row];
}

#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.subRegions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.subRegions objectAtIndex:row];
}

#pragma mark -
- (IBAction)resetSearchFields:(id)sender {
    self.victim.text = nil;
    self.aggressor.text = nil;
    self.selectedSubRegion.text = nil;
    self.dateTo.text = nil;
    self.dateFrom.text = nil;
    self.selectedDateTo = nil;
    self.selectedDateFrom = nil;
    self.selectedSubRegionIndex = 0;
    self.refNumberYear.text = nil;
    self.refNumber.text = nil;
}

- (IBAction)prepareQuery:(id)sender {
    NSMutableArray *queryParams = [[NSMutableArray alloc] init];
    
    // Validate that we have at least one value
    if (self.selectedSubRegion.text.length == 0 && self.dateFrom.text.length == 0 && self.dateTo.text.length == 0 && self.victim.text.length == 0 && self.aggressor.text.length == 0 && self.refNumber.text.length == 0 && self.refNumberYear.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Missing Values" message:@"One search criteria is required." delegate:nil cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [message show];  
        return;
    }
    if ((self.refNumber.text.length == 0 && self.refNumberYear.text.length > 0 ) || (self.refNumber.text.length > 0 && self.refNumberYear.text.length == 0)) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Reference Number Error" message:@"You must enter a valid ASAM ref number for Reference Number search."delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];  
        return;
    }
    if (self.refNumber.text.length > 0 && self.refNumberYear.text.length > 0 ) {
        [queryParams addObject:[NSPredicate predicateWithFormat:@"referenceNumber == %@", [NSString stringWithFormat:@"%@-%@", self.refNumberYear.text, self.refNumber.text]]];
    }
    if (self.selectedSubRegion.text.length > 0) {
        [queryParams addObject:[NSPredicate predicateWithFormat:@"geographicalSubregion == %@", self.selectedSubRegion.text]];
    }
    if (self.dateFrom.text.length > 0) {
        [queryParams addObject:[NSPredicate predicateWithFormat:@"dateofOccurrence >= %@", [AsamUtility getDateFromString:self.dateFrom.text]]];
    }
    if (self.dateTo.text.length > 0) {
        [queryParams addObject:[NSPredicate predicateWithFormat:@"dateofOccurrence =< %@", [AsamUtility getDateFromString:self.dateTo.text]]];
    }
    if (self.victim.text.length > 0) {
        [queryParams addObject:[NSPredicate predicateWithFormat:@"victim CONTAINS [cd] %@", self.victim.text]];
    }
    if (self.aggressor.text.length > 0) {
        [queryParams addObject:[NSPredicate predicateWithFormat:@"aggressor CONTAINS [cd] %@", self.aggressor.text]];
    }
    NSString *joinedString = [queryParams componentsJoinedByString:@" AND "];    
    NSPredicate *finalQueryParam = [NSPredicate predicateWithFormat:joinedString];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.asamSearchDelegate setPredicateForSearching:finalQueryParam];
    }
}

- (IBAction)textFieldDidEndEditing:(id)sender {
    if([sender isEqual:self.victim]) {
        [self.victim resignFirstResponder];
    }
    else if ([sender isEqual:self.aggressor]) {
        [self.aggressor resignFirstResponder];
    }
    else if ([sender isEqual:self.refNumberYear]) {
        [self.refNumberYear resignFirstResponder];
    }
    else if ([sender isEqual:self.refNumber]) {
        [self.refNumber resignFirstResponder];
    }
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    if ([sender isEqual:self.aggressor]){
        if  (self.view.frame.origin.y >= 0) {
//            [self setViewMovedUp:YES];
        }
    }
    else if ([sender isEqual:self.victim]) {
        if (self.view.frame.origin.y >= 0) {
//            [self setViewMovedUp:YES];
        }
    }
}

- (void)loadSubregions {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];	
    context.persistentStoreCoordinator = [appDelegate persistentStoreCoordinator];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Asam" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[@"geographicalSubregion"];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        NSLog(@"Unabled to populate the subregions");
    }
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:objects.count];
    for (int i = 0; i < objects.count; i++) {
        [tmpArray addObject:[[objects objectAtIndex:i] valueForKey:@"geographicalSubregion"]];
    }
    
    self.subRegions = [tmpArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)setUpBarTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica Neue Bold" size:16.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"ASAM Query";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.navigationController.navigationBar.translucent = YES;
}

- (NSString *)formattedDateAsString:(NSDate *)date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    NSString* str = [formatter stringFromDate:date];
    return  str;
}

@end
