//
//  AdvancedFilterViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 6/23/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation


class SubregionViewController: SubregionDisplayViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var regionsText: UITextField!

    let defaults = NSUserDefaults.standardUserDefaults()
    
    let polygonUtil:PolygonUtil = PolygonUtil()
    var selectedRegions = Array<String>()
    
    let unselectedColor:UIColor = UIColor(red: 128/255.0, green: 255/255.0, blue: 130/255.0, alpha: 0.5)
    let selectedColor:UIColor   = UIColor(red: 0.0/255.0, green: 255/255.0, blue: 0.0/255.0, alpha: 0.9)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        //populate selected regions
        if let selectedRegions: Array<String> = defaults.objectForKey(Filter.Advanced.SELECTED_REGION) as? Array<String> {
            self.selectedRegions = selectedRegions
            populateRegionText(selectedRegions, textView: regionsText)
        }
        
        let subregionsMap:SubregionMap = SubregionMap();
        self.mapView.addOverlays(subregionsMap.polygons)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "action:")
        mapView.addGestureRecognizer(tapGesture)
    }
    
    //Offline Map Polygons
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        var polygonRenderer = MKPolygonRenderer(overlay: overlay);

        if let title = overlay.title {
            
            if contains(selectedRegions,overlay.title!)  {
                polygonRenderer.fillColor = selectedColor
            }
            else {
                polygonRenderer.fillColor = unselectedColor
            }            
            polygonRenderer.strokeColor = UIColor.blackColor()
            polygonRenderer.lineWidth = 1.0
        }
        return polygonRenderer
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {

        //where did the user click
        var touchPoint = gestureRecognizer.locationInView(self.mapView)
        var tapCoordinate:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        var point = MKMapPointForCoordinate(tapCoordinate)
        var mapRect = MKMapRectMake(point.x, point.y, 0, 0);
        
        //check overlays to see if polygon was pressed.
        for polygon in mapView.overlays as! [MKPolygon] {
            
            //quick check
            if polygon.intersectsMapRect(mapRect) {
                
                //comprehensive check
                if polygonUtil.isPointInPolygon(polygon, point: point) {

                    let renderer:MKPolygonRenderer = self.mapView.rendererForOverlay(polygon) as! MKPolygonRenderer
                    if contains(selectedRegions, polygon.title) {
                        selectedRegions.removeAtIndex(find(selectedRegions, polygon.title)!)
                        renderer.fillColor = unselectedColor
                    }
                    else {
                        selectedRegions.append(polygon.title)
                        renderer.fillColor = selectedColor

                    }
                    renderer.strokeColor = UIColor.blackColor()
                    renderer.lineWidth = 1.0
                    renderer.setNeedsDisplay()
                    
                    sort(&selectedRegions)
                    defaults.setObject(selectedRegions, forKey: Filter.Advanced.SELECTED_REGION)
                    populateRegionText(selectedRegions, textView: regionsText)
                }

            }
        
        }
        
    }

}