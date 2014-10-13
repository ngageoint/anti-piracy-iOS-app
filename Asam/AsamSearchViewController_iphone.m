#import "AsamSearchViewController_iphone.h"
#import "AsamUtility.h"
#import "AppDelegate.h"
#import "AsamResultViewController_iphone.h"
#import "UIButton+ButtonGradient.h"
#import "AsamFetch.h"
#import "DSActivityView.h"

#define kOFFSET_FOR_KEYBOARD 150.0

@interface AsamSearchViewController_iphone() <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *subRegions;
@property (nonatomic, assign) NSInteger selectedSubRegionIndex;
@property (nonatomic, strong) NSDate *selectedDateFrom;
@property (nonatomic, strong) NSDate *selectedDateTo;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePickerFromView;
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
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)resetSearchFields:(id)sender;
- (IBAction)prepareQuery:(id)sender;

- (void)dateFromWasSelected:(NSDate *)dateFromIndex;
- (void)cancelButtonPressedFrom:(id)sender;
- (void)dateToWasSelected:(NSDate *)dateToIndex;
- (void)cancelButtonPressedTo:(id)sender;
- (void)cancelSubRegionButton:(id)sender;
- (void)queryAsam:(id)sender;
- (void)loadSubregions;
- (void)setUpBarTitle;
- (NSString *)formattedDateAsString:(NSDate *)date;

@end


@implementation AsamSearchViewController_iphone


#pragma mark
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBarTitle];
    [self loadSubregions];
    [self.searchButton addBackgroundToButton:self.searchButton];
    [self.resetButton addBackgroundToButton:self.resetButton];
    
    [self createDateFromView];
    [self createDateToView];
    [self createSubregionView];
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], doneButton, nil]];
    self.refNumber.inputAccessoryView = keyboardDoneButtonView;
    self.refNumberYear.inputAccessoryView = keyboardDoneButtonView;
    
}

#pragma mark
#pragma mark - Memory Mgmt

- (IBAction)doneClicked:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) createDateFromView {
    self.datePickerFromView = [[UIDatePicker alloc] init];
    [self.datePickerFromView sizeToFit];
    self.datePickerFromView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.datePickerFromView.backgroundColor = [UIColor whiteColor];
    self.datePickerFromView.date = [NSDate date];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressedFrom:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateFromWasSelected:)];
    NSArray *barItems = @[cancelBtn, flexSpace, doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [cancelBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [doneBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    self.dateFrom.inputAccessoryView = pickerToolbar;
    self.dateFrom.inputView = self.datePickerFromView;
}

- (void)cancelButtonPressedFrom:(id)sender {
    [self.dateFrom resignFirstResponder];
}

- (void)dateFromWasSelected:(NSDate *)dateFromIndex {
    self.dateFrom.text = [self formattedDateAsString:self.datePickerFromView.date];
    [self cancelButtonPressedFrom:nil];
}

#pragma mark
#pragma mark - Date To
- (void)createDateToView {
    
    self.datePickerToView = [[UIDatePicker alloc] init];
    [self.datePickerToView sizeToFit];
    self.datePickerToView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.datePickerToView.backgroundColor = [UIColor whiteColor];
    self.datePickerToView.date = [NSDate date];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressedTo:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateToWasSelected:)];
    NSArray *barItems = @[cancelBtn, flexSpace, doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [cancelBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [doneBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    self.dateTo.inputAccessoryView = pickerToolbar;
    self.dateTo.inputView = self.datePickerToView;
}

- (void)dateToWasSelected:(NSDate *)dateFromIndex {
    self.dateTo.text = [self formattedDateAsString:self.datePickerToView.date];
    [self cancelButtonPressedTo:nil];
}

- (void)cancelButtonPressedTo:(id)sender {
    [self.dateTo resignFirstResponder];
}

#pragma mark
#pragma mark - Subregions
- (void)createSubregionView {
    const CGFloat toolbarHeight = 44.0f;
    self.subRegionsPickerView = [[UIPickerView alloc] init];
    [self.subRegionsPickerView sizeToFit];
	self.subRegionsPickerView.delegate = self;
	self.subRegionsPickerView.dataSource = self;
	self.subRegionsPickerView.showsSelectionIndicator = YES;
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSubRegionButton:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSubRegionButton:)];
    NSArray *barItems = @[cancelBtn, flexSpace, doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [cancelBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [doneBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    
    self.selectedSubRegion.inputView = self.subRegionsPickerView;
    self.selectedSubRegion.inputAccessoryView = pickerToolbar;
}

- (void)cancelSubRegionButton:(id)sender {
    [self.selectedSubRegion resignFirstResponder];
}

- (void)doneSubRegionButton: (id)sender {
    self.selectedSubRegion.text = [self.subRegions objectAtIndex:[self.subRegionsPickerView selectedRowInComponent:0]];
    [self cancelSubRegionButton:sender];
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    self.selectedSubRegion.text = [self.subRegions objectAtIndex:row];
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
    [self.victim resignFirstResponder];
    [self.aggressor resignFirstResponder];
    [self.refNumberYear resignFirstResponder];
    [self.refNumber resignFirstResponder];
    NSMutableArray *queryParams = [NSMutableArray array];
    
    // Validate that we have at least one value
    if (self.selectedSubRegion.text.length == 0 && self.dateFrom.text.length == 0 && self.dateTo.text.length == 0
       && self.victim.text.length == 0 && self.aggressor.text.length == 0 && self.refNumber.text.length == 0 && self.refNumberYear.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Missing Values" message:@"One search criteria is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }
    if ((self.refNumber.text.length == 0 && self.refNumberYear.text.length > 0) || (self.refNumber.text.length > 0 && self.refNumberYear.text.length == 0)) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Reference Number Error" message:@"You must enter a valid ASAM ref number for Reference Number search." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    [DSBezelActivityView activityViewForView:self.view withLabel:@"Fetching Asam(s)..." width:160];
    [self performSelector:@selector(queryAsam:) withObject:finalQueryParam afterDelay:0.01];
}

- (IBAction)textFieldFinished:(id)sender {
    
}

- (void)queryAsam:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = [appDelegate persistentStoreCoordinator];
    
    NSArray *resultArray  = [context fetchObjectsForEntityName:@"Asam" withPredicate:sender];
    if (resultArray.count == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"0 ASAM found" message:@"Try different query." delegate:nil cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [message show];
        [DSBezelActivityView removeViewAnimated:YES];
    }
    else {
        AsamResultViewController_iphone *asamResultViewController_iphone = [[AsamResultViewController_iphone alloc] initWithNibName:@"AsamResultViewController_iphone" bundle:nil];
        asamResultViewController_iphone.asamArray = resultArray;
        [DSBezelActivityView removeViewAnimated:YES];
        [self.navigationController pushViewController:asamResultViewController_iphone animated:YES];
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
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"ASAM Query";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

- (NSString *)formattedDateAsString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    NSString *str = [formatter stringFromDate:date];
    return  str;
}

@end
