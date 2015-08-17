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
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
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

    
    func stopLocating() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func getLocation() -> CLLocation? {
        currentLocation = locationManager.location
        return currentLocation
    }
    
    func calculateSubregion() -> Int {
        let subregionPolygons = SubregionMap()
        
        var foundPolygon = MKPolygon()

        for polygon in subregionPolygons.polygons {
            
            //pseudo-code
//            var path = CGPathCreateMutable()
//            let point = CGPoint()
//            
//            if CGPathContainsPoint(path, nil, point, true) {
//                foundPolygon = polygon
//                break
//            }
        }
        
        return currentSubregion
    }

    
}