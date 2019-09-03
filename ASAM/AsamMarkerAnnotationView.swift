//
//  AsamAnnotationView.swift
//  ASAM
//
//  Created by William Newman on 8/27/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import MapKit

class AsamMarkerAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            clusteringIdentifier = "asam\(MapViewController.clusteringIdentifierCount)"
            canShowCallout = false
            subtitleVisibility = .adaptive
            markerTintColor = UIColor.init(red: 55.0/255.0, green: 71.0/255.0, blue: 79.0/255.0, alpha: 1)
            glyphImage = UIImage(named: "pirate")
        }
    }
}
