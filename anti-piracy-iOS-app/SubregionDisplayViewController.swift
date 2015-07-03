//
//  SubregionDisplay.swift
//  anti-piracy-iOS-app
//
//  Created by Travis Baumgart on 7/3/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

import Foundation

class SubregionDisplayViewController: UIViewController {
    
    func populateRegionText(regions: Array<String>, textView: UITextField) {
        var regionsText = ""
        
        for region in regions {
            regionsText += region + ","
        }
    
        if !regions.isEmpty {
            textView.text = regionsText.substringToIndex(regionsText.endIndex.predecessor())
        }
        else {
            textView.text = ""
        }
    
    }
    
}