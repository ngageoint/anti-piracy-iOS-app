//
//  ViewController.swift
//  anti-piracy-iOS-app
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, AsamSelectDelegate, WebService {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var asamCountLabel: UILabel!
    @IBOutlet weak var asamMapViewDelegate: AsamMapViewDelegate!
    
    var asams = [AsamAnnotation]()
    var filterType = Filter.BASIC_TYPE
    var asamRetrieval: AsamRetrieval = AsamRetrieval()
    var model = AsamModelFacade()
    
    //Used for local testing, populates ~6.8K ASAMs
    //let asamJsonParser:AsamJsonParser = AsamJsonParser();

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let userDefaultFilterType = asamMapViewDelegate.defaults.string(forKey: Filter.FILTER_TYPE) {
            filterType = userDefaultFilterType
        }
        
        asamMapViewDelegate.asamSelectDelegate = self

        //clustering
        //asamMapViewDelegate.clusteringController = KPClusteringController(mapView: self.mapView)
        
        //Display existing Asams
        asams = retrieveAnnotations(filterType)
        //asamMapViewDelegate.clusteringController.setAnnotations(asams)

        asamRetrieval.delegate = self
        
        let firstLaunch = asamMapViewDelegate.defaults.bool(forKey: AppSettings.FIRST_LAUNCH)
        if !firstLaunch {
            asamRetrieval.searchAllAsams()
            asamMapViewDelegate.defaults.setValue(true, forKey: AppSettings.FIRST_LAUNCH)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd" //ex: "20150221"
            let startDate = formatter.string(from: model.getLatestAsamDate())
            let endDate = formatter.string(from: Foundation.Date())
            asamRetrieval.searchForAsams(startDate, endDate: endDate)
        }

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
        
        let mapSpan = MKCoordinateSpanMake(mapSpanLatitudeDelta, mapSpanLongitudeDelta)
        let mapCenter = CLLocationCoordinate2DMake(mapCenterLatitude, mapCenterLongitude)
        let mapRegion =  MKCoordinateRegionMake(mapCenter, mapSpan)
        
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
        
    }
    
    func didReceiveResponse(_ results: NSArray) {
        print("Success! Response was received.")

        if let json = results as? [[String:Any]] {
            model.populateEntity(json)
        }
        
        asams = retrieveAnnotations(filterType)
        
        //asamMapViewDelegate.clusteringController.setAnnotations(asams)
    }
    
    
    func retrieveAnnotations(_ filterType: String) -> [AsamAnnotation] {
        
        var annotations: [AsamAnnotation] = []

        let filteredAsams = model.getAsams(filterType)
        for asam in filteredAsams {
            // Drop a pin
            let newLocation = CLLocationCoordinate2DMake(asam.lat as Double, asam.lng as Double)
            let dropPin = AsamAnnotation(coordinate: newLocation, asam: asam)
            annotations.append(dropPin)
        }
        
        asamCountLabel.text = "Now Showing \(filteredAsams.count) ASAMS"
        return annotations
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    
    func asamSelected(_ asam: AsamAnnotation) {
        performSegue(withIdentifier: "singleAsamDetails", sender: asam.asam)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleAsamDetails") {
            let viewController: AsamDetailsViewController = segue.destination as! AsamDetailsViewController
            viewController.asam = sender as! Asam?
        } else if (segue.identifier == "listDisplayedAsams") {
            let listController = segue.destination as! ListTableViewController
           // let listController = navController.topViewController as! ListTableViewController
            listController.asams = asams
        }
    }
    
    
    @IBAction func unwindFromFilter(_ segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func applyFilters(_ segue:UIStoryboardSegue) {
        if segue.source.isKind(of: FilterViewController.self) {
            filterType = Filter.BASIC_TYPE
        }
        if let mapViewController = segue.source as? AdvFilterViewController {
            filterType = mapViewController.filterType
        }
        asams = retrieveAnnotations(filterType)
        //asamMapViewDelegate.clusteringController.setAnnotations(asams)
    }
    
}





