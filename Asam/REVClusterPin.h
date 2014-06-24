//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Asam.h"

@interface REVClusterPin : NSObject  <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSArray *nodes;
    
    
    NSString *_referenceNumber;
    NSDate *_dateofOccurrence;
    NSString *_geographicalSubregion;
    NSString *_aggressor;
    NSString *_victim;
    NSString *_asamDescription;
    NSString * _degreeLatitude;
    NSString * _degreeLongitude;

    CLLocationCoordinate2D _theCoordinate;

}
@property(nonatomic, retain) NSArray *nodes;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@property (nonatomic, retain) NSString * degreeLatitude;
@property (nonatomic, retain) NSString * degreeLongitude;
@property (nonatomic, strong) NSDate *dateofOccurrence;
@property (nonatomic, strong) NSString *referenceNumber;
@property (nonatomic, strong) NSString *geographicalSubregion;
@property (nonatomic, strong) NSString *aggressor;
@property (nonatomic, strong) NSString *victim;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@property (nonatomic, strong) NSString *asamDescription;

    //-(id)initWithAsam:(Asam* )asam andCoordinate:(CLLocationCoordinate2D)theCoordinate;

- (NSUInteger) nodeCount;

@end
