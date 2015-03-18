//
//  ViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
   
    let defaults = NSUserDefaults.standardUserDefaults()
    var asams = [Asam]()

    let offlineMap:OfflineMap = OfflineMap()
    //let asamJsonParser:AsamJsonParser = AsamJsonParser();
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        var polygonRenderer = MKPolygonRenderer(overlay: overlay);
        
        if "ocean" == overlay.title {
            polygonRenderer.fillColor = UIColor(red: 127/255.0, green: 153/255.0, blue: 171/255.0, alpha: 1.0)
            polygonRenderer.strokeColor = UIColor.clearColor()
            polygonRenderer.lineWidth = 0.0
        }
        else {
            polygonRenderer.fillColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0)
            polygonRenderer.strokeColor = UIColor.clearColor()
            polygonRenderer.lineWidth = 0.0
        }
        
        return polygonRenderer
    }
    
    
    func  mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        
        //persisting map center and span so that the map will return to this location.
        defaults.setDouble(mapView.region.center.latitude, forKey: "mapViewLatitude")
        defaults.setDouble(mapView.region.center.longitude, forKey: "mapViewLongitude")
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: "mapViewLatitudeDelta")
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: "mapViewLongitudeDelta")
        println("Persisting Map Center (\(mapView.region.center.latitude)," +
                                       "\(mapView.region.center.longitude))");
        println("Persisting Map Deltas (lat delta: \(mapView.region.span.latitudeDelta)," +
                                       "lon delta:\(mapView.region.span.longitudeDelta))");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rebuild map center and map span from persisted user data
        var mapCenterLatitude:  Double = defaults.doubleForKey("mapViewLatitude")
        var mapCenterLongitude: Double = defaults.doubleForKey("mapViewLongitude")
        var mapSpanLatitudeDelta: Double = defaults.doubleForKey("mapViewLatitudeDelta")
        var mapSpanLongitudeDelta: Double = defaults.doubleForKey("mapViewLongitudeDelta")
        
        var mapSpan = MKCoordinateSpanMake(mapSpanLatitudeDelta, mapSpanLongitudeDelta)
        var mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
        var mapRegion =  MKCoordinateRegionMake(mapCenter, mapSpan)
        
        self.mapView.region = mapRegion
        
        //set map type from persisted user data
        if let mapType = defaults.stringForKey("mapType") {
            switch mapType {
                case "Standard":
                    self.mapView.mapType = MKMapType.Standard
                    self.mapView.removeOverlays(self.offlineMap.polygons)
                case "Satellite":
                    self.mapView.mapType = MKMapType.Satellite
                    self.mapView.removeOverlays(self.offlineMap.polygons)
                case "Hybrid":
                    self.mapView.mapType = MKMapType.Hybrid
                    self.mapView.removeOverlays(self.offlineMap.polygons)
                case "Offline":
                    self.mapView.mapType = MKMapType.Standard
                    self.mapView.addOverlays(self.offlineMap.polygons)
                default:
                    self.mapView.mapType = MKMapType.Standard
                    self.mapView.removeOverlays(self.offlineMap.polygons)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Asam")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Asam] {
            
            for asam in fetchResults {

                var newLocation = CLLocationCoordinate2DMake(asam.lat as Double, asam.lng as Double)

                // Drop a pin
                var dropPin = MKPointAnnotation()
                dropPin.coordinate = newLocation
                dropPin.title = "ASAM " + asam.reference
                mapView.addAnnotation(dropPin)

            
            }
            
        }
    
    }
    
    @IBAction func showLayerActionSheet(sender: UIButton) {
        
        // Action Sheet Label
        let optionMenu = UIAlertController(title: nil, message: "Select Map Type", preferredStyle: .ActionSheet)
        
        // Action Sheet Options
        let standardMapAction = UIAlertAction(title: "Standard", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Standard
            self.mapView.removeOverlays(self.offlineMap.polygons)
            self.defaults.setObject("Standard", forKey: "mapType")
        })
        let satelliteMapAction = UIAlertAction(title: "Satellite", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Satellite
            self.mapView.removeOverlays(self.offlineMap.polygons)
            self.defaults.setObject("Satellite", forKey: "mapType")

        })
        let hybridMapAction = UIAlertAction(title: "Hybrid", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Hybrid
            self.mapView.removeOverlays(self.offlineMap.polygons)
            self.defaults.setObject("Hybrid", forKey: "mapType")
        })
        let offlineMapAction = UIAlertAction(title: "Offline", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Standard
            self.mapView.addOverlays(self.offlineMap.polygons)
            self.defaults.setObject("Offline", forKey: "mapType")
        })
        
        // Action Sheet Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        // Build Menu
        optionMenu.addAction(standardMapAction)
        optionMenu.addAction(satelliteMapAction)
        optionMenu.addAction(hybridMapAction)
        optionMenu.addAction(offlineMapAction)
        optionMenu.addAction(cancelAction)
        
        // Show Action Sheet
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }

}

