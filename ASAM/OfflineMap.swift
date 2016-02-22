//
//  OfflineMap.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/10/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import MapKit

class OfflineMap {
    
    let path = NSBundle.mainBundle().pathForResource("ne_50m_land.simplify0.2", ofType: "geojson")
    var polygons: [MKPolygon] = [];
    
    init()
    {
        let geoJson: NSDictionary = self.generateDictionaryFromGeoJson()
        let features: NSArray = geoJson["features"] as! NSArray
        generateExteriorPolygons(features)
    }
    
    func generateDictionaryFromGeoJson() -> NSDictionary
    {
        var jsonDict: NSDictionary = ["empty":"empty"]
        let fileContent = NSData(contentsOfFile: path!)
        do {
            jsonDict = (try NSJSONSerialization.JSONObjectWithData(fileContent!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        } catch _ {
            //Do nothing
        }
        return jsonDict
    }
    
    func generateExteriorPolygons(features: NSArray) {
        
        //add ocean polygons
        var ocean1Coordinates = [
            CLLocationCoordinate2DMake(90, 0),
            CLLocationCoordinate2DMake(90, -180.0),
            CLLocationCoordinate2DMake(-90.0, -180.0),
            CLLocationCoordinate2DMake(-90.0, 0)]
        
        var ocean2Coordinates = [
            CLLocationCoordinate2DMake(90, 0),
            CLLocationCoordinate2DMake(90, 180.0),
            CLLocationCoordinate2DMake(-90.0, 180.0),
            CLLocationCoordinate2DMake(-90.0, 0)
        ]
        
        let ocean1 = MKPolygon(coordinates: &ocean1Coordinates, count: ocean1Coordinates.count)
        let ocean2 = MKPolygon(coordinates: &ocean2Coordinates, count: ocean2Coordinates.count)
        
        ocean1.title = "ocean"
        ocean2.title = "ocean"
        
        polygons.append(ocean1)
        polygons.append(ocean2)
        
        //add feature polygons
        for feature in features
        {
            
            let geometry = feature["geometry"] as! NSDictionary
            let geometryType = geometry["type"]! as! String
            
            if "MultiPolygon" == geometryType {
                let subPolygons = geometry["coordinates"] as! NSArray
                for subPolygon in subPolygons
                {
                    let subPolygon = generatePolygon(subPolygon as! NSArray)
                    polygons.append(subPolygon)
                }
                
            }
            
        }
        
    }
    
    func generatePolygon(coordinates: NSArray) -> MKPolygon {
        
        let exteriorPolygonCoordinates = coordinates[0] as! NSArray;
        var exteriorCoordinates: [CLLocationCoordinate2D] = [];
        
        //build out Array of coordinates
        for coordinate in exteriorPolygonCoordinates {
            let y = coordinate[0] as! Double;
            let x = coordinate[1] as! Double;
            let exteriorCoordinate = CLLocationCoordinate2DMake(x, y);
            exteriorCoordinates.append(exteriorCoordinate)
        }
        
        //build Polygon
        let exteriorPolygon = MKPolygon(coordinates: &exteriorCoordinates, count: exteriorCoordinates.count)
        exteriorPolygon.title = "land"
        
        return exteriorPolygon
        
    }
    
}