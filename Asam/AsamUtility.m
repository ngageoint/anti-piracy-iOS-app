#import "AsamUtility.h"
#import "KMLParser.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "AsamFetch.h"
#import "Asam.h"
#import "REVClusterPin.h"

@implementation AsamUtility

+ (NSString *)formatTodaysDate {
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString* formattedDate = [formatter stringFromDate:date];
    return formattedDate;
}

+ (NSString *)subtractDaysWithParamfromToday:(NSString *)withDays {
    int monthsToSubtract = -3; //Default value to remove 3 month
    if ([withDays isEqual: @"60"]) {
        monthsToSubtract = -2;
    }
    else if ([withDays isEqual: @"180"]) {
        monthsToSubtract = -6;
    }
    else if ([withDays isEqual: @"365"]) {
        monthsToSubtract = -12;
    }
    else if([withDays isEqual: @"1825"]) {
        monthsToSubtract = -60;
    }
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = monthsToSubtract;
    NSDate *endDate = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dateFormatter stringFromDate:endDate];
    return dateString;
}

+ (NSDate *)getDateFromString:(NSString *)dateString {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy";
    }
    return [dateFormatter dateFromString:dateString];
}

- (NSString *)getLatitute:(NSString *)fromString {
    __weak NSArray* array = [fromString componentsSeparatedByString:@","];
    return [array objectAtIndex:1];
}

- (NSString *)getLongitude:(NSString *)fromString {
    __weak NSArray* array = [fromString componentsSeparatedByString:@","];
    return [array objectAtIndex:0];
}

- (NSString *)getStringFromDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter = nil;
    @synchronized ([NSDateFormatter class]) {
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MM/dd/yyyy";
        }
    }
    return  [dateFormatter stringFromDate:date];
}

 + (BOOL)reachable {
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

+ (NSString *)convertToDegreesMinutesSeconds:(NSString *)coordinate {
    NSArray *array = [coordinate componentsSeparatedByString:@","];
    NSString *northOrSouth = @"S";
    NSString *eastOrWest = @"W";
    double latitude = [[array objectAtIndex:1] doubleValue];
    double longitude = [[array objectAtIndex:0] doubleValue];
    if (longitude >= 0.0) {
        eastOrWest = @"E";
    }
    if (latitude >= 0.0) {
        northOrSouth = @"N";
    }
    
    int degrees = latitude;
    double decimal = fabs(latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    
    NSString *lat = @"";
    if (degrees < 0) {
        lat = [NSString stringWithFormat:@"%d° %d' %i\"", (degrees * -1), minutes, (int)round(seconds)];
    }
    else {
        lat = [NSString stringWithFormat:@"%d° %d' %i\"", degrees, minutes, (int)round(seconds)];
    }
    
    degrees = longitude;
    decimal = fabs(longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    
    NSString *longt = @"";
    if (degrees < 0) {
        longt = [NSString stringWithFormat:@"%d° %d' %i\"", (degrees * -1), minutes, (int)round(seconds)];
    }
    else {
        longt = [NSString stringWithFormat:@"%d° %d' %i\"", degrees, minutes, (int)round(seconds)];
    }
    return [NSString stringWithFormat:@"%@ %@  %@ %@", lat, northOrSouth, longt, eastOrWest];
    
    
}

- (NSDate *)getOlderDateInArray:(NSArray *)array {
    NSArray *sorted = [array sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[REVClusterPin class]] && [obj2 isKindOfClass:[REVClusterPin class]]) {
            REVClusterPin *s1 = obj1;
            REVClusterPin *s2 = obj2;
            return [s1.dateofOccurrence compare:s2.dateofOccurrence];
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return [(REVClusterPin *)[sorted objectAtIndex:0] dateofOccurrence];
}

+ (NSString *)getCellStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *value = [dateFormatter stringFromDate:date];
    return value;
}

+ (NSDate *)getNewestDateInArray:(NSArray *)array {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateofOccurrence" ascending:NO selector:@selector(compare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    array = [array sortedArrayUsingDescriptors:sortDescriptors];
    return [(REVClusterPin *)[array objectAtIndex:0] dateofOccurrence];
}

+ (NSString *)fetchAndFomatLastSyncDate {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];	
    context.persistentStoreCoordinator = [appDelegate persistentStoreCoordinator];
    
    NSArray *array  = [context fetchObjectsForEntityName:@"Asam" sortByKey:@"dateofOccurrence" ascending:NO predicateWithFormat:@"dateofOccurrence != nil"];
    
    Asam *asam = nil;
    NSString* formattedDate = nil;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    if (array != nil && array.count > 0) {
        NSManagedObject *asamManagedObject = [array objectAtIndex:0];
        asam = (Asam *)asamManagedObject;
        formattedDate = [formatter stringFromDate:asam.dateofOccurrence];
    }
    return formattedDate;
}

@end
