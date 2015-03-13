//
//  FilterViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 3/13/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {


    
    
    @IBOutlet weak var startDate: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func selectStartDate(sender: UITextField) {
        
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)

    }
    
    func handleDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
