
#import "NSString+StringFromDate.h"

@implementation NSString (StringFromDate)

+ (NSString *) getStringFromDate:(NSString *)dateAsString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSDate *date = [dateFormatter dateFromString:dateAsString];
    
    [dateFormatter setDateFormat:@"MM/dd/YYYY"];
    NSString *formattedStringDate = [dateFormatter stringFromDate:date];
    return formattedStringDate;
}
@end
