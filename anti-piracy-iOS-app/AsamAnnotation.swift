//
//  AsamAnnotation.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 4/14/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

import Foundation
import MapKit.MKAnnotation

class AsamAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}