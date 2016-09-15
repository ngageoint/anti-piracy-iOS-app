//
//  AsamDetailsViewController.swift
//  anti-piracy-iOS-app
//

import Foundation
import UIKit
import MapKit

class AsamDetailsViewController: UIViewController, AsamSelectDelegate {

    @IBOutlet var date: UILabel!
    @IBOutlet var aggresor: UILabel!
    @IBOutlet var victim: UILabel!
    @IBOutlet var desc: UITextView!
    
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    @IBOutlet weak var mapView: MKMapView!

    let MAP_SPAN_DELTA: Double = 30.0
    var dateFormatter = NSDateFormatter()
    
    var asam: Asam?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        asamMapViewDelegate.asamSelectDelegate = self
        
        dateFormatter.dateFormat = Date.FORMAT

        asamMapViewDelegate.clusteringController = KPClusteringController(mapView: self.mapView)

        //set map type from persisted user data
        if let mapType = asamMapViewDelegate.defaults.stringForKey(MapView.MAP_TYPE) {
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
        
        //build map center from passed in ASAM
        let mapCenterLatitude:  Double = asam?.lat as! Double
        let mapCenterLongitude: Double = asam?.lng as! Double
        
        let mapSpan = MKCoordinateSpanMake(MAP_SPAN_DELTA, MAP_SPAN_DELTA)
        let mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
        let mapRegion =  MKCoordinateRegionMake(mapCenter, mapSpan)
        
        self.mapView.region = mapRegion
      
        self.mapView.zoomEnabled = false
        self.mapView.scrollEnabled = false
        self.mapView.pitchEnabled = false
        self.mapView.rotateEnabled = false
        
        
        // Drop a pin
        let newLocation = CLLocationCoordinate2DMake(asam?.lat as! Double, asam?.lng as! Double)
        let dropPin = AsamAnnotation(coordinate: newLocation, asam: asam!)
        
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