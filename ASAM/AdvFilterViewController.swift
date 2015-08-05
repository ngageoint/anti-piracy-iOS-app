//
//  AdvFilterViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Chris Wasko on 7/31/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AdvFilterViewController: SubregionDisplayViewController {
    @IBAction func hideKeyboard(sender: AnyObject) {
        scrollView.endEditing(true)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activeTextField: UITextField!
    
    
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var errorTextDateRange: UILabel!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var regions: UITextField!
    
    var dateFormatter = NSDateFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var selectedRegions = Array<String>()
    
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
            startDate.text = dateFormatter.stringFromDate(NSDate())
        }
        
        if let userDefaultEndDate: NSDate = defaults.objectForKey("endDate") as? NSDate
        {
            println(userDefaultEndDate)
            endDate.text = dateFormatter.stringFromDate(userDefaultEndDate)
        }
        else {
            println("No default End Date found.")
            endDate.text = dateFormatter.stringFromDate(NSDate())
        }
        
        checkDateRange()
        
        if let selectedRegions:Array<String> = defaults.objectForKey("selectedRegions") as? Array<String> {
            self.selectedRegions = selectedRegions
            populateRegionText(selectedRegions, textView: regions)
        }
        
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
    
    
    
    //MARK: - Keyboard Management Methods
    
    // Call this method somewhere in your view controller setup code.
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let activeTextFieldRect: CGRect? = activeTextField?.frame
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        if (!CGRectContainsPoint(aRect, activeTextFieldOrigin!)) {
            scrollView.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    //MARK: - UITextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        activeTextField = textField
        scrollView.scrollEnabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        activeTextField = nil
        scrollView.scrollEnabled = false
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}