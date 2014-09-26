#import "AsamResultViewController_iphone.h"
#import "AppDelegate.h"
#import "AsamUtility.h"
#import "DSActivityView.h"
#import "AsamListViewController_iphone.h"
#import "AsamDetailView.h"
#import "REVClusterMap.h"
#import "REVClusterAnnotationView.h"
#import "Asam.h"
#import "OfflineMapUtility.h"


#pragma
#pragma mark - Private Methods 
@interface AsamResultViewController_iphone() <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet REVClusterMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *controlLabel;
@property (nonatomic, strong) NSMutableArray *asamResults;
@property (nonatomic, strong) AsamUtility *asamUtil;
@property (nonatomic, strong) UIBarButtonItem *listButton;

- (void)setUpSegment;
- (IBAction)viewAsamsAsList;
- (IBAction)startAnimation:(id)sender;
- (void)populateAsamPins;

@end


@implementation AsamResultViewController_iphone

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.asamUtil = [[AsamUtility alloc] init];
    
    [self setMapType: nil];
    [self setUpSegment];
    [self startAnimation:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.mapView = nil;
    self.asamArray = nil;
    self.asamResults = nil;
    self.asamUtil = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setUpSegment {
    
    
    self.listButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"List"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(viewAsamsAsList)];
    
    self.navigationItem.rightBarButtonItem = self.listButton;
}

- (void)segmentAction:(UISegmentedControl*)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self viewAsamsAsList];
            break;
            
        default:
            break;
    }
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
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation class] == MKUserLocation.class) {
        return nil;
    }
    
    REVClusterPin *pin = (REVClusterPin *)annotation;
    MKAnnotationView *annView;
    if (pin.nodeCount > 0) {
        pin.title = [NSString stringWithFormat:@"%lu Asams", (unsigned long)[pin nodeCount]];
        annView = (REVClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
        if (!annView) {
            annView = (REVClusterAnnotationView*)[[REVClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"cluster"];
        }
        annView.image = [UIImage imageNamed:@"cluster.png"];
        [(REVClusterAnnotationView*)annView setClusterText:[NSString stringWithFormat:@"%lu",(unsigned long)[pin nodeCount]]];
        annView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annView.canShowCallout = NO;
    }
    else {
        annView = (REVClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (!annView) {
            annView = (REVClusterAnnotationView*)[[REVClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        }
        annView.image = [UIImage imageNamed:@"pirate"];
        annView.canShowCallout = NO;
        annView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annView.calloutOffset = CGPointMake(-6.0, 0.0);
    }
    return annView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
        [mapView deselectAnnotation:view.annotation animated:YES];
        REVClusterPin *selectedObject = (REVClusterPin *)view.annotation;        
    if (selectedObject.nodeCount > 1) {
        AsamListViewController_iphone *asamListView = [[AsamListViewController_iphone alloc] initWithNibName:@"AsamListViewController_iphone" bundle:nil];
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateofOccurrence" ascending:NO selector:@selector(compare:)];
        NSArray *sortDescriptors = @[dateDescriptor];
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
#pragma mark - Populate Asam Pins with clustering
- (void)populateAsamPins {
    self.asamResults = [[NSMutableArray alloc] init];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    for (NSManagedObject *asamManagedObject in self.asamArray) {
        Asam *asam = (Asam*)[appDelegate.managedObjectContext objectWithID:asamManagedObject.objectID];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([asam.decimalLatitude doubleValue], [asam.decimalLongitude doubleValue]);
        REVClusterPin *pin = [[REVClusterPin alloc] init];
        pin.title = asam.victim;
        pin.victim = asam.victim;
        pin.dateofOccurrence = asam.dateofOccurrence;
        pin.geographicalSubregion = asam.geographicalSubregion;
        pin.aggressor = asam.aggressor;
        pin.asamDescription = asam.asamDescription;
        pin.referenceNumber = asam.referenceNumber;
        pin.coordinate = coordinate;
        pin.degreeLatitude = [asam formatLatitude];
        pin.degreeLongitude = [asam formatLongitude];
        [self.asamResults addObject:pin];
    }
    
    [self.mapView addAnnotations:self.asamResults];
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (REVClusterPin* annotation in self.asamResults) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    if (region.span.longitudeDelta < 180.0) {
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
    }
    else {
        region = [self.mapView regionThatFits:region];
        self.mapView.region = MKCoordinateRegionForMapRect(MKMapRectWorld);
    }
    
//    NSString *title = @"";
//    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) { // < iOS 7
//        title = @"Back";
//    }
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
//    backButton.tintColor = [UIColor blackColor];
//    self.navigationItem.backBarButtonItem = backButton;
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 320, 40)];
//    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    
//    titleLabel.text = [NSString stringWithFormat:@"%lu ASAM(s)", (unsigned long)self.asamResults.count];
//    self.navigationItem.titleView = titleLabel;
    _controlLabel.text =[NSString stringWithFormat:@"%lu ASAM(s)", (unsigned long)self.asamResults.count];
}

#pragma
#pragma mark - Private methods (UIActivityIndicator) impl.
- (IBAction)startAnimation:(id)sender {
    [self populateAsamPins];
}


- (void)setMapType: (NSNotification *)notification {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *maptype = [defaults stringForKey:@"maptype"];
    
    [_mapView removeOverlays:_mapView.overlays];
    
    //set the maptype
    if ([@"Standard" isEqual:maptype]) {
        _mapView.mapType = MKMapTypeStandard;
    }
    else if ([@"Satellite" isEqual:maptype]) {
        _mapView.mapType = MKMapTypeSatellite;
    }
    else if ([@"Hybrid" isEqual:maptype]) {
        _mapView.mapType = MKMapTypeHybrid;
    }
    else if ([@"Offline" isEqual:maptype]) {
        _mapView.mapType = MKMapTypeStandard;
        [_mapView addOverlays:[OfflineMapUtility getPolygons]];
    }
    else {
        _mapView.mapType = MKMapTypeStandard;
    }
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    
    if ([overlay.title isEqualToString:@"ocean"]) {
        polygonView.fillColor = [UIColor colorWithRed:127/255.0 green:153/255.0 blue:171/255.0 alpha:1];
        polygonView.strokeColor = [UIColor clearColor];
        polygonView.lineWidth = 0.0;
    }
    else {
        polygonView.fillColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        polygonView.strokeColor = [UIColor clearColor];
        polygonView.lineWidth = 0.0;
    }
    return polygonView;
}

- (void)dealloc {
    self.mapView.delegate = nil;
}

@end
