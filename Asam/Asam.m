#import <Foundation/Foundation.h>
#import "Asam.h"
#import "AsamUtility.h"


@implementation Asam

@dynamic aggressor;
@dynamic asamDescription;
@dynamic degreeLatitude;
@dynamic dateofOccurrence;
@dynamic geographicalSubregion;
@dynamic referenceNumber;
@dynamic victim;
@dynamic degreeLongitude;
@dynamic decimalLatitude;
@dynamic decimalLongitude;

@synthesize asamUtil = _asamUtil;

- (id)init {
    self = [super init];
    if (self) {
        _asamUtil = [[AsamUtility alloc] init];
    }
    return self;

}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        self.aggressor = [dict objectForKey:@"Aggressor"];
        self.asamDescription = [dict objectForKey:@"Description"];
        self.dateofOccurrence = [dict objectForKey:@"Date"];
        self.geographicalSubregion = [dict objectForKey:@"Subregion"];
        self.referenceNumber = [dict objectForKey:@"Reference"];
        self.victim = [dict objectForKey:@"Victim"];
        self.degreeLongitude = [dict objectForKey:@"Longitude"];
        self.degreeLatitude = [dict objectForKey:@"Latitude"];
        self.decimalLatitude = [dict objectForKey:@"lat"];
        self.decimalLongitude = [dict objectForKey:@"lng"];
    }
    return self;
}

- (NSComparisonResult)victimComparison:(Asam *)otherAsam {
    return [self.victim caseInsensitiveCompare:otherAsam.victim];
}

- (NSComparisonResult)aggressorComparison:(Asam *)otherAsam {
    return [self.aggressor caseInsensitiveCompare:otherAsam.aggressor];
}

- (NSComparisonResult)dateDescendingComparison:(Asam *)otherAsam {
    return [[self.asamUtil getStringFromDate:self.dateofOccurrence] compare:[self.asamUtil getStringFromDate:otherAsam.dateofOccurrence] options:NSOrderedAscending];
}

- (NSComparisonResult)dateAscendingComparison:(Asam *)otherAsam {
    return [[self.asamUtil getStringFromDate:otherAsam.dateofOccurrence] compare:[self.asamUtil getStringFromDate:self.dateofOccurrence]  options:NSOrderedDescending];
}

- (NSString *)formatLatitude {
    NSString *hemisphere = @"N";
    double degrees = [self.decimalLatitude doubleValue];
    if (degrees < 0) {
        hemisphere = @"S";
        degrees = fabs(degrees);
    }
    double minutes = (degrees - (int)degrees) * 60.0;
    long seconds = round((minutes - (int)minutes) * 60.0);
    if (seconds >= 60) {
        seconds = 0;
        minutes++;
    }
    if (minutes >= 60) {
        minutes = 0;
        degrees++;
    }
    return [NSString stringWithFormat:@"%02d\u00b0 %02d' %02ld\" %@", (int)degrees, (int)minutes, seconds, hemisphere];
}

- (NSString *)formatLongitude {
    NSString *hemisphere = @"E";
    double degrees = [self.decimalLongitude doubleValue];
    if (degrees < 0) {
        hemisphere = @"W";
        degrees = fabs(degrees);
    }
    double minutes = (degrees - (int)degrees) * 60.0;
    long seconds = round((minutes - (int)minutes) * 60.0);
    if (seconds >= 60) {
        seconds = 0;
        minutes++;
    }
    if (minutes >= 60) {
        minutes = 0;
        degrees++;
    }
    return [NSString stringWithFormat:@"%03d\u00b0 %02d' %02ld\" %@", (int)degrees, (int)minutes, seconds, hemisphere];
}

@end
