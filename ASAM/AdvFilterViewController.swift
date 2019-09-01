//
//  AdvFilterViewController.swift
//  anti-piracy-iOS-app
//


import Foundation
import UIKit
import CoreData

class AdvFilterViewController: SubregionDisplayViewController, UITextFieldDelegate {
    @IBAction func hideKeyboard(_ sender: AnyObject) {
        scrollView.endEditing(true)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var errorTextDateRange: UILabel!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var regions: UITextField!
    @IBOutlet weak var refNumStart: UITextField!
    @IBOutlet weak var refNumEnd: UITextField!
    @IBOutlet weak var victim: UITextField!
    @IBOutlet weak var aggressor: UITextField!
    
    let dateFormatter = DateFormatter()
    let defaults = UserDefaults.standard
    
    var selectedRegions = Array<String>()
    var filterType = Filter.BASIC_TYPE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        regions.delegate = self
        dateFormatter.dateFormat = DateQuery.FORMAT
        userAdvancedFilters()
    }
    
    @IBAction func selectStartDate(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        //set date picker if user default exists
        if let userDefaultStartDate: Foundation.Date = defaults.object(forKey: Filter.Advanced.START_DATE) as? Foundation.Date {
            datePickerView.date = userDefaultStartDate
        }
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AdvFilterViewController.handleStartDatePicker(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func handleStartDatePicker(_ sender: UIDatePicker) {
        startDate.text = dateFormatter.string(from: sender.date)
        let defaults = UserDefaults.standard
        defaults.set(sender.date, forKey: Filter.Advanced.START_DATE)
        checkDateRange()
    }
    
    @IBAction func selectEndDate(_ sender: UITextField) {
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        //set date picker if user default exists
        if let userDefaultEndDate: Foundation.Date = defaults.object(forKey: Filter.Advanced.END_DATE) as? Foundation.Date {
            datePickerView.date = userDefaultEndDate
        }
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AdvFilterViewController.handleEndDatePicker(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func handleEndDatePicker(_ sender: UIDatePicker) {
        endDate.text = dateFormatter.string(from: sender.date)
        let defaults = UserDefaults.standard
        defaults.set(sender.date, forKey: Filter.Advanced.END_DATE)
        checkDateRange()
    }
    
    func checkDateRange() {
        let date1 = dateFormatter.date(from: startDate.text!)
        let date2 = dateFormatter.date(from: endDate.text!)
        
        if date1?.compare(date2!) == ComparisonResult.orderedDescending {
            print("Date Range Invalid")
            errorTextDateRange.isHidden = false
        }
        else {
            print("Date Range Valid")
            errorTextDateRange.isHidden = true
        }
    }

    func userAdvancedFilters() {
        
        advancedDefaults()
        
        //Apply user defaults if available
        if let userDefaultStartDate: Foundation.Date = defaults.object(forKey: Filter.Advanced.START_DATE) as? Foundation.Date {
            startDate.text = dateFormatter.string(from: userDefaultStartDate)
        }

        if let userDefaultEndDate: Foundation.Date = defaults.object(forKey: Filter.Advanced.END_DATE) as? Foundation.Date {
            print(userDefaultEndDate)
            endDate.text = dateFormatter.string(from: userDefaultEndDate)
        }

        checkDateRange()

        if let userDefaultKeyword = defaults.string(forKey: Filter.Advanced.KEYWORD) {
            keyword.text = userDefaultKeyword
        }
        
        if let userDefaultSelectedRegions:Array<String> = defaults.object(forKey: Filter.Advanced.SELECTED_REGION) as? Array<String> {
            self.selectedRegions = userDefaultSelectedRegions
            populateRegionText(userDefaultSelectedRegions, textView: regions)
        }

        if let userDefaultRefNum = defaults.string(forKey: Filter.Advanced.REFERENCE_NUM) {
            let refNum = userDefaultRefNum.components(separatedBy: Filter.Advanced.REF_SEPARATER)
            refNumStart.text = refNum[0]
            refNumEnd.text = refNum[1]
        }
        
        if let userDefaultVictim = defaults.string(forKey: Filter.Advanced.VICTIM) {
            victim.text = userDefaultVictim
        }
        
        if let userDefaultAggressor = defaults.string(forKey: Filter.Advanced.HOSTILITY) {
            aggressor.text = userDefaultAggressor
        }
    }

    func saveAdvancedFilter() {
        if checkForClearedFilter() {
            defaults.set(Filter.BASIC_TYPE, forKey: Filter.FILTER_TYPE)
            filterType = Filter.BASIC_TYPE
        } else {
            defaults.set(Filter.ADVANCED_TYPE, forKey: Filter.FILTER_TYPE)
            filterType = Filter.ADVANCED_TYPE
        }
        
        defaults.set(dateFormatter.date(from: startDate.text!), forKey: Filter.Advanced.START_DATE)
        defaults.set(dateFormatter.date(from: endDate.text!), forKey: Filter.Advanced.END_DATE)
        defaults.set(keyword.text, forKey: Filter.Advanced.KEYWORD)
        defaults.set(selectedRegions, forKey: Filter.Advanced.SELECTED_REGION)
        defaults.set(refNumStart.text! + Filter.Advanced.REF_SEPARATER + refNumEnd.text!, forKey: Filter.Advanced.REFERENCE_NUM)
        defaults.set(victim.text, forKey: Filter.Advanced.VICTIM)
        defaults.set(aggressor.text, forKey: Filter.Advanced.HOSTILITY)
    }
    
    func checkForClearedFilter() -> Bool {
        var isCleared = false;
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Foundation.Date())
        let approxOneYearAgo = (calendar as NSCalendar).date(byAdding: .year, value: -1, to: today, options: [])!
        
        dateFormatter.dateStyle = .short
        
        let theDate = dateFormatter.string(from: approxOneYearAgo)

        if startDate.text == theDate &&
            endDate.text == dateFormatter.string(from: Foundation.Date()) &&
            keyword.text == String() &&
            regions.text == String() &&
            selectedRegions.isEmpty &&
            refNumStart.text == String() &&
            refNumEnd.text == String() &&
            victim.text == String() &&
            aggressor.text == String() {
                isCleared = true
        }

        return isCleared
    }
    
    @IBAction func clearAdvancedFilters(_ sender: AnyObject) {
        advancedDefaults()
    }
    
    func advancedDefaults() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Foundation.Date())
        let approxOneYearAgo = (calendar as NSCalendar).date(byAdding: .year, value: -1, to: today, options: [])!
        
        dateFormatter.dateStyle = .short
        
        let theDate = dateFormatter.string(from: approxOneYearAgo)

        startDate.text = theDate
        endDate.text = dateFormatter.string(from: Foundation.Date())
        keyword.text = String()
        regions.text = String()
        selectedRegions = Array<String>()
        refNumStart.text = String()
        refNumEnd.text = String()
        victim.text = String()
        aggressor.text = String()
    }
    
    override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
        if segue?.identifier == "applyAdvancedFilter" {
            saveAdvancedFilter()
        } else if (segue?.identifier == "changeSubregions") {
            let viewController: SubregionViewController = segue!.destination as! SubregionViewController
            viewController.regions = regions.text!
            viewController.selectedRegions = selectedRegions
        }
    }
    
    //MARK: - Keyboard Management Methods
    
    // Call this method somewhere in your view controller setup code.
    func registerForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
            selector: #selector(AdvFilterViewController.keyboardWillBeShown(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: #selector(AdvFilterViewController.keyboardWillBeHidden(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    // Called when the UIKeyboardDidShowNotification is sent.
    @objc func keyboardWillBeShown(_ sender: Notification) {
        let info: NSDictionary = sender.userInfo! as NSDictionary
        let value: NSValue = info.value(forKey: UIResponder.keyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let activeTextFieldRect: CGRect? = aggressor?.frame
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        if (!aRect.contains(activeTextFieldOrigin!)) {
            scrollView.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    @objc func keyboardWillBeHidden(_ sender: Notification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    //MARK: - UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        aggressor = textField
        scrollView.isScrollEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        aggressor = nil
        scrollView.isScrollEnabled = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "changeSubregions", sender: self)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func unwindSubregionFilters(_ segue:UIStoryboardSegue) {
        if let controller = segue.source as? SubregionViewController {
            regions.text = controller.regions
            selectedRegions = controller.selectedRegions
        }
    }
}
