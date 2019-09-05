//
//  AsamClusterAnnotationView.swift
//  ASAM
//
//  Created by William Newman on 8/27/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import MapKit

final class AsamClusterAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        subtitleVisibility = .hidden
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard let annotation = annotation as? MKClusterAnnotation else { return }

        let count = annotation.memberAnnotations.count
        glyphText = "\(count)"
        markerTintColor = UIColor.init(red: 84.0/255.0, green: 110.0/255.0, blue: 122.0/255.0, alpha: 1)
    }
}
