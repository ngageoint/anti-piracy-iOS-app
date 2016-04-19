//
//  CurrentSubregion.swift
//  ASAM
//
//  Created by Chris Wasko on 8/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentSubregion: NSObject {
    
    func calculateSubregion(currentLocation: CLLocation?) -> String {
        var currentSubregion = Filter.Basic.DEFAULT_SUBREGION
        let subregionPolygons = SubregionMap()

        var mapCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
        if let aMapCoordinate: CLLocationCoordinate2D = currentLocation?.coordinate {
            mapCoordinate = aMapCoordinate
        }

        for polygon in subregionPolygons.polygons {
            let pathRef: CGMutablePathRef = CGPathCreateMutable()
            let polygonPoints = polygon.points()
            
            for count in 0..<polygon.pointCount {
                let mp: MKMapPoint = polygonPoints[count]
                if count == 0 {
                    CGPathMoveToPoint(pathRef, nil, CGFloat(mp.x), CGFloat(mp.y))
                } else {
                    CGPathAddLineToPoint(pathRef, nil, CGFloat(mp.x), CGFloat(mp.y))
                }
            }
            
            let mapPoint: MKMapPoint  = MKMapPointForCoordinate(mapCoordinate);
            let mapPointAsCGP: CGPoint = CGPointMake(CGFloat(mapPoint.x), CGFloat(mapPoint.y))
            
            let pointIsInPolygon: Bool = CGPathContainsPoint(pathRef, nil, mapPointAsCGP, false)
            
            if pointIsInPolygon {
                currentSubregion = polygon.title!
                print("Point found in region: \(polygon.title)")
                break
            }
        }
        
        return currentSubregion
    }

    
}