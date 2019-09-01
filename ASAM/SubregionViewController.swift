//
//  AdvancedFilterViewController.swift
//  anti-piracy-iOS-app
//

import Foundation
import MapKit

class SubregionViewController: SubregionDisplayViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedRegions = Array<String>()
    var regions = String()
    
    let unselectedColor:UIColor = UIColor.init(white: 0.0, alpha: 0.0)
    let selectedColor:UIColor = UIColor(red: 230.0/255.0, green: 74.0/255.0, blue: 25.0/255.0, alpha: 0.54)
    let strokeColor:UIColor = UIColor(red: 230.0/255.0, green: 74.0/255.0, blue: 25.0/255.0, alpha: 0.87)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subregionsMap:SubregionMap = SubregionMap()
        self.mapView.addOverlays(subregionsMap.polygons)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SubregionViewController.action(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    // Offline Map Polygons
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonRenderer = MKPolygonRenderer(overlay: overlay)
        
        if let title = overlay.title {
            if selectedRegions.contains(title!)  {
                polygonRenderer.fillColor = selectedColor
            } else {
                polygonRenderer.fillColor = unselectedColor
            }
            
            polygonRenderer.strokeColor = strokeColor
            polygonRenderer.lineWidth = 1.0
        }
        
        return polygonRenderer
    }

    @IBAction func clearSelected(_ sender: AnyObject) {
        for polygon in mapView.overlays as! [MKPolygon] {
            let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer
            
            if selectedRegions.contains(polygon.title!) {
                selectedRegions.remove(at: selectedRegions.firstIndex(of: polygon.title!)!)
            }
            
            renderer?.fillColor = unselectedColor
        }
    }
    
    @objc func action(_ gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let tapCoordinate:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let point = MKMapPoint.init(tapCoordinate)
        
        for polygon in mapView.overlays as! [MKPolygon] {
            if let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer {
                let polygonViewPoint: CGPoint = renderer.point(for: point)
                if renderer.path.contains(polygonViewPoint) {
                    if selectedRegions.contains(polygon.title!) {
                        selectedRegions.remove(at: selectedRegions.firstIndex(of: polygon.title!)!)
                        renderer.fillColor = unselectedColor
                    } else {
                        selectedRegions.append(polygon.title!)
                        renderer.fillColor = selectedColor
                    }

                    renderer.strokeColor = strokeColor
                    renderer.lineWidth = 1.0
                    renderer.setNeedsDisplay()

                    selectedRegions.sort()
                    
                    let textField = UITextField()
                    populateRegionText(selectedRegions, textView: textField)
                    regions = textField.text!
                }
            }
        }
    }
}
