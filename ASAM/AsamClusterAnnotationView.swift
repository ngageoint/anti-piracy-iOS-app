//
//  AsamClusterAnnotationView.swift
//  ASAM
//
//  Created by William Newman on 8/27/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import MapKit

final class AsamClusterAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        displayPriority = .defaultHigh
        collisionMode = .circle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard let annotation = annotation as? MKClusterAnnotation else {
            return
        }
        annotation.title = "purple"
        annotation.subtitle = "green"
        let count = annotation.memberAnnotations.count
        image = self.image(annotation: annotation, count: count)
    }

    func image(annotation: MKClusterAnnotation, count: Int) -> UIImage? {
        var width: CGFloat = 28.0
        var height: CGFloat = 28.0

        if (count > 1000) {
            width = 46.0
            height = 46.0;
        } else if (count > 100) {
            width = 40.0
            height = 40.0;
        } else if (count > 10) {
            width = 34.0
            height = 34.0;
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: height, height: height))
        image = renderer.image { _ in
            UIColor.init(red: 230.0/255.0, green: 74.0/255.0, blue: 25.0/255.0, alpha: 1).setStroke()
            UIColor.init(red: 55.0/255.0, green: 71.0/255.0, blue: 79.0/255.0, alpha: 1).setFill()
            let path = UIBezierPath(ovalIn: CGRect(x: 3.0, y: 3.0, width: width - 6, height: height - 6))
            path.lineWidth = 3
            path.fill()
            path.stroke()
            
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12.0)
            ]

            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: (width / 2.0) - size.width / 2, y: (height / 2.0) - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }

        return image
    }
}
