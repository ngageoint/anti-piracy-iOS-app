//
//  AsamDetailsViewController.swift
//  anti-piracy-iOS-app
//

import Foundation
import UIKit
import MapKit

class AsamDetailsViewController: UIViewController {

    var asam: Asam!
    var dateFormatter = DateFormatter()
    let MAP_SPAN_DELTA: Double = 30.0
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var hostility: UILabel!
    @IBOutlet weak var victim: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var subregion: UILabel!
    @IBOutlet weak var navArea: UILabel!
    @IBOutlet weak var coordinate: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ASAM Details"

        dateFormatter.dateFormat = DateQuery.FORMAT
        
        initializeMap()
        initializeDetails()
    }
    
    fileprivate func initializeMap() {
        mapView.register(AsamMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        if let asam = asam {
            let mapCenterLatitude = asam.latitude
            let mapCenterLongitude = asam.longitude
            
            let mapSpan = MKCoordinateSpan.init(latitudeDelta: MAP_SPAN_DELTA, longitudeDelta: MAP_SPAN_DELTA)
            let mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
            let mapRegion =  MKCoordinateRegion.init(center: mapCenter, span: mapSpan)
            mapView.region = mapRegion

            let newLocation = CLLocationCoordinate2DMake(asam.latitude, asam.longitude)
            let annotation = AsamAnnotation(coordinate: newLocation, asam: asam)
            mapView.addAnnotation(annotation)
        }
        
        if let mapType = UserDefaults.standard.string(forKey: MapView.MAP_TYPE) {
            switch mapType {
            case "Standard":
                self.mapView.mapType = MKMapType.standard
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            case "Satellite":
                self.mapView.mapType = MKMapType.satellite
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            case "Hybrid":
                self.mapView.mapType = MKMapType.hybrid
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            case "Offline":
                self.mapView.mapType = MKMapType.standard
                self.mapView.addOverlays(asamMapViewDelegate.offlineMap.polygons)
            default:
                self.mapView.mapType = MKMapType.standard
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            }
        }
    }
    
    fileprivate func initializeDetails() {
        date.text = dateFormatter.string(from: asam.date)
        hostility.text = asam.hostility
        victim.text = asam.victim
        number.text = asam.reference
        subregion.text = String(asam.subregion)
        navArea.text = asam.navArea
        coordinate.text = "\(formatLatitudeDegMinSec()), \(formatLongitudeDegMinSec())"
        detail.text = asam.detail
    }
    
    fileprivate func formatLatitudeDegMinSec() -> String {
        var hemisphere = "N"
        
        var degrees = asam.latitude
        if (degrees < 0) {
            hemisphere = "S"
            degrees = abs(degrees)
        }
        
        var minutes = (degrees - Double(Int(degrees))) * 60.0
        var seconds = ((minutes - Double(Int(minutes))) * 60.0).rounded()
        if (seconds >= 60) {
            seconds = 0
            minutes += 1
        }
        if (minutes >= 60) {
            minutes = 0
            degrees += 1
        }
        
        return "\(String(format: "%02.f", degrees))° \(String(format: "%02.f", minutes))' \(String(format: "%02.f", seconds))\" \(hemisphere)"
    }
    
    fileprivate func formatLongitudeDegMinSec() -> String {
        var hemisphere = "E"
        
        var degrees = asam.longitude
        if (degrees < 0) {
            hemisphere = "W"
            degrees = abs(degrees)
        }
        
        var minutes = (degrees - Double(Int(degrees))) * 60.0
        var seconds = ((minutes - Double(Int(minutes))) * 60).rounded()
        if (seconds >= 60) {
            seconds = 0
            minutes += 1
        }
        if (minutes >= 60) {
            minutes = 0
            degrees += 1
        }
        
        return "\(String(format: "%03.f", degrees))° \(String(format: "%02.f", minutes))' \(String(format: "%02.f", seconds))\" \(hemisphere)"
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}
