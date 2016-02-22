//
//  ViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 2/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
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
    let asamJsonParser:AsamJsonParser = AsamJsonParser();

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let userDefaultFilterType = asamMapViewDelegate.defaults.stringForKey(Filter.FILTER_TYPE) {
            filterType = userDefaultFilterType
        }
        
        asamMapViewDelegate.asamSelectDelegate = self

        //clustering
        asamMapViewDelegate.clusteringController = KPClusteringController(mapView: self.mapView)
        
        //Display existing Asams
        asams = retrieveAnnotations(filterType)
        asamMapViewDelegate.clusteringController.setAnnotations(asams)

        asamRetrieval.delegate = self
        
        let firstLaunch = asamMapViewDelegate.defaults.boolForKey(AppSettings.FIRST_LAUNCH)
        if !firstLaunch {
            asamRetrieval.searchAllAsams()
            asamMapViewDelegate.defaults.setValue(true, forKey: AppSettings.FIRST_LAUNCH)
        } else {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMdd" //ex: "20150221"
            let startDate = formatter.stringFromDate(model.getLatestAsamDate())
            let endDate = formatter.stringFromDate(NSDate())
            asamRetrieval.searchForAsams(startDate, endDate: endDate)
        }
        
        configureMap()
        
    }
    
    
    func configureMap() {
        //rebuild map center and map span from persisted user data
        var mapCenterLatitude:  Double = asamMapViewDelegate.defaults.doubleForKey(MapView.LATITUDE)
        var mapCenterLongitude: Double = asamMapViewDelegate.defaults.doubleForKey(MapView.LONGITUDE)
        var mapSpanLatitudeDelta: Double = asamMapViewDelegate.defaults.doubleForKey(MapView.LAT_DELTA)
        var mapSpanLongitudeDelta: Double = asamMapViewDelegate.defaults.doubleForKey(MapView.LON_DELTA)
        
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
        if let mapType = asamMapViewDelegate.defaults.stringForKey(MapView.MAP_TYPE) {
            switch mapType {
            case "Standard":
                self.mapView.mapType = MKMapType.Standard
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            case "Satellite":
                self.mapView.mapType = MKMapType.Satellite
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            case "Hybrid":
                self.mapView.mapType = MKMapType.Hybrid
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            case "Offline":
                self.mapView.mapType = MKMapType.Standard
                self.mapView.addOverlays(asamMapViewDelegate.offlineMap.polygons)
            default:
                self.mapView.mapType = MKMapType.Standard
                self.mapView.removeOverlays(asamMapViewDelegate.offlineMap.polygons)
            }
        }
        
    }
    
    
    func didReceiveResponse(results: NSArray) {
        print("Success! Response was received.")

        model.populateEntity(results)
        
        asams = retrieveAnnotations(filterType)
        
        asamMapViewDelegate.clusteringController.setAnnotations(asams)
    }
    
    
    func retrieveAnnotations(filterType: String) -> [AsamAnnotation] {
        
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
    
        
    @IBAction func showLayerActionSheet(sender: UIButton) {
        
        // Action Sheet Label
        let optionMenu = UIAlertController(title: nil, message: "Select Map Type", preferredStyle: .ActionSheet)
        
        // Action Sheet Options
        let standardMapAction = UIAlertAction(title: "Standard", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.Standard
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Standard", forKey: MapView.MAP_TYPE)
        })
        let satelliteMapAction = UIAlertAction(title: "Satellite", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.Satellite
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Satellite", forKey: MapView.MAP_TYPE)

        })
        let hybridMapAction = UIAlertAction(title: "Hybrid", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.Hybrid
            self.mapView.removeOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Hybrid", forKey: MapView.MAP_TYPE)
        })
        let offlineMapAction = UIAlertAction(title: "Offline", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            self.mapView.mapType = MKMapType.Standard
            self.mapView.addOverlays(self.asamMapViewDelegate.offlineMap.polygons)
            self.asamMapViewDelegate.defaults.setObject("Offline", forKey: MapView.MAP_TYPE)
        })
        
        // Action Sheet Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
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
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    

    @IBAction func setupSegueToFilter(sender: AnyObject) {
        if filterType == Filter.ADVANCED_TYPE {
            performSegueWithIdentifier("advancedFilter", sender: self)
        } else {
            performSegueWithIdentifier("basicFilter", sender: self)
        }
    }
    
    
    func asamSelected(asam: AsamAnnotation) {
        performSegueWithIdentifier("singleAsamDetails", sender: asam)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "singleAsamDetails") {
            let viewController: AsamDetailsViewController = segue!.destinationViewController as! AsamDetailsViewController
            viewController.asam = (sender as! AsamAnnotation).asam
        } else if (segue?.identifier == "listDisplayedAsams") {
            let navController = segue!.destinationViewController as! UINavigationController
            let listController = navController.topViewController as! ListTableViewController
            listController.asams = asams
        }
    }
    
    
    @IBAction func unwindFromFilter(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func applyFilters(segue:UIStoryboardSegue) {
        if segue.sourceViewController.isKindOfClass(FilterViewController) {
            filterType = Filter.BASIC_TYPE
        }
        if let mapViewController = segue.sourceViewController as? AdvFilterViewController {
            filterType = mapViewController.filterType
        }
        asams = retrieveAnnotations(filterType)
        asamMapViewDelegate.clusteringController.setAnnotations(asams)
    }
    
}





