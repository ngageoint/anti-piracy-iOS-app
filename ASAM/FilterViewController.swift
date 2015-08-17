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
    @IBAction func hideKeyboard(sender: AnyObject) {
         scrollView.endEditing(true)
    }
    
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var selectedInterval: UITextField!
    @IBOutlet weak var shiftKeyword: NSLayoutConstraint!
    @IBOutlet weak var currentSubregionEnabled: UISwitch!

    @IBOutlet weak var scrollView: UIScrollView!
    var dateIntervalPicker: UIPickerView!
    var dateFormatter = NSDateFormatter()
    let pickerData = [DateInterval.ALL, DateInterval.DAYS_30, DateInterval.DAYS_60, DateInterval.DAYS_120, DateInterval.YEARS_1]
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        dateFormatter.dateFormat = AsamDateFormat.dateFormat
        
        dateIntervalPicker = UIPickerView()
        dateIntervalPicker.dataSource = self
        dateIntervalPicker.delegate = self
        selectedInterval.inputView = dateIntervalPicker

        userBasicFilters()
    }
    
    @IBAction func dateIntervalEditBegin(sender: AnyObject) {
            selectedInterval.text = pickerData[DateInterval.DEFAULT]
    }
    
    func userBasicFilters() {
        
        if let userDefaultInterval = defaults.stringForKey(Filter.Basic.DATE_INTERVAL) {
            selectedInterval.text = userDefaultInterval
        } else {
            selectedInterval.text = pickerData[DateInterval.DEFAULT]
        }

        if let userDefaultKeyword = defaults.stringForKey(Filter.Basic.KEYWORD) {
            keyword.text = userDefaultKeyword
        } else {
            keyword.text = String()
        }
        
        let userDefaultCurrentEnabled = defaults.boolForKey(Filter.Basic.CURRENT_SUBREGION)
        currentSubregionEnabled.setOn(userDefaultCurrentEnabled, animated: false)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveBasicFilter() {
        defaults.setObject(Filter.BASIC_TYPE, forKey: Filter.FILTER_TYPE)
        defaults.setObject(selectedInterval.text, forKey: Filter.Basic.DATE_INTERVAL)
        defaults.setObject(keyword.text, forKey: Filter.Basic.KEYWORD)
        defaults.setBool(currentSubregionEnabled.on, forKey: Filter.Basic.CURRENT_SUBREGION)
    }

    @IBAction func switchCurrentSubregion(sender: AnyObject) {
        var currSub = CurrentSubregion()
        if currentSubregionEnabled.on {
            if currSub.askPermission(self) {
                currSub.calculateSubregion()
                currSub.stopLocating()
            } else {
                currentSubregionEnabled.setOn(false, animated: false)
            }
        } else {
            currSub.stopLocating()
        }
    }
    
    @IBAction func clearBasicFilters(sender: AnyObject) {
        basicDefaults()
    }
    
    
    func basicDefaults() {
        selectedInterval.text = pickerData[DateInterval.DEFAULT]
        keyword.text = String()
        currentSubregionEnabled.setOn(false, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "applyBasicFilter" {
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
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInterval.text = pickerData[row]
    }

    
}
