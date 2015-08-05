//
//  FilterViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 3/13/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: SubregionDisplayViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var regions: UITextField!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var dateIntervalPicker: UIPickerView!
    @IBOutlet weak var selectedInterval: UITextField!
    @IBOutlet weak var shiftKeyword: NSLayoutConstraint!

    
    var dateFormatter = NSDateFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerData = ["Last 30 Days", "Last 60 Days", "Last 120 Days", "Last 1 year"]
    
    var selectedRegions = Array<String>()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        dateFormatter.dateFormat = AsamDateFormat.dateFormat
        
        if let selectedRegions:Array<String> = defaults.objectForKey("selectedRegions") as? Array<String> {
            self.selectedRegions = selectedRegions
            populateRegionText(selectedRegions, textView: regions)
        }
        
        //for swipe down gesture
        var swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissControlWithSwipe")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipe)
        
        //for picker
        hidePicker()
        dateIntervalPicker.dataSource = self
        dateIntervalPicker.delegate = self
        
        
    }
    
    func hidePicker() {
        dateIntervalPicker.hidden = true
        shiftKeyword.priority = 1000
    }
    
    func showPicker() {
        dateIntervalPicker.hidden = false
        shiftKeyword.priority = 250
    }
    
    //for swipe down gesture
    func dismissControlWithSwipe() {
        self.keyword.resignFirstResponder()
        self.regions.resignFirstResponder()
    }
    
    //Clicking outside a textbox will close the datepicker or keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectStartDate(sender: UITextField) {
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        
        //set date picker if user default exists
        if let userDefaultStartDate: NSDate = defaults.objectForKey("startDate") as? NSDate
        {
            datePickerView.date = userDefaultStartDate
        }
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleStartDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
//    func handleStartDatePicker(sender: UIDatePicker) {
//        startDate.text = dateFormatter.stringFromDate(sender.date)
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setObject(sender.date, forKey: "startDate")
//        checkDateRange()
//    }
    
    
    @IBAction func selectEndDate(sender: UITextField) {
        
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        //set date picker if user default exists
        if let userDefaultEndDate: NSDate = defaults.objectForKey("endDate") as? NSDate
        {
            datePickerView.date = userDefaultEndDate
        }
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleEndDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
//    func handleEndDatePicker(sender: UIDatePicker) {
//        endDate.text = dateFormatter.stringFromDate(sender.date)
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setObject(sender.date, forKey: "endDate")
//        checkDateRange()
//    }
//    
//    func checkDateRange() {
//    
//        let date1 = dateFormatter.dateFromString(startDate.text)
//        let date2 =   dateFormatter.dateFromString(endDate.text)
//        
//        if date1?.compare(date2!) == NSComparisonResult.OrderedDescending {
//            println("Date Range Invalid")
//            errorTextDateRange.hidden = false
//        }
//        else {
//            println("Date Range Valid")
//            errorTextDateRange.hidden = true
//        }
//        
//    }
    
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInterval.text = pickerData[row]
    }

}
