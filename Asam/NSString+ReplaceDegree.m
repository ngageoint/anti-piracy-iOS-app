
#import "NSString+ReplaceDegree.h"

@implementation NSString (ReplaceDegree)


+ (NSString *) degreeRepresentation: (NSString *) value {
    return [value stringByReplacingOccurrencesOfString:@"&deg;" withString:@"\u00B0"];
}
@end
