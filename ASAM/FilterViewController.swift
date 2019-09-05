//
//  FilterViewController.swift
//  anti-piracy-iOS-app
//


import UIKit
import CoreData
import MapKit

class FilterViewController: SubregionDisplayViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    @IBAction func hideKeyboard(_ sender: AnyObject) {
         scrollView.endEditing(true)
    }
    
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var selectedInterval: UITextField!
    @IBOutlet weak var shiftKeyword: NSLayoutConstraint!
    @IBOutlet weak var currentSubregionEnabled: UISwitch!

    @IBOutlet weak var scrollView: UIScrollView!
    var currentSubregion = Filter.Basic.DEFAULT_SUBREGION
    var dateIntervalPicker: UIPickerView!
    var dateFormatter = DateFormatter()
    var subregionLocation = CurrentSubregion()

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation? = nil
    var locationFixAchieved = false
    var isInitialAuthorizationCheck = false

    var subregionInitialized = false
    let pickerData = [DateQuery.ALL, DateQuery.DAYS_30, DateQuery.DAYS_60, DateQuery.DAYS_120, DateQuery.YEARS_1]
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        dateFormatter.dateFormat = DateQuery.FORMAT
        
        dateIntervalPicker = UIPickerView()
        dateIntervalPicker.dataSource = self
        dateIntervalPicker.delegate = self
        selectedInterval.inputView = dateIntervalPicker

        userBasicFilters()
    }
    
    @IBAction func dateIntervalEditBegin(_ sender: AnyObject) {
        selectedInterval.text = pickerData[DateQuery.DEFAULT]
    }
    
    func userBasicFilters() {
        
        if let userDefaultInterval = UserDefaults.standard.string(forKey: Filter.Basic.DATE_INTERVAL) {
            selectedInterval.text = userDefaultInterval
        } else {
            selectedInterval.text = pickerData[DateQuery.DEFAULT]
        }

        if let userDefaultKeyword = UserDefaults.standard.string(forKey: Filter.Basic.KEYWORD) {
            keyword.text = userDefaultKeyword
        } else {
            keyword.text = String()
        }
        
        let userDefaultCurrentEnabled = UserDefaults.standard.bool(forKey: Filter.Basic.CURRENT_SUBREGION_ENABLED)
        currentSubregionEnabled.setOn(userDefaultCurrentEnabled, animated: false)
        if userDefaultCurrentEnabled {
            if let userDefaultCurrentSubregion = UserDefaults.standard.string(forKey: Filter.Basic.CURRENT_SUBREGION) {
                currentSubregion = userDefaultCurrentSubregion
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveBasicFilter() {
        UserDefaults.standard.set(Filter.BASIC_TYPE, forKey: Filter.FILTER_TYPE)
        UserDefaults.standard.set(selectedInterval.text, forKey: Filter.Basic.DATE_INTERVAL)
        UserDefaults.standard.set(keyword.text, forKey: Filter.Basic.KEYWORD)
        UserDefaults.standard.set(currentSubregionEnabled.isOn, forKey: Filter.Basic.CURRENT_SUBREGION_ENABLED)
        UserDefaults.standard.set(currentSubregion, forKey: Filter.Basic.CURRENT_SUBREGION)
    }
    
    @IBAction func switchCurrentSubregion(_ sender: AnyObject) {
        var canAskPermission = true
        
        if currentSubregionEnabled.isOn {
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
        if currentSubregionEnabled.isOn && subregionInitialized && hasPermission() {
            //Assumes location is found, otherwise will use a default
            currentSubregion = subregionLocation.calculateSubregion(currentLocation)
        }
    }
    
    @IBAction func clearBasicFilters(_ sender: AnyObject) {
        basicDefaults()
    }
    
    func basicDefaults() {
        selectedInterval.text = pickerData[DateQuery.DEFAULT]
        keyword.text = String()
        currentSubregionEnabled.setOn(false, animated: false)
        currentSubregion = Filter.Basic.DEFAULT_SUBREGION
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "applyBasicFilter" {
            checkForCurrentSubregion()
            saveBasicFilter()
        }
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hasPermission() -> Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    //MARK: Location Delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .notDetermined {
            isInitialAuthorizationCheck = true
            locationManager.requestWhenInUseAuthorization()
        } else if status != .authorizedWhenInUse {
            if !isInitialAuthorizationCheck {
                askPermission()
            }
            isInitialAuthorizationCheck = false
        }
        
        if status == .authorizedWhenInUse && !locationFixAchieved {
            currentSubregionEnabled.setOn(true, animated: true)
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            currentLocation = locationArray.lastObject as? CLLocation
            //Found a location, stop updating
            locationManager.stopUpdatingLocation()
        }
    }
}
