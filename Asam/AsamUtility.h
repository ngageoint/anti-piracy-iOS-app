#import <Foundation/Foundation.h>

#define kConnectedKey @"connected"
#define kLastSyncDateKey @"lastsyncdate"

@interface AsamUtility : NSObject

+ (NSString *)getCellStringFromDate:(NSDate *)date;
+ (NSString *)formatTodaysDate;
+ (NSString *)subtractDaysWithParamfromToday:(NSString *)withDays;
+ (NSDate *)getDateFromString:(NSString *)dateString;
+ (BOOL)reachable;
+ (NSString *)convertToDegreesMinutesSeconds:(NSString *)coordinate;
+ (NSDate *)getNewestDateInArray:(NSArray *)array;
+ (NSString *)fetchAndFomatLastSyncDate;
- (NSString *)getStringFromDate:(NSDate *)date;
- (NSString *)getLatitute:(NSString *)fromString;
- (NSString *)getLongitude:(NSString *)fromString;
- (NSDate *)getOlderDateInArray:(NSArray *)array;

@end
