//
//  AsamDetailsViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 4/23/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation


class AsamDetailsViewController: UIViewController, AsamSelectDelegate {

    @IBOutlet var date: UILabel!
    @IBOutlet var aggresor: UILabel!
    @IBOutlet var victim: UILabel!
    @IBOutlet var desc: UITextView!
    
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    @IBOutlet weak var mapView: MKMapView!

    var dateFormatter = NSDateFormatter()
    
    var asam: Asam?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        //
        asamMapViewDelegate.asamSelectDelegate = self
        
        dateFormatter.dateFormat = AsamDateFormat.dateFormat

        asamMapViewDelegate.clusteringController = KPClusteringController(mapView: self.mapView)

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
        
        //rebuild map center and map span from persisted user data
        var mapCenterLatitude:  Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLatitude")
        var mapCenterLongitude: Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLongitude")
        var mapSpanLatitudeDelta: Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLatitudeDelta")
        var mapSpanLongitudeDelta: Double = asamMapViewDelegate.defaults.doubleForKey("mapViewLongitudeDelta")
        
        var mapSpan = MKCoordinateSpanMake(mapSpanLatitudeDelta, mapSpanLongitudeDelta)
        var mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
        var mapRegion =  MKCoordinateRegionMake(mapCenter, mapSpan)
        
        self.mapView.region = mapRegion
      
        self.mapView.zoomEnabled = false
        self.mapView.scrollEnabled = false
        self.mapView.pitchEnabled = false
        self.mapView.rotateEnabled = false
        
        
        // Drop a pin
        var newLocation = CLLocationCoordinate2DMake(asam?.lat as Double, asam?.lng as Double)
        var dropPin = AsamAnnotation(coordinate: newLocation, asam: asam!)
        
        asamMapViewDelegate.clusteringController.setAnnotations([dropPin])
        
        //populate view
        self.title = "ASAM Reference: " + (asam?.reference)!
        date.text = dateFormatter.stringFromDate((asam?.date)!)
        aggresor.text = (asam?.aggressor)!
        victim.text = (asam?.victim)!
        desc.text = (asam?.desc)!
        
    }

    func asamSelected(asam: AsamAnnotation) {
        //no action to perform.  We're already on the details screen.
    }
    

}