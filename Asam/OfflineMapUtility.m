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
    
    //add ocean polygon
    CLLocationCoordinate2D  points[4];
    points[0] = CLLocationCoordinate2DMake(90, 0);
    points[1] = CLLocationCoordinate2DMake(90, -180.0);
    points[2] = CLLocationCoordinate2DMake(-90.0, -180.0);
    points[3] = CLLocationCoordinate2DMake(-90.0, 0);
    MKPolygon* ocean = [MKPolygon polygonWithCoordinates:points count:4];
    ocean.title = @"ocean";
    [polygonsFromFeatures addObject:ocean];
    
    CLLocationCoordinate2D  points2[4];
    points2[0] = CLLocationCoordinate2DMake(90, 0);
    points2[1] = CLLocationCoordinate2DMake(90, 180.0);
    points2[2] = CLLocationCoordinate2DMake(-90.0, 180.0);
    points2[3] = CLLocationCoordinate2DMake(-90.0, 0);
    MKPolygon* ocean2 = [MKPolygon polygonWithCoordinates:points2 count:4];
    ocean2.title = @"ocean";
    
    [polygonsFromFeatures addObject:ocean2];
    
    //add features polygons
    for (id object in featuresArray) {
        
        NSDictionary *element = object;
        NSDictionary *geometry = [element objectForKey:@"geometry"];
        
        if ([[geometry objectForKey:@"type"] isEqualToString:@"Polygon"]) {
            NSMutableArray *coordinates = [geometry objectForKey:@"coordinates"];
            MKPolygon *exteriorPolygon = [OfflineMapUtility generatePolygon:coordinates];
            [polygonsFromFeatures addObject:exteriorPolygon];
        }
        else if ([[geometry objectForKey:@"type"] isEqualToString:@"MultiPolygon"]) {
            NSMutableArray *subPolygons = [geometry objectForKey:@"coordinates"];
        
            for (id subPolygon in subPolygons) {
                NSMutableArray *coordinates = subPolygon;
                MKPolygon *exteriorPolygon = [OfflineMapUtility generatePolygon:coordinates];
                [polygonsFromFeatures addObject:exteriorPolygon];
            }
            
        }
        
    }
    
    polygons = [NSArray arrayWithArray:polygonsFromFeatures];
}

+ (MKPolygon *) generatePolygon:(NSMutableArray *) coordinates {
    
    //exterior polygon
    NSMutableArray *exteriorPolygonCoordinates = coordinates[0];
    NSMutableArray *interiorPolygonCoordinates = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D *exteriorMapCoordinates = malloc(exteriorPolygonCoordinates.count * sizeof(CLLocationCoordinate2D));
    NSInteger exteriorCoordinateCount = 0;
    for (id coordinate in exteriorPolygonCoordinates) {
        NSNumber *y = coordinate[0];
        NSNumber *x = coordinate[1];
        CLLocationCoordinate2D exteriorCoord = CLLocationCoordinate2DMake([x doubleValue], [y doubleValue]);
        exteriorMapCoordinates[exteriorCoordinateCount++] = exteriorCoord;
    }
    
    //interior polygons
    NSMutableArray *interiorPolygons = [[NSMutableArray alloc] init];
    if (coordinates.count > 1) {
        [interiorPolygonCoordinates addObjectsFromArray:coordinates];
        [interiorPolygonCoordinates removeObjectAtIndex:0];
        MKPolygon *recursePolygon = [OfflineMapUtility generatePolygon:interiorPolygonCoordinates];
        [interiorPolygons addObject:recursePolygon];
    }
    
    MKPolygon *exteriorPolygon;
    if (interiorPolygons.count > 0) {
        exteriorPolygon = [MKPolygon polygonWithCoordinates:exteriorMapCoordinates count:exteriorPolygonCoordinates.count interiorPolygons:[NSArray arrayWithArray:interiorPolygons]];
    }
    else {
        exteriorPolygon = [MKPolygon polygonWithCoordinates:exteriorMapCoordinates count:exteriorPolygonCoordinates.count];
    }
    exteriorPolygon.title = @"feature";

    return exteriorPolygon;
}

+ (NSArray *)getPolygons {
    return polygons;
}

@end