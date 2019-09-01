//
//  AsamMapViewDelegate.swift
//  anti-piracy-iOS-app
//

import Foundation
import MapKit

class AsamMapViewDelegate: NSObject, MKMapViewDelegate {
    
    var delegate : AsamSelectDelegate!
    
    let defaults = UserDefaults.standard
    let offlineMap:OfflineMap = OfflineMap()
    
    //Offline Map Polygons
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonRenderer = MKPolygonRenderer(overlay: overlay);
        
        if "ocean" == overlay.title! {
            polygonRenderer.fillColor = UIColor(red: 127/255.0, green: 153/255.0, blue: 171/255.0, alpha: 1.0)
            polygonRenderer.strokeColor = UIColor.clear
            polygonRenderer.lineWidth = 0.0
        } else {
            polygonRenderer.fillColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0)
            polygonRenderer.strokeColor = UIColor.clear
            polygonRenderer.lineWidth = 0.0
        }
        
        return polygonRenderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        switch view {
            case is AsamClusterAnnotationView:
                let annotations = (view.annotation as! MKClusterAnnotation).memberAnnotations as! [AsamAnnotation]
                delegate.clusterSelected(asams: annotations)
            default:
                delegate.asamSelected(view.annotation as! AsamAnnotation)

        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //persisting map center and span so that the map will return to this location.
        defaults.set(mapView.region.center.latitude, forKey: MapView.LATITUDE)
        defaults.set(mapView.region.center.longitude, forKey: MapView.LONGITUDE)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapView.LAT_DELTA)
        defaults.set(mapView.region.span.latitudeDelta, forKey: MapView.LON_DELTA)
    }
}
