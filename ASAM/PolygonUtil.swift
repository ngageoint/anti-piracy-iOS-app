//
//  PolygonUtil.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

class PolygonUtil {

    //Ray casting algorithm
    func isPointInPolygon(polygon:MKPolygon, point:MKMapPoint) -> Bool {
    
        var vertx:[Double] = [];
        var verty:[Double] = [];
        
        let testx:Double = point.x
        let testy:Double = point.y
        
        //create arrays for x and y points
        for point in UnsafeBufferPointer(start: polygon.points(), count: polygon.pointCount) {
            vertx.append(point.x)
            verty.append(point.y)
        }
        
        var i = 0
        var j = verty.count-1
        var c:Bool = false
        let nvert = vertx.count
        
        while i < nvert {
            if (verty[i]>testy) != (verty[j]>testy) {
                if (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) {
                    c = !c
                }
            }
            j = i++
        }
        return c
    }

}