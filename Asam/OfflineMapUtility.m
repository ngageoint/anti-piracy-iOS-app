//
//  OfflineMapUtility.m
//  Asam
//
//  Created by Travis Baumgart on 7/11/14.
//
//

#import "OfflineMapUtility.h"

#import <MapKit/MapKit.h>

@implementation OfflineMapUtility

static NSArray *polygons;

+ (NSDictionary *) dictionaryWithContentsOfJSONString:(NSString*) fileLocation {

    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileLocation ofType:@"geojson"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error != nil) {
        return nil;
    }
    return result;
    
}

+ (void) generateExteriorPolygons:(NSMutableArray*) featuresArray {
    
    NSMutableArray *polygonsFromFeatures = [[NSMutableArray alloc] init];
    NSInteger featureCount = 0;
    
    for (id object in featuresArray) {
        
        NSDictionary *element = object;
        NSDictionary *geometry = [element objectForKey:@"geometry"];
        
        if ([[geometry objectForKey:@"type"] isEqualToString:@"Polygon"]) {
            NSMutableArray *coordinates = [geometry objectForKey:@"coordinates"];
            MKPolygon *exteriorPolygon = [OfflineMapUtility generatePolygon:coordinates];
            polygonsFromFeatures[featureCount++] = exteriorPolygon;
        }
        else if ([[geometry objectForKey:@"type"] isEqualToString:@"MultiPolygon"]) {
            NSMutableArray *subPolygons = [geometry objectForKey:@"coordinates"];
        
            for (id subPolygon in subPolygons) {
                NSMutableArray *coordinates = subPolygon;
                MKPolygon *exteriorPolygon = [OfflineMapUtility generatePolygon:coordinates];
                polygonsFromFeatures[featureCount++] = exteriorPolygon;
            }
            
        }
        
    }
    polygons = [NSArray arrayWithArray:polygonsFromFeatures];
}

+ (MKPolygon *) generatePolygon:(NSMutableArray *) coordinates {
    
    //exterior polygon
    NSMutableArray *exteriorPolygonCoordinates = coordinates[0];
    CLLocationCoordinate2D *mapCoordinates = malloc(exteriorPolygonCoordinates.count * sizeof(CLLocationCoordinate2D));
    
    NSInteger count = 0;
    for (id coordinate in exteriorPolygonCoordinates) {
        NSNumber *y = coordinate[0];
        NSNumber *x = coordinate[1];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([x doubleValue], [y doubleValue]);
        mapCoordinates[count++] = coord;
    }
    
    MKPolygon *exteriorPolygon = [MKPolygon polygonWithCoordinates:mapCoordinates count:exteriorPolygonCoordinates.count];
    return exteriorPolygon;
}

+ (NSArray *)getPolygons {
    return polygons;
}

@end