//
//  FilterViewController.swift
//  anti-piracy-iOS-app
//


import UIKit
import CoreData
import MapKit

class FilterViewController: SubregionDisplayViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    @IBAction func hideKeyboard(sender: AnyObject) {
         scrollView.endEditing(true)
    }
    
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var selectedInterval: UITextField!
    @IBOutlet weak var shiftKeyword: NSLayoutConstraint!
    @IBOutlet weak var currentSubregionEnabled: UISwitch!

    @IBOutlet weak var scrollView: UIScrollView!
    var currentSubregion = Filter.Basic.DEFAULT_SUBREGION
    var dateIntervalPicker: UIPickerView!
    var dateFormatter = NSDateFormatter()
    var subregionLocation = CurrentSubregion()



    var locationManager: CLLocationManager!
    var currentLocation: CLLocation? = nil
    var locationFixAchieved = false
    var isInitialAuthorizationCheck = false

    var subregionInitialized = false
    let pickerData = [Date.ALL, Date.DAYS_30, Date.DAYS_60, Date.DAYS_120, Date.YEARS_1]
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        dateFormatter.dateFormat = Date.FORMAT
        
        dateIntervalPicker = UIPickerView()
        dateIntervalPicker.dataSource = self
        dateIntervalPicker.delegate = self
        selectedInterval.inputView = dateIntervalPicker

        userBasicFilters()
    }
    

    
    @IBAction func dateIntervalEditBegin(sender: AnyObject) {
            selectedInterval.text = pickerData[Date.DEFAULT]
    }
    
    
    func userBasicFilters() {
        
        if let userDefaultInterval = defaults.stringForKey(Filter.Basic.DATE_INTERVAL) {
            selectedInterval.text = userDefaultInterval
        } else {
            selectedInterval.text = pickerData[Date.DEFAULT]
        }

        if let userDefaultKeyword = defaults.stringForKey(Filter.Basic.KEYWORD) {
            keyword.text = userDefaultKeyword
        } else {
            keyword.text = String()
        }
        
        let userDefaultCurrentEnabled = defaults.boolForKey(Filter.Basic.CURRENT_SUBREGION_ENABLED)
        currentSubregionEnabled.setOn(userDefaultCurrentEnabled, animated: false)
        if userDefaultCurrentEnabled {
            if let userDefaultCurrentSubregion = defaults.stringForKey(Filter.Basic.CURRENT_SUBREGION) {
                currentSubregion = userDefaultCurrentSubregion
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveBasicFilter() {
        defaults.setObject(Filter.BASIC_TYPE, forKey: Filter.FILTER_TYPE)
        defaults.setObject(selectedInterval.text, forKey: Filter.Basic.DATE_INTERVAL)
        defaults.setObject(keyword.text, forKey: Filter.Basic.KEYWORD)
        defaults.setBool(currentSubregionEnabled.on, forKey: Filter.Basic.CURRENT_SUBREGION_ENABLED)
        defaults.setObject(currentSubregion, forKey: Filter.Basic.CURRENT_SUBREGION)
    }
    
    
    @IBAction func switchCurrentSubregion(sender: AnyObject) {
        var canAskPermission = true
        
        if currentSubregionEnabled.on {
            if !subregionInitialized {
                subregionInitialized = true
                canAskPermission = false
                //First time: initialize a new CurrentSubregion,
                //  this will automatically trigger didChangeAuthorizationStatus
                //subregionLocation = CurrentSubregion(view: self)
                initLocationManager()
            }
            
            if !hasPermission() {
                if canAskPermission {
                    askPermission()
                }
                currentSubregionEnabled.setOn(false, animated: true)
            }
            
        }
    }
    
    
    func checkForCurrentSubregion() {
        if currentSubregionEnabled.on && subregionInitialized && hasPermission() {
            //Assumes location is found, otherwise will use a default
            currentSubregion = subregionLocation.calculateSubregion(currentLocation)
        }
    }
    
    
    @IBAction func clearBasicFilters(sender: AnyObject) {
        basicDefaults()
    }
    
    
    func basicDefaults() {
        selectedInterval.text = pickerData[Date.DEFAULT]
        keyword.text = String()
        currentSubregionEnabled.setOn(false, animated: false)
        currentSubregion = Filter.Basic.DEFAULT_SUBREGION
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "applyBasicFilter" {
            checkForCurrentSubregion()
            saveBasicFilter()
        }
    }
    
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    //MARK: Delegates
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInterval.text = pickerData[row]
    }


    //MARK: - Location Delegates and Functions
    //MARK: Location Functions
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    
    func askPermission() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "To enable Current Subregion, please open this app's settings and set location access to 'While Using the App'.",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func hasPermission() -> Bool {
        return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }
    

    //MARK: Location Delegates
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
    }

    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if status == .NotDetermined {
            isInitialAuthorizationCheck = true
            locationManager.requestWhenInUseAuthorization()
        } else if status != .AuthorizedWhenInUse {
            if !isInitialAuthorizationCheck {
                askPermission()
            }
            isInitialAuthorizationCheck = false
        }
        
        if status == .AuthorizedWhenInUse && !locationFixAchieved {
            currentSubregionEnabled.setOn(true, animated: true)
            locationManager.startUpdatingLocation()
        }
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            currentLocation = locationArray.lastObject as? CLLocation
            //Found a location, stop updating
            locationManager.stopUpdatingLocation()
        }
    }

   
}
