//
//  AdvancedFilterViewController.swift
//  anti-piracy-iOS-app
//

import Foundation
import MapKit


class SubregionViewController: SubregionDisplayViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var regionsText: UITextField!

    let defaults = UserDefaults.standard
    
    let polygonIntersection:Polygon = Polygon()
    var selectedRegions = Array<String>()
    var regions = String()
    let unselectedColor:UIColor = UIColor(red: 128/255.0, green: 255/255.0, blue: 130/255.0, alpha: 0.5)
    let selectedColor:UIColor   = UIColor(red: 0.0/255.0, green: 255/255.0, blue: 0.0/255.0, alpha: 0.9)
    
    @IBAction func clearSelected(_ sender: AnyObject) {
        regionsText.text = String()
        
        for polygon in mapView.overlays as! [MKPolygon] {
            let renderer:MKPolygonRenderer = self.mapView.renderer(for: polygon) as! MKPolygonRenderer
            
            if selectedRegions.contains(polygon.title!) {
                selectedRegions.remove(at: selectedRegions.index(of: polygon.title!)!)
            }
            
            renderer.fillColor = unselectedColor
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        regionsText.text = regions
        
        //populate selected regions
        populateRegionText(selectedRegions, textView: regionsText)
        
        let subregionsMap:SubregionMap = SubregionMap();
        self.mapView.addOverlays(subregionsMap.polygons)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SubregionViewController.action(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    //Offline Map Polygons
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polygonRenderer = MKPolygonRenderer(overlay: overlay);

        if let title = overlay.title {
            
            if selectedRegions.contains(title!)  {
                polygonRenderer.fillColor = selectedColor
            }
            else {
                polygonRenderer.fillColor = unselectedColor
            }            
            polygonRenderer.strokeColor = UIColor.black
            polygonRenderer.lineWidth = 1.0
        }
        return polygonRenderer
    }
    
    func action(_ gestureRecognizer:UIGestureRecognizer) {

        //where did the user click
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let tapCoordinate:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let point = MKMapPointForCoordinate(tapCoordinate)
        let mapRect = MKMapRectMake(point.x, point.y, 0, 0);
        
        //check overlays to see if polygon was pressed.
        for polygon in mapView.overlays as! [MKPolygon] {
            
            //quick check
            if polygon.intersects(mapRect) {
                
                //comprehensive check
                if self.polygonIntersection.isPointInPolygon(polygon, point: point) {

                    let renderer:MKPolygonRenderer = self.mapView.renderer(for: polygon) as! MKPolygonRenderer
                    if selectedRegions.contains(polygon.title!) {
                        selectedRegions.remove(at: selectedRegions.index(of: polygon.title!)!)
                        renderer.fillColor = unselectedColor
                    }
                    else {
                        selectedRegions.append(polygon.title!)
                        renderer.fillColor = selectedColor

                    }
                    renderer.strokeColor = UIColor.black
                    renderer.lineWidth = 1.0
                    renderer.setNeedsDisplay()
                    
                    selectedRegions.sort()
                    populateRegionText(selectedRegions, textView: regionsText)
                    regions = regionsText.text!
                }

            }
        
        }
        
    }

}
