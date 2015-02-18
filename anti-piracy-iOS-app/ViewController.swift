//
//  ViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/6/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let path = NSBundle.mainBundle().pathForResource("ne_50m_land.simplify0.2", ofType: "geojson")
    let offlineMap:OfflineMap = OfflineMap()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showActionSheet(sender: AnyObject) {
    
        // Action Sheet Label
        let optionMenu = UIAlertController(title: nil, message: "Select Map Type", preferredStyle: .ActionSheet)
        
        // Action Sheet Options
        let standardMapAction = UIAlertAction(title: "Standard", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Standard Map")
            
            self.mapView.mapType = MKMapType.Standard
            
        })
        let satelliteMapAction = UIAlertAction(title: "Satellite", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Satellite Map")
            
            self.mapView.mapType = MKMapType.Satellite
            
        })
        let hybridMapAction = UIAlertAction(title: "Hybrid", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Hybrid Map")
            
            self.mapView.mapType = MKMapType.Hybrid
            
        })
        let offlineMapAction = UIAlertAction(title: "Offline", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Offline Map")

            self.mapView.mapType = MKMapType.Standard
            self.mapView.addOverlays(self.offlineMap.polygons)
            
            
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

