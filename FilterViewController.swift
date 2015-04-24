//
//  FilterViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 3/13/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UIViewController {
    
    @IBOutlet var startDate: UITextField!
    @IBOutlet var endDate: UITextField!
    @IBOutlet var errorTextDateRange: UILabel!

    var dateFormatter = NSDateFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        dateFormatter.dateFormat = AsamDateFormat.dateFormat
        
        //setting user defaults if there are any
        if let userDefaultStartDate: NSDate = defaults.objectForKey("startDate") as? NSDate
        {
            println(userDefaultStartDate)
            startDate.text = dateFormatter.stringFromDate(userDefaultStartDate)
        }
        else {
            println("No default Start Date found.")
        }

        if let userDefaultEndDate: NSDate = defaults.objectForKey("endDate") as? NSDate
        {
            println(userDefaultEndDate)
            endDate.text = dateFormatter.stringFromDate(userDefaultEndDate)
        }
        else {
            println("No default End Date found.")
        }
        
        checkDateRange()
        
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
    
    func handleStartDatePicker(sender: UIDatePicker) {
        startDate.text = dateFormatter.stringFromDate(sender.date)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sender.date, forKey: "startDate")
        checkDateRange()
    }
    
    
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
    
    func handleEndDatePicker(sender: UIDatePicker) {
        endDate.text = dateFormatter.stringFromDate(sender.date)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sender.date, forKey: "endDate")
        checkDateRange()
    }
    
    func checkDateRange() {
    
        let date1 = dateFormatter.dateFromString(startDate.text)
        let date2 =   dateFormatter.dateFromString(endDate.text)
        
        if date1?.compare(date2!) == NSComparisonResult.OrderedDescending {
            println("Date Range Invalid")
            errorTextDateRange.hidden = false
        }
        else {
            println("Date Range Valid")
            errorTextDateRange.hidden = true
        }
        
    }
    
}
