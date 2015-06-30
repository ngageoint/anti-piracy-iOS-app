//
//  PolygonUtil.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

class PolygonUtil {

    

    func isPointInPolygon(polygon:MKPolygon, point:MKMapPoint) -> Bool {
    
        let returnValue:Bool = false;
        
        var polygonXcoords:[Double] = [];
        var polygonYcoords:[Double] = [];
        
        let pointX:Double = point.x
        let pointY:Double = point.y
        
        //create arrays for x and y points
        for point in UnsafeBufferPointer(start: polygon.points(), count: polygon.pointCount) {
            polygonXcoords.append(point.x)
            polygonYcoords.append(point.y)
        }
        
        //let j:Int = polygonXcoords.count-1
        //for (let i:Int = 0, i <polygonXcoords.count; j = i++) {
            
            
            
            //if ( ((verty[i]>testy) != (verty[j]>testy)) &&
            //(testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
            //c = !c;
        //}

        
        
        return returnValue
    }


}

/**


int pnpoly(int nvert, float *vertx, float *verty, float testx, float testy)
{
int i, j, c = 0;
for (i = 0, j = nvert-1; i < nvert; j = i++) {
if ( ((verty[i]>testy) != (verty[j]>testy)) &&
(testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
c = !c;
}
return c;
}

**/