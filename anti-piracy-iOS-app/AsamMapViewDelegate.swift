//
//  AsamMapViewDelegate.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 4/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation


class AsamMapViewDelegate: NSObject, MKMapViewDelegate, KPClusteringControllerDelegate {
    
    var clusteringController : KPClusteringController!
    var asamSelectDelegate : AsamSelectDelegate!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let offlineMap:OfflineMap = OfflineMap()
    
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
            }
            else if cluster.annotations.count == 1 {
                //drive to Asam Details page
                asamSelectDelegate.asamSelected(cluster.annotations.allObjects[0] as AsamAnnotation)
            }
            
        }
        
    }
    
    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        return true
    }
    
}