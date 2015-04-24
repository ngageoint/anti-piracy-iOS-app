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
    @IBOutlet weak var asamCountLabel: UILabel!
    
    private var clusteringController : KPClusteringController!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let offlineMap:OfflineMap = OfflineMap()
    //let asamJsonParser:AsamJsonParser = AsamJsonParser();

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //clustering
        let algorithm : KPGridClusteringAlgorithm = KPGridClusteringAlgorithm()
        
        algorithm.annotationSize = CGSizeMake(25, 50)
        algorithm.clusteringStrategy = KPGridClusteringAlgorithmStrategy.TwoPhase;
        clusteringController = KPClusteringController(mapView: self.mapView)
        clusteringController.delegate = self
        clusteringController.setAnnotations(annotations())
        
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




extension ViewController : KPClusteringControllerDelegate {
    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        return true
    }
}

extension ViewController : MKMapViewDelegate {
    
    //Offline Map Polygons
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

    //Clustering Annotations
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        var annotationView : MKPinAnnotationView?
        
        if annotation is KPAnnotation {
            let a : KPAnnotation = annotation as KPAnnotation
            
            if a.isCluster() {
                annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("cluster") as? MKPinAnnotationView
                
                if (annotationView == nil) {
                    annotationView = MKPinAnnotationView(annotation: a, reuseIdentifier: "cluster")
                }
                
                //annotationView!.pinColor = .Purple
                annotationView!.image = ClusterImageGenerator.textToImage(String(a.annotations.count), inImage: UIImage(named: "cluster")!)
                
            }
                
            else {
                annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
                
                if (annotationView == nil) {
                    annotationView = MKPinAnnotationView(annotation: a, reuseIdentifier: "pin")
                }
                
                //annotationView!.pinColor = .Red
                annotationView!.image = UIImage(named: "pirate")

                
                
            }
            
            annotationView!.canShowCallout = false;
        }
        
        return annotationView;
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        clusteringController.refresh(true)
        
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
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        if view.annotation is KPAnnotation {
            let cluster : KPAnnotation = view.annotation as KPAnnotation
            
            if cluster.annotations.count > 1 {
                let region = MKCoordinateRegionMakeWithDistance(cluster.coordinate,
                    cluster.radius * 2.5,
                    cluster.radius * 2.5)
                
                mapView.setRegion(region, animated: true)
            } else if cluster.annotations.count == 1 {
                print("PIRATE CLICK!")
                performSegueWithIdentifier("singleAsamDetails", sender: cluster.annotations.allObjects[0])
            }
            
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "singleAsamDetails") {
            let viewController: AsamDetailsViewController = segue!.destinationViewController as AsamDetailsViewController
            viewController.asam = (sender as AsamAnnotation).asam

            
        }
    }
    
    
}


