//
//  ViewController.swift
//  anti-piracy-iOS-app
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, AsamSelectDelegate {
    static var clusteringIdentifierCount = 1

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    
    var asams = [Asam]()
    var annotations = [String:Asam]()
    var filterType = Filter.BASIC_TYPE
    var model = AsamModelFacade()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.barStyle = .black
        navigationController?.setNavigationBarHidden(false, animated: true)

        if let userDefaultFilterType = asamMapViewDelegate.defaults.string(forKey: Filter.FILTER_TYPE) {
            filterType = userDefaultFilterType
        }
        
        asamMapViewDelegate.delegate = self
        mapView.register(AsamMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(AsamClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    
        configureMap()
    }
    
    func configureMap() {
        //rebuild map center and map span from persisted user data
        var mapCenterLatitude:  Double = asamMapViewDelegate.defaults.double(forKey: MapView.LATITUDE)
        var mapCenterLongitude: Double = asamMapViewDelegate.defaults.double(forKey: MapView.LONGITUDE)
        var mapSpanLatitudeDelta: Double = asamMapViewDelegate.defaults.double(forKey: MapView.LAT_DELTA)
        var mapSpanLongitudeDelta: Double = asamMapViewDelegate.defaults.double(forKey: MapView.LON_DELTA)
        
        if mapCenterLatitude.isNaN {
            mapCenterLatitude = 0.0
        }
        
        if mapCenterLongitude.isNaN {
            mapCenterLongitude = 0.0
        }
        
        if mapSpanLatitudeDelta == 0 {
            mapSpanLatitudeDelta = 50.0
        }
        
        if mapSpanLongitudeDelta == 0 {
            mapSpanLongitudeDelta = 50.0
        }
        print("Retrieving Map Center (\(mapCenterLatitude)," +
            "\(mapCenterLongitude))");
        print("Retrieving Map Deltas (lat delta: \(mapSpanLatitudeDelta)," +
            "lon delta:\(mapSpanLongitudeDelta))");
        
        let mapSpan = MKCoordinateSpan.init(latitudeDelta: mapSpanLatitudeDelta, longitudeDelta: mapSpanLongitudeDelta)
        let mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
        let mapRegion =  MKCoordinateRegion.init(center: mapCenter, span: mapSpan)
        
        self.mapView.region = mapRegion
        
        //set map type from persisted user data
        if let mapType = asamMapViewDelegate.defaults.string(forKey: MapView.MAP_TYPE) {
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
        
        // Display existing Asams
        addAsams(filterType)
    }
    
    func addAsams(_ filterType: String) {
        MapViewController.clusteringIdentifierCount += 1
        
        var newAnnotations = [String:Asam]()
        asams = model.getAsams(filterType)
        
        for asam in asams {
            if (annotations[asam.reference] == nil) {
                mapView.addAnnotation(asam)
                newAnnotations[asam.reference] = asam
            } else {
                newAnnotations[asam.reference] = annotations[asam.reference]
            }
        }
        
        var allReferences = Set(annotations.keys)
        allReferences.subtract(Set(newAnnotations.keys))
        for reference in allReferences {
            if let annotation = annotations[reference] {
                mapView.removeAnnotation(annotation)
            }
        }

        navigationItem.prompt = "\(asams.count) ASAMs match filter"
        annotations = newAnnotations
    }
    
    @IBAction func showLayerActionSheet(_ sender: UIButton) {
        
        // Action Sheet Label
        let optionMenu = UIAlertController(title: nil, message: "Select Map Type", preferredStyle: .actionSheet)
        
        // Action Sheet Options
        let standardMapAction = UIAlertAction(title: "Standard", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.standard
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.set("Standard", forKey: MapView.MAP_TYPE)
        })
        let satelliteMapAction = UIAlertAction(title: "Satellite", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.satellite
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.set("Satellite", forKey: MapView.MAP_TYPE)

        })
        let hybridMapAction = UIAlertAction(title: "Hybrid", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.hybrid
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.set("Hybrid", forKey: MapView.MAP_TYPE)
        })
        let offlineMapAction = UIAlertAction(title: "Offline", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.standard
            self.mapView.addOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.set("Offline", forKey: MapView.MAP_TYPE)
        })
        
        // Action Sheet Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled")
        })
        
        // Build Menu
        optionMenu.addAction(standardMapAction)
        optionMenu.addAction(satelliteMapAction)
        optionMenu.addAction(hybridMapAction)
        optionMenu.addAction(offlineMapAction)
        optionMenu.addAction(cancelAction)
        
        // Show Action Sheet
        self.present(optionMenu, animated: true, completion: nil)
    }
    

    @IBAction func setupSegueToFilter(_ sender: AnyObject) {
        if filterType == Filter.ADVANCED_TYPE {
            performSegue(withIdentifier: "advancedFilter", sender: self)
        } else {
            performSegue(withIdentifier: "basicFilter", sender: self)
        }
    }
    
    func asamSelected(_ asam: Asam) {
        performSegue(withIdentifier: "singleAsamDetails", sender: asam)
    }
    
    func clusterSelected(asams: [Asam]) {
        performSegue(withIdentifier: "listDisplayedAsams", sender: asams)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleAsamDetails") {
            let viewController: AsamDetailsViewController = segue.destination as! AsamDetailsViewController
            viewController.asam = sender as! Asam?
        } else if (segue.identifier == "listDisplayedAsams") {
            let listController = segue.destination as! ListTableViewController
            if let cluster = sender as? [Asam] {
                listController.asams = cluster.sorted() {$0.date > $1.date}
            } else {
                listController.asams = asams
            }
        }
    }
    
    @IBAction func unwindFromFilter(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func applyFilters(_ segue:UIStoryboardSegue) {
        if segue.source.isKind(of: FilterViewController.self) {
            filterType = Filter.BASIC_TYPE
        }
        
        if let advFilterController = segue.source as? AdvFilterViewController {
            filterType = advFilterController.filterType
        }
        
        addAsams(filterType)
    }
}
