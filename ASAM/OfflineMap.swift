//
//  OfflineMap.swift
//  anti-piracy-iOS-app
//


import Foundation
import MapKit

class OfflineMap {
    
    let path = Bundle.main.path(forResource: "ne_50m_land.simplify0.2", ofType: "geojson")
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
        let fileContent = try? Data(contentsOf: URL(fileURLWithPath: path!))
        do {
            jsonDict = (try JSONSerialization.jsonObject(with: fileContent!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        } catch _ {
            //Do nothing
        }
        return jsonDict
    }
    
    func generateExteriorPolygons(_ features: NSArray) {
        
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
        for feature in features {
            let aFeature = feature as! [String:Any]
            let geometry = aFeature["geometry"] as! NSDictionary
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
    
    func generatePolygon(_ coordinates: NSArray) -> MKPolygon {
        
        let exteriorPolygonCoordinates = coordinates[0] as! [[Double]];
        var exteriorCoordinates: [CLLocationCoordinate2D] = [];
        
        //build out Array of coordinates
        for coordinate in exteriorPolygonCoordinates {
            let y = coordinate[0];
            let x = coordinate[1];
            let exteriorCoordinate = CLLocationCoordinate2DMake(x, y);
            exteriorCoordinates.append(exteriorCoordinate)
        }
        
        //build Polygon
        let exteriorPolygon = MKPolygon(coordinates: &exteriorCoordinates, count: exteriorCoordinates.count)
        exteriorPolygon.title = "land"
        
        return exteriorPolygon
        
    }
    
}
