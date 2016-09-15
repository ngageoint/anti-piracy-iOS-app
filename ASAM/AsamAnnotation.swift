//
//  AsamAnnotation.swift
//  anti-piracy-iOS-app
//


import Foundation

import Foundation
import MapKit.MKAnnotation

class AsamAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var asam: Asam
    
    init(coordinate: CLLocationCoordinate2D, asam: Asam) {
        self.coordinate = coordinate
        self.asam =  asam
    }
}