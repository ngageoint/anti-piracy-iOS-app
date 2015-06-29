//
//  AdvancedFilterViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 6/23/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation



class AdvancedFilterViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        let subregionsMap:SubregionMap = SubregionMap();
        self.mapView.addOverlays(subregionsMap.polygons)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "action:")
        mapView.addGestureRecognizer(tapGesture)
        
    }
    
    //Offline Map Polygons
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        

        
        
        var polygonRenderer = MKPolygonRenderer(overlay: overlay);

        if let title = overlay.title {
            polygonRenderer.fillColor = UIColor(red: 128/255.0, green: 255/255.0, blue: 130/255.0, alpha: 0.5)
            polygonRenderer.strokeColor = UIColor.blackColor()
            polygonRenderer.lineWidth = 1.0
        }
        
        return polygonRenderer
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {

        var touchPoint = gestureRecognizer.locationInView(self.mapView)
        var tapCoordinate:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        var point = MKMapPointForCoordinate(tapCoordinate)
        var mapRect = MKMapRectMake(point.x, point.y, 0, 0);

        
        for polygon in mapView.overlays as! [MKPolygon] {
            if polygon.intersectsMapRect(mapRect) {
                
                
                polygon.title = "selected"
                
                let renderer:MKPolygonRenderer = self.mapView.rendererForOverlay(polygon) as! MKPolygonRenderer
                renderer.fillColor = UIColor(red: 0.0/255.0, green: 255/255.0, blue: 0.0/255.0, alpha: 0.9)
                renderer.strokeColor = UIColor.blackColor()
                renderer.lineWidth = 1.0
                renderer.setNeedsDisplay()
                //self.mapView.setNeedsDisplay()
                
                //change the color somehow
                println("found")
                break
            }
        
        }
        
    }

}