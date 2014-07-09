#import "AsamMap_iphone.h"
#import "DSActivityView.h"
#import <dispatch/dispatch.h>
#import "AsamListViewController_iphone.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "AsamUtility.h"
#import "Asam.h"
#import "AsamFetch.h"
#import "AsamListView.h"
#import "AsamDetailView.h"
#import "REVClusterMap.h"
#import "REVClusterAnnotationView.h"

#pragma
#pragma mark - Private Methods i(UIActivityIndicator)
@interface AsamMap_iphone() <UIActionSheetDelegate, MKMapViewDelegate>

@property (nonatomic, strong) AsamUtility *asamUtil;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *asamArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) IBOutlet REVClusterMapView *mapView;
@property (nonatomic, strong) NSMutableArray *asamResults;
@property (nonatomic, strong) NSString *numberOfDaysToFetch;
@property (nonatomic, strong) UILabel *countLabel;


- (void)populateAsamsInMap:(id)sender;
- (void)prepareNavBar;
- (void)segmentAction:(UISegmentedControl*)sender;
- (void)fetchAsams:(id) sender;
- (void)populateAsamPins;
- (void)clearAndResetMap;
- (void)updateCountLabel:(NSString *)text;

- (IBAction)showActionSheetForQuery;
- (IBAction)showActionSheetForMapType;
- (IBAction)viewAsamsAsList;

@end

@implementation AsamMap_iphone

#pragma mark -  Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.countLabel];
    [self.view addSubview:self.mapView];
    [self prepareNavBar];
    self.numberOfDaysToFetch = @"365";
    [self performSelector:@selector(populateAsamsInMap:) withObject:@"365" afterDelay:0.2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mapView = nil;
    self.countLabel = nil;
    self.asamArray = nil;
    self.actionSheet = nil;
    self.numberOfDaysToFetch = nil;
    self.asamResults = nil;
    self.segmentedControl = nil;
    self.mapView.delegate = nil;
    self.asamUtil = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Utility functions
- (void)fetchAsams:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = [appDelegate persistentStoreCoordinator];
    
    if ([sender isEqualToString:@"All"]) {
        self.asamArray= [context fetchObjectsForEntityName:@"Asam"];
    }
    else {
        NSString *formattedDays =  [AsamUtility subtractDaysWithParamfromToday:sender];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateofOccurrence >=%@", [AsamUtility getDateFromString:formattedDays]];
        self.asamArray  = [context fetchObjectsForEntityName:@"Asam" withPredicate:predicate];
    }
    if (self.asamArray.count == 0){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"0 ASAM found" message:@"Select a different search parameter." delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [message show];
        return;
    }
    
    [self populateAsamPins];
    
    NSString *asamFounds = [NSString stringWithFormat:@"%lu ASAM(s)", (unsigned long)self.asamArray.count];
    NSString *inDays = @"";
    if ([self.numberOfDaysToFetch isEqualToString:@"All"]) {
        inDays = @"in all ASAM(s)";
    }
    else {
        inDays =[NSString stringWithFormat:@"in last %@ days", self.numberOfDaysToFetch];
    }
    
    [self updateCountLabel:[NSString stringWithFormat: @"%@ %@", asamFounds, inDays]];
    
}

- (void)prepareNavBar {
    NSString *title = @"";
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // < iOS 7
        title = @"Map";
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
    backButton.tintColor = [UIColor blackColor];
    self.navigationItem.backBarButtonItem = backButton;
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Reset", @"Query",@"List View",@"Map"]];
    self.segmentedControl.tag = 3;
    [self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.momentary = YES;
    [self.segmentedControl sizeToFit];
    self.segmentedControl.opaque = TRUE;
    [self.segmentedControl setWidth:65.0 forSegmentAtIndex:2];
    self.segmentedControl.tintColor = [UIColor blackColor];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) { // iOS 7+
        [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    }
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    self.asamUtil = [[AsamUtility alloc] init];
}

- (void)segmentAction:(UISegmentedControl*)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self clearAndResetMap];
            break;
        case 1:
            [self showActionSheetForQuery];
            break;
            
        case 2:
            [self viewAsamsAsList];
            break;
        case 3:
            [self showActionSheetForMapType];
            break;
        default:
            break;
    }
}

- (IBAction)showActionSheetForQuery {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select the number of days to query:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Last 60 days", @"Last 90 days", @"Last 180 days", @"Last 1 Year", @"All", nil];
    [self.actionSheet showInView:self.view];
}

- (IBAction)showActionSheetForMapType {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select the map type:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Standard", @"Satellite", @"Hybrid", @"Offline", nil];
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet title] isEqualToString:@"Select the map type:"]) {
        
        
        switch (buttonIndex) {
            case 0:
                _mapView.mapType = MKMapTypeStandard;
                break;
            case 1:
                _mapView.mapType = MKMapTypeSatellite;
                break;
            case 2:
                _mapView.mapType = MKMapTypeHybrid;
                break;
            default:
                break;
        }
        
    }
    else {
        switch (buttonIndex) {
            case 0:
                self.numberOfDaysToFetch = @"60";
                [self populateAsamsInMap:self.numberOfDaysToFetch];
                break;
                
            case 1:
                self.numberOfDaysToFetch = @"90";
                [self populateAsamsInMap:self.numberOfDaysToFetch];
                break;
                
            case 2:
                self.numberOfDaysToFetch = @"180";
                [self populateAsamsInMap:self.numberOfDaysToFetch];
                break;
                
            case 3:
                self.numberOfDaysToFetch = @"365";
                [self populateAsamsInMap:self.numberOfDaysToFetch];
                break;
                
            case 4:
                self.numberOfDaysToFetch = @"All";
                [self populateAsamsInMap:self.numberOfDaysToFetch];
                break;
                
            default:
                break;
        }
    }

}

- (void)updateCountLabel:(NSString *)text {

    // remove all labels from mapView
    for (UIView *labelView in self.mapView.subviews) {
        if ([labelView isKindOfClass:[UILabel class]]) {
            [labelView removeFromSuperview];
        }
    }
    
    //build label and add to mapView
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 0, 0)];
    [_countLabel setTextColor:[UIColor whiteColor]];
    [_countLabel setBackgroundColor:[UIColor grayColor]];
    [_countLabel setAlpha:0.9];
    [_countLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10.0]];
    [_countLabel setText:text];
    [_countLabel sizeToFit];
    
    [self.mapView addSubview:_countLabel];
    
}

- (void)clearAndResetMap {
    self.numberOfDaysToFetch = @"365";
    [self populateAsamsInMap:self.numberOfDaysToFetch];
}

- (void)populateAsamPins {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    self.asamResults = [[NSMutableArray alloc] init];

    for (NSManagedObject *asamManagedObject in self.asamArray) {
        __weak Asam *asam = (Asam *)asamManagedObject;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([asam.decimalLatitude doubleValue], [asam.decimalLongitude doubleValue]);
        REVClusterPin *pin = [[REVClusterPin alloc] init];
        pin.title = asam.victim;
        pin.subtitle = [formatter stringFromDate:asam.dateofOccurrence];
        pin.victim = asam.victim;
        pin.dateofOccurrence = asam.dateofOccurrence;
        pin.geographicalSubregion = asam.geographicalSubregion;
        pin.aggressor = asam.aggressor;
        pin.asamDescription = asam.asamDescription;
        pin.referenceNumber = asam.referenceNumber;
        pin.degreeLatitude = [asam formatLatitude];
        pin.degreeLongitude = [asam formatLongitude];
        pin.coordinate = coordinate;
        [self.asamResults addObject:pin];
    }
    
    [self.mapView addAnnotations:self.asamResults];
    self.mapView.region = MKCoordinateRegionForMapRect(MKMapRectWorld);
}

- (IBAction)viewAsamsAsList {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateofOccurrence" ascending:NO selector:@selector(compare:)];
    NSArray *sortDescriptors = @[dateDescriptor];
    AsamListViewController_iphone *asamListView = [[AsamListViewController_iphone alloc] initWithNibName:@"AsamListViewController_iphone" bundle:nil];
    asamListView.asamArray = [self.asamResults sortedArrayUsingDescriptors:sortDescriptors];
    [self.navigationController pushViewController:asamListView animated:YES];
}

#pragma
#pragma mark - Map Views
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation class] == MKUserLocation.class) {
        
        // userLocation - do nothing
        return nil;
    }
    
    REVClusterPin *pin = (REVClusterPin *)annotation;
        
    MKAnnotationView *annView;
    if (pin.nodeCount > 0 ) {
        pin.title = [NSString stringWithFormat:@"%lu%@", (unsigned long)[pin nodeCount], @" Asams"];
        annView = (REVClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
        if (!annView) {
            annView = (REVClusterAnnotationView*)[[REVClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"cluster"];
        }
        annView.image = [UIImage imageNamed:@"cluster.png"];
        [(REVClusterAnnotationView*)annView setClusterText:[NSString stringWithFormat:@"%lu", (unsigned long)[pin nodeCount]]];
        annView.canShowCallout = YES;
        annView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else {
        annView = (REVClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (!annView) {
            annView = (REVClusterAnnotationView*)[[REVClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        }
        annView.image = [UIImage imageNamed:@"pirate"];
        annView.canShowCallout = YES;
        annView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annView.calloutOffset = CGPointMake(-6.0, 0.0);
    }
    return annView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    REVClusterPin *selectedObject = (REVClusterPin *) view.annotation;
    if (selectedObject.nodeCount > 1) {
        AsamListViewController_iphone *asamListView = [[AsamListViewController_iphone alloc] initWithNibName:@"AsamListViewController_iphone" bundle:nil];
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateofOccurrence" ascending:NO selector:@selector(compare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
        asamListView.asamArray = [[selectedObject nodes] sortedArrayUsingDescriptors:sortDescriptors];
        [self.navigationController pushViewController:asamListView animated:YES];
    }
    else {
        AsamDetailView *asamDetailView = [[AsamDetailView alloc] initWithNibName:@"AsamDetailView" bundle:nil];
        asamDetailView.asam = selectedObject;
        [self.navigationController pushViewController:asamDetailView animated:YES];
    }
}

#pragma
#pragma mark - Private methods (UIActivityIndicator) impl.
- (void)populateAsamsInMap:(id)sender {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [DSBezelActivityView activityViewForView:self.view withLabel:@"Fetching Asam(s)..." width:160];
        
        if (self.mapView.annotations != nil && self.mapView.annotations.count > 0) {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchAsams:sender];
        });
        dispatch_async(mainQueue, ^{
            [DSBezelActivityView removeViewAnimated:YES];
        });
    });
}

- (void)dealloc {
    self.mapView.delegate = nil;
}

@end
