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
    var locationFixAchieved = false
    var filterView: UIViewController!
    
    init(view: UIViewController) {
        super.init()
        filterView = view
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        println("Error while updating location " + error.localizedDescription)
    }

    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if status == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status != .AuthorizedWhenInUse {
            askPermission()
        }
        
        if status == .AuthorizedWhenInUse && !locationFixAchieved {
            locationManager.startUpdatingLocation()
        }
    }

    
    func askPermission() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "To enable Current Subregion, please open this app's settings and set location access to 'While Using the App'.",
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
    
    func hasPermission() -> Bool {
        return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            var locationArray = locations as NSArray
            currentLocation = locationArray.lastObject as? CLLocation
            //Found a location, stop updating
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func stopLocating() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func calculateSubregion() -> String {
        var currentSubregion = Filter.Basic.DEFAULT_SUBREGION
        let subregionPolygons = SubregionMap()

        var mapCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
        if let aMapCoordinate: CLLocationCoordinate2D = currentLocation?.coordinate {
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