//
//  OfflineMapUtility.h
//  Asam
//
//  Created by Travis Baumgart on 7/11/14.
//
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface OfflineMapUtility : NSObject

+ (NSArray*)getPolygons;

+ (NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation;
+ (void) generateExteriorPolygons:(NSMutableArray*) featuresArray;
+ (MKPolygon *) generatePolygon:(NSMutableArray *) coordinates;

@end
