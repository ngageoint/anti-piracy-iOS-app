//
//  AsamDetailsViewController.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 4/23/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation


class AsamDetailsViewController: UIViewController {

    @IBOutlet var date: UILabel!
    @IBOutlet var aggresor: UILabel!
    @IBOutlet var victim: UILabel!
    @IBOutlet var desc: UITextView!
    
    var dateFormatter = NSDateFormatter()
    
    var asam: Asam?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        dateFormatter.dateFormat = AsamDateFormat.dateFormat
        
        //populate view
        self.title = "ASAM Reference: " + (asam?.reference)!
        date.text = dateFormatter.stringFromDate((asam?.date)!)
        aggresor.text = (asam?.aggressor)!
        victim.text = (asam?.victim)!
        desc.text = (asam?.desc)!
        
    }


}