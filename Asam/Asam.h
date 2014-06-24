#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AsamUtility.h"

@interface Asam : NSManagedObject

@property (nonatomic, retain) NSString * aggressor;
@property (nonatomic, retain) NSString * asamDescription;
@property (nonatomic, retain) NSDate * dateofOccurrence;
@property (nonatomic, retain) NSString * geographicalSubregion;
@property (nonatomic, retain) NSString * referenceNumber;
@property (nonatomic, retain) NSString * victim;
@property (nonatomic, retain) NSString * degreeLatitude;
@property (nonatomic, retain) NSString * degreeLongitude;
@property (nonatomic, retain) NSNumber * decimalLatitude;
@property (nonatomic, retain) NSNumber * decimalLongitude;
@property (nonatomic, strong) AsamUtility *asamUtil;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSString *)formatLatitude;
- (NSString *)formatLongitude;

@end
