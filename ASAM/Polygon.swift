//
//  Polygon.swift
//  anti-piracy-iOS-app
//

import Foundation
import MapKit

class Polygon {

    //Ray casting algorithm
    func isPointInPolygon(polygon:MKPolygon, point:MKMapPoint) -> Bool {
        var isInPolygon = false
        var xVertex:[Double] = [];
        var yVertex:[Double] = [];
        
        for polygonPoint in UnsafeBufferPointer(start: polygon.points(), count: polygon.pointCount) {
            xVertex.append(polygonPoint.x)
            yVertex.append(polygonPoint.y)
        }
        
        var row = 0
        var column = yVertex.count - 1
        
        while row < xVertex.count {
            if (yVertex[row] > point.y) != (yVertex[column] > point.y) {
                if (point.x < (xVertex[column]-xVertex[row]) * (point.y - yVertex[row]) / (yVertex[column] - xVertex[row]) + xVertex[row]) {
                    isInPolygon = !isInPolygon
                }
            }
            row = row + 1
            column = row
        }
        return isInPolygon
    }

}