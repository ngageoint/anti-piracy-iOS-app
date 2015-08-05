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

class ViewController: UIViewController, AsamSelectDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var asamCountLabel: UILabel!
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    
    //let asamJsonParser:AsamJsonParser = AsamJsonParser();

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //
        asamMapViewDelegate.asamSelectDelegate = self
        
        //clustering
        let algorithm : KPGridClusteringAlgorithm = KPGridClusteringAlgorithm()
        
        algorithm.annotationSize = CGSizeMake(25, 50)
        algorithm.clusteringStrategy = KPGridClusteringAlgorithmStrategy.TwoPhase;
        asamMapViewDelegate.clusteringController = KPClusteringController(mapView: self.mapView)
        //asamMapViewDelegate.clusteringController.delegate = self
        asamMapViewDelegate.clusteringController.setAnnotations(annotations())
        
        //rebuild map center and map span from persisted user data
        var mapCenterLatitude:  Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLatitude")
        var mapCenterLongitude: Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLongitude")
        var mapSpanLatitudeDelta: Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLatitudeDelta")
        var mapSpanLongitudeDelta: Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLongitudeDelta")
        
        var mapSpan = MKCoordinateSpanMake(mapSpanLatitudeDelta, mapSpanLongitudeDelta)
        var mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
        var mapRegion =  MKCoordinateRegionMake(mapCenter, mapSpan)
        
        self.mapView.region = mapRegion
        
        //set map type from persisted user data
        if let mapType = asamMapViewDelegate.defaults.stringForKey("mapType") {
            switch mapType {
                case "Standard":
                    self.mapView.mapType = MKMapType.Standard
                    self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
                case "Satellite":
                    self.mapView.mapType = MKMapType.Satellite
                    self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
                case "Hybrid":
                    self.mapView.mapType = MKMapType.Hybrid
                    self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
                case "Offline":
                    self.mapView.mapType = MKMapType.Standard
                    self.mapView.addOverlays(asamMapViewDelegate.offlineMap.polygons)
                default:
                    self.mapView.mapType = MKMapType.Standard
                    self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            }
        }
        
    }
    
    func annotations() -> [AsamAnnotation] {
        
        var annotations: [AsamAnnotation] = []
        
        let model = AsamModelFacade()
        let filteredAsams = model.getAsams()
        for asam in filteredAsams {
            // Drop a pin
            var newLocation = CLLocationCoordinate2DMake(asam.lat as Double, asam.lng as Double)
            var dropPin = AsamAnnotation(coordinate: newLocation, asam: asam)
            annotations.append(dropPin)
        }
        
        asamCountLabel.text = "Now Showing \(filteredAsams.count) ASAMS"
        return annotations
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    @IBAction func showLayerActionSheet(sender: UIButton) {
        
        // Action Sheet Label
        let optionMenu = UIAlertController(title: nil, message: "Select Map Type", preferredStyle: .ActionSheet)
        
        // Action Sheet Options
        let standardMapAction = UIAlertAction(title: "Standard", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Standard
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Standard", forKey: "mapType")
        })
        let satelliteMapAction = UIAlertAction(title: "Satellite", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Satellite
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Satellite", forKey: "mapType")

        })
        let hybridMapAction = UIAlertAction(title: "Hybrid", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Hybrid
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Hybrid", forKey: "mapType")
        })
        let offlineMapAction = UIAlertAction(title: "Offline", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapView.mapType = MKMapType.Standard
            self.mapView.addOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Offline", forKey: "mapType")
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

    func asamSelected(asam: AsamAnnotation) {
        performSegueWithIdentifier("singleAsamDetails", sender: asam)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "singleAsamDetails") {
            let viewController: AsamDetailsViewController = segue!.destinationViewController as! AsamDetailsViewController
            viewController.asam = (sender as! AsamAnnotation).asam
            
            
        }
    }
    
    @IBAction func unwindFromFilter(segue: UIStoryboardSegue) {
        
    }
    
}





