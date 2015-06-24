//
//  SubregionMap.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import MapKit

class SubregionMap {
    
    let region11 = [11,32.750000000,-116.000000000,34.250270844,-107.428421021,44.002246857,-105.655769348,44.000003815,-93.000000000,40.499996185,-88.000000000,40.500003815,-82.000007629,35.527622223,
                    -77.197044373,35.499992371,-74.750000000,32.935321808,-74.250007629,32.000000000,-79.599998474,23.499948502,-79.600051880,23.500000000,-86.000000000,23.499994278,-90.000007629,
                    27.299686432,-100.679649353,28.985225677,-105.417129517,32.750000000,-116.000000000]
    
    init()
    {
        
        generateExteriorPolygons(region11)
        
    }
    
    func generateExteriorPolygons(region: NSArray) -> MKPolygon {
        
        var coordinates:[CLLocationCoordinate2D] = []
        
        let size = region.count
        var position: Int = 0;
        while position < size-1 {
            coordinates.append(CLLocationCoordinate2DMake(region[position] as! Double, region[position+1] as! Double))
            position += 2
        }
        
        var region = MKPolygon(coordinates: &coordinates, count: coordinates.count)
        return region
        
    }
    
    
}