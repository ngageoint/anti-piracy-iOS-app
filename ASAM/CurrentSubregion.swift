//
//  CurrentSubregion.swift
//  ASAM
//
//  Created by Chris Wasko on 8/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentSubregion: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    var currentSubregion = 11
    
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    

    func askPermission(filterView: UIViewController) -> Bool {
        var hasPermission = false
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "To enabled Current Subregion, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            filterView.presentViewController(alertController, animated: true, completion: nil)
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            hasPermission = true
        }
        
        return hasPermission
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    
    func startLocating() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func stopLocating() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func getLocation() -> CLLocation? {
        currentLocation = locationManager.location
        return currentLocation
    }
    
    
    func calculateSubregion() -> String {
        var currentSubregion = Filter.Basic.DEFAULT_SUBREGION
        let subregionPolygons = SubregionMap()

        var mapCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
        if let aMapCoordinate: CLLocationCoordinate2D = getLocation()?.coordinate {
            mapCoordinate = aMapCoordinate
        }

        for polygon in subregionPolygons.polygons {
            var pathRef: CGMutablePathRef = CGPathCreateMutable()
            let polygonPoints = polygon.points()
            
            for var count = 0; count < polygon.pointCount; count++ {
                var mp: MKMapPoint = polygonPoints[count]
                if count == 0 {
                    CGPathMoveToPoint(pathRef, nil, CGFloat(mp.x), CGFloat(mp.y))
                } else {
                    CGPathAddLineToPoint(pathRef, nil, CGFloat(mp.x), CGFloat(mp.y))
                }
            }
            
            let mapPoint: MKMapPoint  = MKMapPointForCoordinate(mapCoordinate);
            let mapPointAsCGP: CGPoint = CGPointMake(CGFloat(mapPoint.x), CGFloat(mapPoint.y))
            
            var pointIsInPolygon: Bool = CGPathContainsPoint(pathRef, nil, mapPointAsCGP, false)
            
            if pointIsInPolygon {
                currentSubregion = polygon.title
                println("Point found in region: \(polygon.title)")
                break
            }
        }
        
        return currentSubregion
    }

    
}