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
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polygonRenderer = MKPolygonRenderer(overlay: overlay);
        
        if "ocean" == overlay.title! {
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
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        var annotationView : MKPinAnnotationView?
        
        if annotation is KPAnnotation {
            let kpAnnon : KPAnnotation = annotation as! KPAnnotation
            
            if kpAnnon.isCluster() {
                annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("cluster") as? MKPinAnnotationView
                
                if (annotationView == nil) {
                    annotationView = MKPinAnnotationView(annotation: kpAnnon, reuseIdentifier: "cluster")
                }
                
                //annotationView!.pinColor = .Purple
                annotationView!.image = ClusterImageGenerator.textToImage(String(kpAnnon.annotations.count), inImage: UIImage(named: "cluster")!)
                
            }
                
            else {
                annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
                
                if (annotationView == nil) {
                    annotationView = MKPinAnnotationView(annotation: kpAnnon, reuseIdentifier: "pin")
                }
                
                //annotationView!.pinColor = .Red
                annotationView!.image = UIImage(named: "pirate")
                
            }
            
            annotationView!.canShowCallout = true;
        }
        
        return annotationView;
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusteringController.refresh(true)
        
        //persisting map center and span so that the map will return to this location.
        defaults.setDouble(mapView.region.center.latitude, forKey: MapView.LATITUDE)
        defaults.setDouble(mapView.region.center.longitude, forKey: MapView.LONGITUDE)
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: MapView.LAT_DELTA)
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: MapView.LON_DELTA)
        
        //print("Persisting Map Center (\(mapView.region.center.latitude), \(mapView.region.center.longitude))");
        //print("Persisting Map Deltas (lat delta: \(mapView.region.span.latitudeDelta), lon delta:\(mapView.region.span.longitudeDelta))");
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if view.annotation is KPAnnotation {
            let cluster : KPAnnotation = view.annotation as! KPAnnotation
            
            if cluster.annotations.count > 1 {
                let region = MKCoordinateRegionMakeWithDistance(cluster.coordinate,
                    cluster.radius * 2.5,
                    cluster.radius * 2.5)
                
                mapView.setRegion(region, animated: true)
            }
            else if cluster.annotations.count == 1 {
                //drive to Asam Details page
                asamSelectDelegate.asamSelected(cluster.annotations.first as! AsamAnnotation)
                
            }
            
        }
        
    }
    
    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        return true
    }
    
}