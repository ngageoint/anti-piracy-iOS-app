//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
//

#import "REVClusterPin.h"
#import "AsamUtility.h"

@implementation REVClusterPin
@synthesize title,subtitle;
@synthesize coordinate;
@synthesize nodes;

@synthesize dateofOccurrence = _dateofOccurrence;
@synthesize referenceNumber = _referenceNumber;
@synthesize  geographicalSubregion = _geographicalSubregion;
@synthesize aggressor = _aggressor;
@synthesize victim = _victim;
@synthesize asamDescription = _asamDescription;
@synthesize degreeLongitude = _degreeLongitude;
@synthesize degreeLatitude = _degreeLatitude;

- (NSUInteger) nodeCount {
    if( nodes )
        return [nodes count];
    return 0;
}
/*
-(id)initWithAsam:(Asam* )asam andCoordinate:(CLLocationCoordinate2D)theCoordinate{
    self = [super init];
    if (self) {
        _dateofOccurrence = asam.dateofOccurrence;
        _referenceNumber = asam.referenceNumber;
        _geographicalSubregion = asam.geographicalSubregion;
        _aggressor = asam.aggressor;
        _victim = asam.victim;
        _asamDescription = asam.asamDescription;
        _degreeLatitude = asam.degreeLatitude;
        _degreeLongitude = asam.degreeLongitude;
        self.theCoordinate = CLLocationCoordinate2DMake([asam.decimalLatitude doubleValue] , [asam.decimalLongitude doubleValue]);
    }
    return self;
}
 */
- (NSComparisonResult)victimComparison:(Asam *)otherAsam {
    return [self.victim caseInsensitiveCompare:otherAsam.victim];
}

- (NSComparisonResult)aggressorComparison:(Asam *)otherAsam {
    return [self.aggressor caseInsensitiveCompare:otherAsam.aggressor];
}

//#if !__has_feature(objc_arc)
//- (void)dealloc
//{
//    [title release];
//    [subtitle release];
//    [nodes release];
//    
//    
//    [_dateofOccurrence release];
//    [_referenceNumber release];
//    [_geographicalSubregion release];
//    [_aggressor release];
//    [_victim release];
//    [_asamDescription release];
//    [_theCoordinate release];
//    [super dealloc];
//}
//#endif

@end
