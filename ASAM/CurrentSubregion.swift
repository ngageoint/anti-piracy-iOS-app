//
//  CurrentSubregion.swift
//  ASAM
//


import Foundation
import CoreLocation
import MapKit

class CurrentSubregion: NSObject {
    
    func calculateSubregion(_ currentLocation: CLLocation?) -> String {
        var currentSubregion = Filter.Basic.DEFAULT_SUBREGION
        let subregionPolygons = SubregionMap()

        var mapCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
        if let aMapCoordinate: CLLocationCoordinate2D = currentLocation?.coordinate {
            mapCoordinate = aMapCoordinate
        }

        for polygon in subregionPolygons.polygons {
            let pathRef: CGMutablePath = CGMutablePath()
            let polygonPoints = polygon.points()
            
            for count in 0..<polygon.pointCount {
                let mp: MKMapPoint = polygonPoints[count]
                if count == 0 {
                    pathRef.move(to: CGPoint(x: mp.x, y: mp.y))
                    //CGPathMoveToPoint(pathRef, nil, CGFloat(mp.x), CGFloat(mp.y))
                } else {
                    pathRef.addLine(to: CGPoint(x: mp.x, y: mp.y))
                    //CGPathAddLineToPoint(pathRef, nil, CGFloat(mp.x), CGFloat(mp.y))
                }
            }
            
            let mapPoint: MKMapPoint  = MKMapPoint.init(mapCoordinate);
            let mapPointAsCGP: CGPoint = CGPoint(x: CGFloat(mapPoint.x), y: CGFloat(mapPoint.y))
            
            let pointIsInPolygon = pathRef.contains(mapPointAsCGP)
            //let pointIsInPolygon: Bool = CGPathContainsPoint(pathRef, nil, mapPointAsCGP, false)
            
            if pointIsInPolygon {
                currentSubregion = polygon.title!
                print("Point found in region: \(String(describing: polygon.title))")
                break
            }
        }
        
        return currentSubregion
    }

    
}
