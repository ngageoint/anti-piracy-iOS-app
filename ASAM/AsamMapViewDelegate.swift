//
//  AsamMapViewDelegate.swift
//  anti-piracy-iOS-app
//


import Foundation
import MapKit

class AsamMapViewDelegate: NSObject, MKMapViewDelegate {
    
    var asamSelectDelegate : AsamSelectDelegate!
    
    let defaults = UserDefaults.standard
    let offlineMap:OfflineMap = OfflineMap()
    
    //Offline Map Polygons
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polygonRenderer = MKPolygonRenderer(overlay: overlay);
        
        if "ocean" == overlay.title! {
            polygonRenderer.fillColor = UIColor(red: 127/255.0, green: 153/255.0, blue: 171/255.0, alpha: 1.0)
            polygonRenderer.strokeColor = UIColor.clear
            polygonRenderer.lineWidth = 0.0
        }
        else {
            polygonRenderer.fillColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0)
            polygonRenderer.strokeColor = UIColor.clear
            polygonRenderer.lineWidth = 0.0
        }
        
        return polygonRenderer
    }

    //Clustering Annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        var annotationView : MKPinAnnotationView?
        /*
        if annotation is KPAnnotation {
            let kpAnnon : KPAnnotation = annotation as! KPAnnotation
            
            if kpAnnon.isCluster() {
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKPinAnnotationView
                
                if (annotationView == nil) {
                    annotationView = MKPinAnnotationView(annotation: kpAnnon, reuseIdentifier: "cluster")
                }
                
                //annotationView!.pinColor = .Purple
                annotationView!.image = ClusterImageGenerator.textToImage(String(kpAnnon.annotations.count), inImage: UIImage(named: "cluster")!)
                
            }
                
            else {
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
                
                if (annotationView == nil) {
                    annotationView = MKPinAnnotationView(annotation: kpAnnon, reuseIdentifier: "pin")
                }
                
                //annotationView!.pinColor = .Red
                annotationView!.image = UIImage(named: "pirate")
                
            }
            
            annotationView!.canShowCallout = true;
        }
         */
        
        return annotationView;
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // clusteringController.refresh(true)
        
        //persisting map center and span so that the map will return to this location.
        defaults.set(mapView.region.center.latitude, forKey: MapView.LATITUDE)
        defaults.set(mapView.region.center.longitude, forKey: MapView.LONGITUDE)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapView.LAT_DELTA)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapView.LON_DELTA)
        
        //print("Persisting Map Center (\(mapView.region.center.latitude), \(mapView.region.center.longitude))");
        //print("Persisting Map Deltas (lat delta: \(mapView.region.span.latitudeDelta), lon delta:\(mapView.region.span.longitudeDelta))");
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        /*
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
         */
        
    }
    
}
