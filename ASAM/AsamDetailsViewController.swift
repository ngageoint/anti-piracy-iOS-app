//
//  AsamDetailsViewController.swift
//  anti-piracy-iOS-app
//

import Foundation
import UIKit
import MapKit

class AsamDetailsViewController: UIViewController, AsamSelectDelegate {

    var asam: Asam?
    var dateFormatter = NSDateFormatter()
    let MAP_SPAN_DELTA: Double = 30.0
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var aggressor: UILabel!
    @IBOutlet weak var victim: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var subregion: UILabel!
    @IBOutlet weak var coordinate: UILabel!
    @IBOutlet weak var detailDescription: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        asamMapViewDelegate.asamSelectDelegate = self
        dateFormatter.dateFormat = Date.FORMAT
        
        initializeMap()
        initializeDetails()
    }
    
    func asamSelected(asam: AsamAnnotation) {
        //no action to perform.  We're already on the details screen.
    }
    
    private func initializeMap() {
        if let asam = asam {
            let mapCenterLatitude:  Double = asam.lat as Double
            let mapCenterLongitude: Double = asam.lng as Double
            
            let mapSpan = MKCoordinateSpanMake(MAP_SPAN_DELTA, MAP_SPAN_DELTA)
            let mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
            let mapRegion =  MKCoordinateRegionMake(mapCenter, mapSpan)
            
            self.mapView.region = mapRegion

            let newLocation = CLLocationCoordinate2DMake(asam.lat as Double, asam.lng as Double)
            let dropPin = AsamAnnotation(coordinate: newLocation, asam: asam)

            
            asamMapViewDelegate.clusteringController = KPClusteringController(mapView: self.mapView)
            asamMapViewDelegate.clusteringController.setAnnotations([dropPin])
        }
        
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
        
    }
    
    private func initializeDetails() {
        if let asam = asam {
            self.title = "ASAM Details"
            date.text = dateFormatter.stringFromDate(asam.date)
            aggressor.text = asam.aggressor
            victim.text = asam.victim
            number.text = asam.reference
            subregion.text = asam.subregion.stringValue
            
            let rawCoordinate = "Lat: " + asam.latitude + ", Lon: " + asam.longitude
            let options: [String : AnyObject] = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : NSUTF8StringEncoding]
            if let data = rawCoordinate.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let unescaped = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                    coordinate.text = unescaped.string
                } catch {
                    print(error)
                }
            }
            
            detailDescription.text = asam.desc
        }
    }
    
    
}