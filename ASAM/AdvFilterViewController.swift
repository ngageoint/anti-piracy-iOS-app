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
 
    
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var errorTextDateRange: UILabel!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var regions: UITextField!
    @IBOutlet weak var refNumStart: UITextField!
    @IBOutlet weak var refNumEnd: UITextField!
    @IBOutlet weak var victim: UITextField!
    @IBOutlet weak var aggressor: UITextField!
    
    
    
    let dateFormatter = NSDateFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var selectedRegions = Array<String>()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dateFormatter.dateFormat = AsamDateFormat.dateFormat
        
        refNumStart.keyboardType = UIKeyboardType.NumberPad
        refNumEnd.keyboardType = UIKeyboardType.NumberPad
        
        userAdvancedFilters()
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectStartDate(sender: UITextField) {
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        
        //set date picker if user default exists
        if let userDefaultStartDate: NSDate = defaults.objectForKey(Filter.Advanced.START_DATE) as? NSDate
        {
            datePickerView.date = userDefaultStartDate
        }
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleStartDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleStartDatePicker(sender: UIDatePicker) {
        startDate.text = dateFormatter.stringFromDate(sender.date)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sender.date, forKey: Filter.Advanced.START_DATE)
        checkDateRange()
    }
    
    
    @IBAction func selectEndDate(sender: UITextField) {
        
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        //set date picker if user default exists
        if let userDefaultEndDate: NSDate = defaults.objectForKey(Filter.Advanced.END_DATE) as? NSDate
        {
            datePickerView.date = userDefaultEndDate
        }
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleEndDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    func handleEndDatePicker(sender: UIDatePicker) {
        endDate.text = dateFormatter.stringFromDate(sender.date)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sender.date, forKey: Filter.Advanced.END_DATE)
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
    
    
    
    
    
    
    func userAdvancedFilters() {
        
        advancedDefaults()
        
        //Apply user defaults if available
        if let userDefaultStartDate: NSDate = defaults.objectForKey(Filter.Advanced.START_DATE) as? NSDate {
            startDate.text = dateFormatter.stringFromDate(userDefaultStartDate)
        }

        if let userDefaultEndDate: NSDate = defaults.objectForKey(Filter.Advanced.END_DATE) as? NSDate {
            println(userDefaultEndDate)
            endDate.text = dateFormatter.stringFromDate(userDefaultEndDate)
        }

        checkDateRange()

        if let userDefaultKeyword = defaults.stringForKey(Filter.Advanced.KEYWORD) {
            keyword.text = userDefaultKeyword
        }
        
        if let userDefaultSelectedRegions:Array<String> = defaults.objectForKey(Filter.Advanced.SELECTED_REGION) as? Array<String> {
            self.selectedRegions = userDefaultSelectedRegions
            populateRegionText(userDefaultSelectedRegions, textView: regions)
        }

        if let userDefaultRefNum = defaults.stringForKey(Filter.Advanced.REFERENCE_NUM) {
            let refNum = userDefaultRefNum.componentsSeparatedByString(Filter.Advanced.REF_SEPARATER)
            refNumStart.text = refNum[0]
            refNumEnd.text = refNum[1]
        }
        
        if let userDefaultVictim = defaults.stringForKey(Filter.Advanced.VICTIM) {
            victim.text = userDefaultVictim
        }
        
        if let userDefaultAggressor = defaults.stringForKey(Filter.Advanced.AGGRESSOR) {
            aggressor.text = userDefaultAggressor
        }
      
    }

    
    
    
    
    func saveAdvancedFilter() {
        defaults.setObject(dateFormatter.dateFromString(startDate.text), forKey: Filter.Advanced.START_DATE)
        defaults.setObject(dateFormatter.dateFromString(endDate.text), forKey: Filter.Advanced.END_DATE)
        defaults.setObject(keyword.text, forKey: Filter.Advanced.KEYWORD)

        
       //Need to move the save regions array logic here instead of in the subregionview
        
        
        defaults.setObject(refNumStart.text + Filter.Advanced.REF_SEPARATER + refNumEnd.text, forKey: Filter.Advanced.REFERENCE_NUM)
        defaults.setObject(victim.text, forKey: Filter.Advanced.VICTIM)
        defaults.setObject(aggressor.text, forKey: Filter.Advanced.AGGRESSOR)
    }
    
    @IBAction func clearAdvancedFilters(sender: AnyObject) {
        advancedDefaults()
    }
    
    
    func advancedDefaults() {
        let calendar = NSCalendar.currentCalendar()
        var today = calendar.startOfDayForDate(NSDate())
        
        var approxOneYearAgo = calendar.dateByAddingUnit(.CalendarUnitYear, value: -1, toDate: today, options: nil)!
        
        dateFormatter.dateStyle = .ShortStyle
        
        let theDate = dateFormatter.stringFromDate(approxOneYearAgo)

        startDate.text = theDate
        endDate.text = dateFormatter.stringFromDate(NSDate())
        keyword.text = String()
        regions.text = String()
        refNumStart.text = String()
        refNumEnd.text = String()
        victim.text = String()
        aggressor.text = String()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "applyAdvancedFilter" {
            saveAdvancedFilter()
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
        let activeTextFieldRect: CGRect? = aggressor?.frame
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
        aggressor = textField
        scrollView.scrollEnabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        aggressor = nil
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
    
    @IBAction func unwindSubregionFilters(segue:UIStoryboardSegue) {
        if let controller = segue.sourceViewController as? SubregionViewController {
            regions.text = controller.regionsText.text
        }
       
    }
    
}